#!/usr/bin/env python3
"""Start A2AC Local via Docker Compose."""
import subprocess, sys
r = subprocess.run([sys.executable, "-c", "import shutil; print(shutil.which('docker'))"], capture_output=True, text=True)
if "None" in r.stdout:
    print("Docker not found."); sys.exit(1)
subprocess.run(["docker", "compose", "up", "-d", "--build"], check=True)
print("A2AC Local started on http://localhost:8080")
