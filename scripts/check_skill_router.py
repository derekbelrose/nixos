#!/usr/bin/env python3

import argparse
import re
import sys
from pathlib import Path


REQUIRED_SECTIONS = [
    "Purpose",
    "Progressive Disclosure Flow",
    "Decision Table",
    "Escalation Rules",
    "Exit Criteria",
    "Local Mapping",
]


def extract_h2_sections(content: str) -> list[str]:
    sections = []
    for line in content.splitlines():
        match = re.match(r"^##\s+(.+?)\s*$", line)
        if match:
            sections.append(match.group(1))
    return sections


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate SKILL router sections against project standard"
    )
    parser.add_argument(
        "router",
        nargs="?",
        default="SKILL.md",
        help="Path to router markdown file (default: SKILL.md)",
    )
    args = parser.parse_args()

    router_path = Path(args.router)
    if not router_path.exists():
        print(f"ERROR: router file not found: {router_path}")
        return 1

    content = router_path.read_text(encoding="utf-8")
    headings = extract_h2_sections(content)

    missing = [name for name in REQUIRED_SECTIONS if name not in headings]

    if missing:
        print(f"FAIL: {router_path} is missing required sections:")
        for name in missing:
            print(f"- {name}")
        return 1

    decision_rows = re.findall(r"^-\s+.+->\s+`.+`\s*$", content, flags=re.MULTILINE)
    if not decision_rows:
        print("FAIL: no decision mappings found (expected '- <intent> -> `<path>`').")
        return 1

    print(f"PASS: {router_path} includes all required sections and decision mappings.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
