#!/usr/bin/env python3
"""Preflight check - verify Python, Docker, gcloud, Terraform are available."""
import shutil, sys

TOOLS = {"python3": "Python 3", "docker": "Docker", "gcloud": "Google Cloud SDK", "terraform": "Terraform"}
ok = True
for cmd, name in TOOLS.items():
    path = shutil.which(cmd)
    if path:
        print(f"  ✓ {name}: {path}")
    else:
        print(f"  ✗ {name}: NOT FOUND")
        ok = False
if ok:
    print("\nAll prerequisites met.")
else:
    print("\nMissing prerequisites. Install before proceeding.")
    sys.exit(1)
