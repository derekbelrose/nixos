# Local Skills

These are reusable playbooks for common work in this NixOS fleet repo.

Primary entrypoint: `../SKILL.md` (progressive-disclosure router).
Agent-wide pattern reference: `../SKILL-GUIDE.md`.

All skill files follow a shared template so they stay consistent and easy to extend.

## How To Use

- Open the matching file in `skills/`.
- Follow the checklist and command examples.
- Keep host-specific values in the host `default.nix` or `disko.nix`.

## Available Skills

- `skills/TEMPLATE.md` - canonical format for new or updated skills.
- `skills/nixos-host-bootstrap.md` - fresh install and first boot flow.
- `skills/nixos-host-validate.md` - pre-change validation flow.
- `skills/nixos-add-host.md` - add a new host to the flake.
