#!/usr/bin/env python3
"""Generate `import` blocks for DNS records that exist in Cloudflare but are not
yet tracked by Terraform.

Terraform only tracks a record once it is in state, so a record you created by
hand and then added to records.tf is still "unmanaged": `tofu apply` tries to
CREATE it and Cloudflare rejects the create with "record already exists".
Importing adopts the existing record instead, which keeps its ID, its
propagation state and its TTL, so nothing stops resolving.

Usage, from inside a zone directory:

    # one-time: find the zone ID (Cloudflare dashboard: zone > Overview > API)
    ./gen-imports.py --zone-id 023e105f4ecef8ad9ca31a8372d0c353 > imports.tf

    # or reuse a records dump you already have (see ../import-1.sh)
    ../import-1.sh && ./gen-imports.py --zone-id <id> --records dns.json

Review imports.tf, then run your normal apply. The blocks are no-ops on later
runs, so it is safe to leave them in place or delete them once imported.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request

KEY_RE = re.compile(r'^    "([\w\-]+)" = \{$')
NAME_RE = re.compile(r'^\s*name\s*=\s*"([^"]*)"', re.M)
TYPE_RE = re.compile(r'^\s*type\s*=\s*"([^"]*)"', re.M)
CONTENT_RE = re.compile(r'^\s*content\s*=\s*"((?:[^"\\]|\\.)*)"', re.M)


def unquote(tok):
    """Strip HCL quoting. Not json.loads: bare IPs and hostnames are not JSON."""
    try:
        return json.loads(tok)
    except (ValueError, TypeError):
        return tok.strip('"')


def read_configured(records_tf):
    """Return [(key, name, type, content)] in file order."""
    lines = open(records_tf).read().split("\n")
    out, i = [], 0
    while i < len(lines):
        m = KEY_RE.match(lines[i])
        if not m:
            i += 1
            continue
        depth, j = 0, i
        while True:
            depth += lines[j].count("{") - lines[j].count("}")
            j += 1
            if depth == 0:
                break
        body = "\n".join(lines[i + 1:j - 1])
        content = CONTENT_RE.search(body)
        out.append((
            m.group(1),
            NAME_RE.search(body).group(1),
            TYPE_RE.search(body).group(1),
            unquote(content.group(1)) if content else None,
        ))
        i = j
    return out


def fetch_records(zone_id, token):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?per_page=5000"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    with urllib.request.urlopen(req, timeout=30) as r:
        payload = json.load(r)
    if not payload.get("success"):
        sys.exit(f"API error: {payload.get('errors')}")
    return payload["result"]


def load_records_file(path):
    payload = json.load(open(path))
    if isinstance(payload, list):
        return payload
    if not payload.get("success"):
        sys.exit(f"{path}: API error: {payload.get('errors')}")
    return payload["result"]


def state_keys(records_tf_dir):
    """Keys already tracked in state, so we only emit imports that are needed.

    Import blocks for already-imported records are harmless no-ops, but leaving
    90 of them in the file makes it much harder to review the 16 that matter.
    """
    try:
        r = subprocess.run(
            ["tofu", "state", "list"],
            cwd=records_tf_dir, capture_output=True, text=True, timeout=60,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if r.returncode != 0:
        return None
    found = set()
    for line in r.stdout.split("\n"):
        m = re.match(r'^cloudflare_dns_record\.records\["([^"]+)"\]$', line.strip())
        if m:
            found.add(m.group(1))
    return found


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--zone-id", help="Cloudflare zone ID (the first half of an import ID)")
    p.add_argument("--records", help="JSON dump of the zone's records, instead of calling the API")
    p.add_argument("--records-tf", default="records.tf")
    p.add_argument("--output", help="write here instead of stdout")
    p.add_argument("--ignore-state", action="store_true",
                   help="emit a block even for records already tracked in state")
    args = p.parse_args()

    zone_dir = os.path.dirname(os.path.abspath(args.records_tf))
    if not os.path.exists(args.records_tf):
        sys.exit(f"{args.records_tf} not found; run this from inside a zone directory")
    if not args.zone_id:
        # The import ID is "<zone_id>/<dns_record_id>" and the provider rejects
        # anything else, so a placeholder here would only fail later at apply.
        sys.exit("--zone-id is required (Cloudflare dashboard: zone > Overview > API)")

    tracked = None
    if not args.ignore_state:
        tracked = state_keys(zone_dir)
        if tracked is None:
            print("# note: could not read state, so blocks are emitted for every "
                  "matching record. Re-run this from Semaphore (which has backend "
                  "access) to get a minimal list.", file=sys.stderr)

    configured = read_configured(args.records_tf)
    if args.records:
        remote = load_records_file(args.records)
    else:
        token = os.environ.get("CLOUDFLARE_API_TOKEN")
        if not token:
            sys.exit("CLOUDFLARE_API_TOKEN is not set (try: infisical run -- ./gen-imports.py ...)")
        remote = fetch_records(args.zone_id, token)

    # index remote records by (name, type) so a config entry can be matched
    by_name_type = {}
    for r in remote:
        by_name_type.setdefault((r["name"], r["type"]), []).append(r)

    blocks, unresolved, ambiguous, already = [], [], [], []
    for key, name, rtype, content in configured:
        if tracked and key in tracked:
            already.append(key)
            continue
        candidates = by_name_type.get((name, rtype), [])
        if not candidates:
            continue
        if content is None:
            # no content in config (e.g. SRV, which uses data) - ambiguous
            ambiguous.append((key, name, rtype, len(candidates)))
            continue
        exact = [c for c in candidates if c.get("content") == content]
        if len(exact) == 1:
            r = exact[0]
            blocks.append((key, f"{args.zone_id}/{r['id']}"))
        elif not exact:
            unresolved.append((key, name, rtype, content))
        else:
            ambiguous.append((key, name, rtype, len(exact)))

    out = [
        "# Generated by gen-imports.py. Each block adopts a record that already",
        "# exists in Cloudflare so Terraform stops trying to create it.",
        "# Safe to re-run: a block for an already-imported record is a no-op.",
        "",
    ]
    for key, iid in blocks:
        out.append("import {")
        out.append(f'  to = cloudflare_dns_record.records["{key}"]')
        out.append(f'  id = "{iid}"')
        out.append("}")
        out.append("")
    text = "\n".join(out).rstrip() + "\n"

    if args.output:
        open(args.output, "w").write(text)
        print(f"wrote {len(blocks)} import block(s) to {args.output}", file=sys.stderr)
    else:
        print(text, end="")

    if already:
        print(f"# skipped {len(already)} record(s) already tracked in state", file=sys.stderr)
    if ambiguous:
        print(f"\n# NOTE: {len(ambiguous)} matching record(s) could not be matched to one "
              f"config entry automatically:", file=sys.stderr)
        for key, name, rtype, n in ambiguous:
            print(f"#   {key}  ({rtype} {name}) - {n} candidate(s) in Cloudflare", file=sys.stderr)
        print("# Look these up by hand and write the import block yourself.", file=sys.stderr)
    if unresolved:
        print(f"\n# NOTE: {len(unresolved)} config entry/entries have a name and type that "
              f"exist in Cloudflare but different content, so they were left out:", file=sys.stderr)
        for key, name, rtype, content in unresolved:
            print(f"#   {key}  ({rtype} {name}) content={content!r}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())