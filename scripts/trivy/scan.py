#!/usr/bin/env python3
"""Scan container images referenced by this homelab repo with Trivy.

Extracts `image:` references from Docker Compose files and Kubernetes
manifests, deduplicates them, and runs `trivy image` against each one.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path
from typing import Iterable

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
COMPOSE_DIR = REPO_ROOT / "docker-compose"
K8S_DIR = REPO_ROOT / "kubernetes"

COMPOSE_FILENAMES = {"compose.yaml", "compose.yml", "docker-compose.yaml", "docker-compose.yml"}


def is_compose_file(path: Path) -> bool:
    return path.name in COMPOSE_FILENAMES or path.name.startswith("compose.")


def collect_compose_images(root: Path) -> set[str]:
    images: set[str] = set()
    for path in root.rglob("*"):
        if not path.is_file() or not is_compose_file(path):
            continue
        try:
            with path.open() as fh:
                docs = list(yaml.safe_load_all(fh))
        except (yaml.YAMLError, OSError) as exc:
            print(f"warn: could not parse {path}: {exc}", file=sys.stderr)
            continue
        for doc in docs:
            if not isinstance(doc, dict):
                continue
            services = doc.get("services")
            if not isinstance(services, dict):
                continue
            for service in services.values():
                if isinstance(service, dict) and isinstance(service.get("image"), str):
                    images.add(service["image"].strip())
    return images


def collect_k8s_images(root: Path) -> set[str]:
    images: set[str] = set()

    def walk(obj: object) -> None:
        if isinstance(obj, dict):
            for key, value in obj.items():
                if key == "image" and isinstance(value, str):
                    candidate = value.strip()
                    # Skip obvious non-image values (e.g. configmap entries).
                    if candidate and not candidate.startswith(("http://", "https://")):
                        images.add(candidate)
                else:
                    walk(value)
        elif isinstance(obj, list):
            for item in obj:
                walk(item)

    for path in root.rglob("*.yaml"):
        if not path.is_file():
            continue
        # Skip generated/output directories.
        if "_out" in path.parts or ".terraform" in path.parts:
            continue
        try:
            with path.open() as fh:
                docs = list(yaml.safe_load_all(fh))
        except (yaml.YAMLError, OSError) as exc:
            print(f"warn: could not parse {path}: {exc}", file=sys.stderr)
            continue
        for doc in docs:
            if doc is not None:
                walk(doc)
    # Also handle .yml
    for path in root.rglob("*.yml"):
        if not path.is_file() or "_out" in path.parts or ".terraform" in path.parts:
            continue
        try:
            with path.open() as fh:
                docs = list(yaml.safe_load_all(fh))
        except (yaml.YAMLError, OSError) as exc:
            print(f"warn: could not parse {path}: {exc}", file=sys.stderr)
            continue
        for doc in docs:
            if doc is not None:
                walk(doc)
    return images


def normalize(images: Iterable[str]) -> list[str]:
    out: set[str] = set()
    for img in images:
        img = img.strip().strip('"').strip("'")
        if not img or "${" in img or "$" in img:
            continue
        # Drop images with whitespace.
        if any(ch.isspace() for ch in img):
            continue
        out.add(img)
    return sorted(out)


def run_trivy(images: list[str], args: argparse.Namespace) -> int:
    trivy = args.trivy or "trivy"
    worst = 0
    for idx, image in enumerate(images, 1):
        print(f"\n===== [{idx}/{len(images)}] {image} =====", flush=True)
        cmd = [trivy, "image"]
        if args.config:
            cmd += ["--config", args.config]
        cmd += ["--severity", args.severity]
        if args.ignore_unfixed:
            cmd += ["--ignore-unfixed"]
        if args.format:
            cmd += ["--format", args.format]
        if args.output:
            out_path = Path(args.output) / (image.replace("/", "_").replace(":", "_") + ".json")
            out_path.parent.mkdir(parents=True, exist_ok=True)
            cmd += ["--output", str(out_path), "--format", "json"]
        cmd += ["--exit-code", str(args.exit_code)]
        cmd.append(image)
        if args.dry_run:
            print(" ".join(cmd))
            continue
        try:
            result = subprocess.run(cmd, check=False)
            worst = max(worst, result.returncode)
        except FileNotFoundError:
            print("error: trivy not found on PATH", file=sys.stderr)
            return 127
    return worst


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan homelab container images with Trivy")
    parser.add_argument("--source", choices=["compose", "k8s", "all"], default="all")
    parser.add_argument("--dry-run", action="store_true", help="Only list images / commands, do not scan")
    parser.add_argument("--severity", default="HIGH,CRITICAL")
    parser.add_argument("--ignore-unfixed", action="store_true", default=True)
    parser.add_argument("--no-ignore-unfixed", dest="ignore_unfixed", action="store_false")
    parser.add_argument("--format", default=None)
    parser.add_argument("--output", default=None, help="Directory for per-image JSON reports")
    parser.add_argument("--exit-code", type=int, default=0)
    parser.add_argument("--trivy", default=None, help="Path to trivy binary")
    parser.add_argument("--config", default=str(REPO_ROOT / "scripts" / "trivy" / "trivy.yaml") if (REPO_ROOT / "scripts" / "trivy" / "trivy.yaml").exists() else None)
    args = parser.parse_args()

    images: set[str] = set()
    if args.source in ("compose", "all"):
        images |= collect_compose_images(COMPOSE_DIR)
    if args.source in ("k8s", "all"):
        images |= collect_k8s_images(K8S_DIR)

    images_list = normalize(images)
    print(f"Found {len(images_list)} unique images", file=sys.stderr)

    if args.dry_run and not args.output:
        for img in images_list:
            print(img)
        # Still allow command preview? no.
        return 0

    # If dry-run requested but we also want commands, run_trivy handles printing.
    if args.dry_run:
        return run_trivy(images_list, args)

    # Default: list first
    for img in images_list:
        print(img, file=sys.stderr)

    return run_trivy(images_list, args)


if __name__ == "__main__":
    raise SystemExit(main())