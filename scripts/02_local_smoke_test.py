#!/usr/bin/env python3
"""Smoke test local A2AC endpoints."""
import json, urllib.request

BASE = "http://localhost:8080"
tests = [
    ("GET", f"{BASE}/health", None),
    ("GET", f"{BASE}/.well-known/agent.json", None),
    ("POST", f"{BASE}/cube/make", {"payload": {"test": True}}),
    ("POST", f"{BASE}/q/parse", {"q_command": "TEST|SMOKE[local]->AGENT[test]|REQUESTED"}),
    ("POST", f"{BASE}/receipt/write", {"event_type": "smoke_test", "status": "COMPLETE"}),
    ("GET", f"{BASE}/receipts", None),
]

for method, url, data in tests:
    try:
        if data:
            req = urllib.request.Request(url, data=json.dumps(data).encode(), headers={"Content-Type": "application/json"})
        else:
            req = urllib.request.Request(url)
        r = urllib.request.urlopen(req, timeout=5)
        body = json.loads(r.read())
        print(f"  ✓ {method} {url.replace(BASE, '')} → {r.status}")
    except Exception as e:
        print(f"  ✗ {method} {url.replace(BASE, '')} → {e}")
