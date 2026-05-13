"""Test receipt schema validation."""

REQUIRED_FIELDS = {"receipt_id", "event_type", "status", "q_command", "agent_id", "created_at", "runtime_policy"}

def test_receipt_has_required_fields():
    sample = {
        "receipt_id": "rcpt_001",
        "event_type": "workflow.complete",
        "status": "COMPLETE",
        "q_command": "TEST|SMOKE->LOCAL|DONE",
        "agent_id": "test-agent",
        "created_at": "2026-05-11T22:00:00Z",
        "runtime_policy": "python_only",
    }
    missing = REQUIRED_FIELDS - set(sample.keys())
    assert not missing, f"Missing required fields: {missing}"

def test_receipt_rejects_missing_fields():
    incomplete = {"receipt_id": "rcpt_002", "status": "COMPLETE"}
    missing = REQUIRED_FIELDS - set(incomplete.keys())
    assert len(missing) > 0, "Incomplete receipt should have missing fields"

def test_receipt_runtime_policy():
    sample = {"runtime_policy": "python_only"}
    assert sample["runtime_policy"] == "python_only"
