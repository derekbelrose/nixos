# Skill Router

Start here. This router implements the agent-wide pattern in `SKILL-GUIDE.md`.

## Purpose

Route each request to the smallest next skill needed, one skill at a time.

## Progressive Disclosure Flow

1. Identify intent from the request.
2. Open only the linked skill for that intent.
3. Execute its procedure and validation.
4. Return here only if the intent changes.

## Decision Table

- New install or reinstall from ISO -> `skills/nixos-host-bootstrap.md`
- Validate edits before or after change -> `skills/nixos-host-validate.md`
- Add a brand-new host profile -> `skills/nixos-add-host.md`
- Create or update a skill doc -> `skills/TEMPLATE.md`

## Escalation Rules

- Start with validation when request is unclear: `skills/nixos-host-validate.md`.
- If task expands, disclose one additional skill at a time.
- Do not load all skills at once unless explicitly requested.

## Exit Criteria

- Exactly one primary skill was used for the current task.
- Validation from that skill was completed or explicitly deferred.
- Any follow-up skill need is called out in the handoff.

## Local Mapping

- Agent-wide `Purpose` -> This file intro + `SKILL-GUIDE.md`
- Agent-wide `Progressive Disclosure Flow` -> `Progressive Disclosure Flow`
- Agent-wide `Decision Table` -> `Decision Table`
- Agent-wide `Escalation Rules` -> `Escalation Rules`
- Agent-wide `Exit Criteria` -> `Exit Criteria`
- Agent-wide `Skill Template` -> `skills/TEMPLATE.md`
