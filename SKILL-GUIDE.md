# Agent-Wide Skill Guide Pattern

Use this as the generic pattern across repositories. Keep it repo-agnostic and map to local files in each project's `SKILL.md`.

## Goal

Provide a single, predictable entrypoint for routing work by intent using progressive disclosure.

## Core Rules

- Route by user intent, not by file name.
- Load one primary skill first.
- Disclose one additional skill only when scope expands.
- Keep validation explicit in every skill.

## Required Sections For Any Project Router

1. `Purpose`
2. `Progressive Disclosure Flow`
3. `Decision Table` (intent -> skill)
4. `Escalation Rules`
5. `Exit Criteria`
6. `Local Mapping` (agent-wide pattern -> project files)

## Decision Table Template

- `<intent-a>` -> `<project-skill-a>`
- `<intent-b>` -> `<project-skill-b>`
- `<intent-c>` -> `<project-skill-c>`

## Escalation Template

- If intent is unclear, start with validation skill.
- If request grows, add one next-best skill.
- If multiple tracks are required, process sequentially and restate active skill each handoff.

## Exit Template

- Exactly one primary skill was active at a time.
- Validation completed or explicitly deferred with reason.
- Next skill (if any) is named in handoff.

## Router Lint

Validate project routers with:

```bash
python3 scripts/check_skill_router.py
```
