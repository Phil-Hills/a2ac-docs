#!/usr/bin/env python3
"""Run terraform plan for GCP sandbox."""
import argparse, subprocess, sys
p = argparse.ArgumentParser()
p.add_argument("--project", required=True)
p.add_argument("--region", default="us-central1")
args = p.parse_args()
subprocess.run(["terraform", "init"], cwd="terraform", check=True)
subprocess.run(["terraform", "plan", f"-var=project_id={args.project}", f"-var=region={args.region}"], cwd="terraform", check=True)
