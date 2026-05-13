#!/usr/bin/env python3
"""Run terraform apply (or destroy) for GCP sandbox."""
import argparse, subprocess
p = argparse.ArgumentParser()
p.add_argument("--destroy", action="store_true")
args = p.parse_args()
cmd = ["terraform", "destroy", "-auto-approve"] if args.destroy else ["terraform", "apply", "-auto-approve"]
subprocess.run(cmd, cwd="terraform", check=True)
