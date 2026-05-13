"""Test Q command parsing."""

def parse_q(q_command):
    parts = q_command.split("->")
    left = parts[0] if len(parts) > 0 else ""
    right = parts[1] if len(parts) > 1 else ""
    left_parts = left.split("|")
    domain = left_parts[0] if len(left_parts) > 0 else ""
    sequence_raw = left_parts[1] if len(left_parts) > 1 else ""
    if "[" in sequence_raw:
        sequence = sequence_raw.split("[")[0]
        arg = sequence_raw.split("[")[1].rstrip("]")
    else:
        sequence = sequence_raw
        arg = None
    right_parts = right.split("|")
    target = right_parts[0] if len(right_parts) > 0 else ""
    outcome = right_parts[1] if len(right_parts) > 1 else ""
    return {"domain": domain, "sequence": sequence, "arg": arg, "target": target, "outcome": outcome}

def test_valid_q_command():
    r = parse_q("DOCUMENT|INTAKE[EnterprisePackage]->AGENT[demo-agent-01]|REQUESTED")
    assert r["domain"] == "DOCUMENT"
    assert r["sequence"] == "INTAKE"
    assert r["arg"] == "EnterprisePackage"
    assert r["target"] == "AGENT[demo-agent-01]"
    assert r["outcome"] == "REQUESTED"

def test_q_command_no_arg():
    r = parse_q("INFRA|DEPLOY->GCP|PROVISIONED")
    assert r["domain"] == "INFRA"
    assert r["sequence"] == "DEPLOY"
    assert r["arg"] is None
    assert r["outcome"] == "PROVISIONED"

def test_q_command_simple():
    r = parse_q("TEST|SMOKE->LOCAL|DONE")
    assert r["domain"] == "TEST"
    assert r["sequence"] == "SMOKE"
    assert r["outcome"] == "DONE"
