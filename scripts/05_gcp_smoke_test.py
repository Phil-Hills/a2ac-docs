#!/usr/bin/env python3
"""Smoke test deployed GCP sandbox."""
import argparse, json, urllib.request
p = argparse.ArgumentParser()
p.add_argument("--url", required=True, help="Deployed service URL")
args = p.parse_args()
for path in ["/health", "/.well-known/agent.json"]:
    try:
        r = urllib.request.urlopen(f"{args.url}{path}", timeout=10)
        print(f"  ✓ {path} → {r.status}")
    except Exception as e:
        print(f"  ✗ {path} → {e}")
