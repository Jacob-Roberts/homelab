#!/usr/bin/env python3
"""Report Docker networks whose subnets overlap protected networks.

Usage: check-docker-subnets.py CIDR [CIDR ...]

Runs on the target host (stdlib only) and prints JSON:
  {"networks": [{"name", "subnet"}...], "overlaps": [{"name", "subnet", "protected"}...]}
"""
import ipaddress
import json
import subprocess
import sys


def main() -> int:
    protected = [ipaddress.ip_network(c, strict=False) for c in sys.argv[1:]]

    ids = subprocess.run(
        ["docker", "network", "ls", "-q"], check=True, capture_output=True, text=True
    ).stdout.split()
    inspected = []
    if ids:
        inspected = json.loads(
            subprocess.run(
                ["docker", "network", "inspect", *ids],
                check=True,
                capture_output=True,
                text=True,
            ).stdout
        )

    networks, overlaps = [], []
    for net in inspected:
        for cfg in (net.get("IPAM") or {}).get("Config") or []:
            if not cfg.get("Subnet"):
                continue
            subnet = ipaddress.ip_network(cfg["Subnet"], strict=False)
            networks.append({"name": net["Name"], "subnet": str(subnet)})
            for p in protected:
                if subnet.version == p.version and subnet.overlaps(p):
                    overlaps.append(
                        {"name": net["Name"], "subnet": str(subnet), "protected": str(p)}
                    )

    json.dump({"networks": networks, "overlaps": overlaps}, sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main())
