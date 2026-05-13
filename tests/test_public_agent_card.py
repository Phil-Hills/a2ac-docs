"""Test public agent card for blocked content."""
import json
from pathlib import Path

BLOCKED_SKILLS = {"commerce_offer", "payment_subscribe", "brain_recall", "brain_remember", "librarian_organize"}
BLOCKED_WORDS = {"mortgage", "blockchain", "immutable"}

def test_agent_card_no_blocked_skills():
    card = json.loads(Path("agent_card.json").read_text())
    skill_ids = {s["id"] for s in card.get("skills", [])}
    violations = skill_ids & BLOCKED_SKILLS
    assert not violations, f"Blocked skills found: {violations}"

def test_agent_card_no_blocked_words():
    raw = Path("agent_card.json").read_text().lower()
    for word in BLOCKED_WORDS:
        assert word not in raw, f"Blocked word '{word}' found in agent_card.json"

def test_agent_card_has_required_fields():
    card = json.loads(Path("agent_card.json").read_text())
    assert card.get("name"), "Missing name"
    assert card.get("description"), "Missing description"
    assert card.get("url"), "Missing url"
    assert card.get("skills"), "Missing skills"
