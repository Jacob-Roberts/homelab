# Restrict PBJ gateway access over Netbird

Date: 2026-10-23

Status: proposed

## Context

Public hostnames (`auth.jakerob.pro`, `auth.autovation.com`, ...) CNAME to
`iad1-node-1`. iad1 terminates TLS with Traefik and proxies the requests over
Netbird to the destination:

- `auth.jakerob.pro` -> `http://192.168.42.200` (Cilium Gateway, plain HTTP)
- `auth.autovation.com` -> `https://slc1-node-3.vpn.jakerob.pro`

The `PBJ 192.168.42.0/24` Netbird route (routing peer `pbj-node-1`) currently
has no access control group, so every peer that receives the route can reach
the gateway's plaintext listener. That listener matches every hostname, so the
exposure is every HTTPRoute attached to `my-gateway`, not just pocket-id.

TLS on the iad1 -> gateway hop was considered and rejected:

- The hop already runs inside WireGuard, which provides encryption, peer
  authentication and replay protection.
- iad1 terminates the client TLS, so it sees plaintext regardless.
- `https://192.168.42.200` does not work: the HTTPS listeners are selected by
  SNI and an IP-address URL sends none, so Cilium resets the connection
  (verified: `curl: (35) Recv failure: Connection reset by peer`).
  Making it work needs a hostname/SNI plus a dedicated verified
  `serversTransport`; using the existing global `insecureSkipVerify: true`
  would add encryption without authentication, which WireGuard already gives.

Cilium cannot filter gateway clients by source either:

- Backend pods see the per-node Envoy proxy as the TCP peer. Observed via
  whoami through the gateway: `RemoteAddr: 10.244.0.219:*` (Envoy pod) with the
  real client only in `X-Forwarded-For`.
- L7 `CiliumNetworkPolicy` header matching is exact-match only, and it breaks
  streaming/long-lived endpoints. Per-application L4 allowlisting behind one
  shared Gateway is a known limitation
  ([cilium#43556](https://github.com/cilium/cilium/issues/43556)).

## Decision

Netbird is the enforcement point for who can reach the PBJ gateway.

- Keep plain HTTP on the iad1 -> gateway hop and treat the Netbird tunnel as
  the trust boundary.
- Restrict the `PBJ 192.168.42.0/24` route's access control group and add a
  route access policy allowing only iad1's peer on TCP 80 and 443.
- Add other peers explicitly if they need direct access to the PBJ LAN. Do not
  fall back to the `All` group.
- Use Cilium policies only for east-west restriction (optional draft below),
  not for gateway client allowlisting.

The Netbird configuration is dashboard-managed and lives outside this repo;
this document is its source of truth until it is codified with the Netbird
Terraform provider.

## Implementation (Netbird dashboard)

Create these groups under **Access Control -> Groups**:

| Group           | Members                                | Purpose                          |
| --------------- | -------------------------------------- | -------------------------------- |
| `iad1-egress`   | `iad1-node-1`                          | only peer allowed to use the route |
| `pbj-gateway`   | none (intentionally empty)             | destination marker for the route |
| `homelab-admins`| optional: laptops needing direct LAN access | explicit, auditable exception |

1. **Network Routing -> Routes -> PBJ `192.168.42.0/24`**
   - Set **Access Control Groups** to `pbj-gateway`.
   - Optionally narrow **Distribution Groups** to `iad1-egress` as well, so
     other peers are not handed the route at all. Distribution is an
     optimization; the access policy is the security boundary.
   - If you set the access control group but no enabled route policy matches,
     *all* routed traffic is dropped. Create the policy before saving, or
     expect an outage until it exists.
2. **Access Control -> Policies -> Add policy**
   - Name: `iad1 to PBJ gateway`
   - Source: `iad1-egress`
   - Destination: `pbj-gateway`
   - Protocol: `TCP`, Ports: `80,443`
   - Direction: unidirectional (source initiates)
   - Enabled: yes
3. If `homelab-admins` needs direct LAN access, add it as a second source group
   on the same policy (or a second policy). Keep the member list short and
   deliberate; this is the exception, not the default.

Notes:

- Route policies apply from routing clients to the routing peer and are
  unidirectional.
- The default `All` peer policy does not bypass a route access policy, but it
  is still worth reducing separately; it is not part of this change.
- Other routes are unaffected. `pbj-node-1.vpn.jakerob.pro` is a direct
  peer-to-peer address, not routed through `192.168.42.0/24`.

## Verification

From iad1 (the allowed peer), the tunnel hop must still work:

```zsh
curl -fsS -o /dev/null -H 'Host: auth.jakerob.pro' http://192.168.42.200/
curl -fsS -o /dev/null --max-time 5 https://auth.autovation.com/
```

From a peer that is **not** in `iad1-egress`, a direct request to the gateway
should now time out, while the public hostname still works through iad1:

```zsh
curl -sS --max-time 3 -o /dev/null -H 'Host: auth.jakerob.pro' \
  http://192.168.42.200/          # expect: timeout / connection failure
curl -fsS -o /dev/null https://auth.jakerob.pro/   # expect: 200 via iad1
```

Run `./scripts/test-tls.sh` from the LAN or from iad1. When run from a remote
peer that is not in the allowlist, its "internal path" checks are expected to
fail; that is the restriction working.

Netbird's **Activity** view should show the policy change; the route's
access-control group must be non-empty (or the documented empty marker) or
traffic is dropped by design.

## Optional Cilium hardening (east-west only)

This does **not** restrict gateway clients; it only prevents workloads from
bypassing the gateway and talking to pocket-id directly. It also makes ingress
default-deny for that pod, so allow `host` if `kubectl port-forward` is used
against it.

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: pocket-id-ingress
  namespace: pocket-id
spec:
  endpointSelector:
    matchLabels:
      app: pocket-id
  ingress:
    - fromEntities:
        - ingress   # Cilium Gateway / Envoy traffic
        - host      # kubectl port-forward and node-local checks
      toPorts:
        - ports:
            - port: "1411"
              protocol: TCP
```

Apply only after confirming with Hubble that gateway traffic is attributed to
the `ingress` entity in this cluster; if it is not, the policy will block the
public path.

## Consequences

- Remote peers lose direct access to `192.168.42.0/24` unless explicitly added
  to `iad1-egress`; they still reach published services through iad1.
- LAN access is unchanged: local clients reach `192.168.42.200` directly and
  never touch the route.
- The gateway's HTTP listener still serves every attached hostname over
  plaintext inside the tunnel. This decision accepts that because only iad1
  can reach it.
- The restriction is Netbird dashboard state, not git state. If the route is
  recreated without the access control group, the exposure returns silently.

## Rollback

Remove the access control group from the route (or disable the policy). Route
access returns to unrestricted as soon as no access control group is assigned.
