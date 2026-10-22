# Trivy scanning

Scan the container images referenced by this repository's Docker Compose
files and Kubernetes manifests.

## Prerequisites

Trivy is provided via `mise`:

```sh
mise install
```

## Usage

List the images that would be scanned:

```sh
python scripts/trivy/scan.py --dry-run
```

Scan everything (report only, exit 0):

```sh
python scripts/trivy/scan.py
```

Scan only Docker Compose images and fail on HIGH/CRITICAL:

```sh
python scripts/trivy/scan.py --source compose --exit-code 1
```

Write per-image JSON reports:

```sh
python scripts/trivy/scan.py --output /tmp/trivy-reports
```

## In-cluster

The Trivy Operator is deployed to the `trivy-system` namespace via Flux
(see `kubernetes/infrastructure/controllers/trivy-operator.yaml`) and
continuously scans running workloads, producing `VulnerabilityReport`
resources.