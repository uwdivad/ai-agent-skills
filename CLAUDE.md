# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Git-versioned source of truth for reusable `SKILL.md` workflows shared between Claude Code and OpenAI Codex. There is no application code: the deliverables are the Markdown skills under `skills/<name>/SKILL.md`, plus installer scripts that symlink each skill directory into the user-level discovery paths (`~/.claude/skills/<name>` and `~/.agents/skills/<name>`).

## Commands

```powershell
python scripts/validate.py                      # validate every skill manifest (no third-party deps)
python -m unittest discover -s tests -v         # the single test just asserts validate() returns no errors
python -m unittest tests.test_skills.SkillTests.test_skill_manifests   # run the one test directly
```

CI (`.github/workflows/validate.yml`) runs exactly those two commands on push and PR with Python 3.12. The validator uses `list[str]` syntax, so it needs Python 3.9+.

Install / uninstall into the local agents (symlinks; `-WhatIf` / `--dry-run` previews):

```powershell
.\scripts\install.ps1 [-Agent Claude|Codex] [-Force] [-CopyFallback] [-WhatIf]   # Windows
.\scripts\uninstall.ps1 [-Agent Claude|Codex] [-WhatIf]
```

```bash
scripts/install.sh [--agent claude|codex] [--force] [--copy-fallback] [--dry-run]  # macOS / Linux
scripts/uninstall.sh [--agent claude|codex] [--dry-run]
```

## Skill contract (enforced by `scripts/validate.py`)

Every directory under `skills/` must contain a `SKILL.md` that:

- starts with YAML frontmatter delimited by `---` lines, parsed with a simple regex (top-level `key: value` only, no nested YAML);
- has `name` equal to its kebab-case directory name (`^[a-z][a-z0-9-]*$`) and unique across skills;
- has a non-empty `description` of at most 1024 characters that says *when* to invoke the skill;
- has at least 150 characters of instruction body and a total size under 100 KB (split into reference files beyond that).

`REQUIRED` in `validate.py` hard-codes the set of skills that must exist. Adding a skill means creating the directory, and removing or renaming one means updating that set, or validation fails. The installer reads `skills/*/` directly, so a new directory is picked up on the next install run with no other registration.

## Skill authoring conventions

All current skills follow the same shape: frontmatter, an H1, a one-line framing sentence, a numbered `## Procedure`, constraints, and an `## Output` section that prescribes a severity-ordered finding format (Finding, Evidence `file:line`, Failure scenario, Fix, Test, Confidence). Skills are review/analysis workflows that are read-only by default, require inspecting actual code before reporting a defect, separate verified findings from assumptions, and never modify source, install packages, or run destructive operations without approval. Keep new skills consistent with that stance.

## Installer invariants

Both the PowerShell and shell installers share the same safety rules; preserve them when editing either:

- Link **per-skill directories**, never the parent `skills/` directory or the `SKILL.md` file (works around Codex skill-discovery inconsistencies).
- Never delete a real directory at the target path, even with `-Force` / `--force`; only existing symlinks are replaced.
- Record every installed path in the gitignored `.skill-install-state.json` (array of `{path, source, mode}`); the uninstaller removes only recorded symlinks whose current target still matches `source`. The shell scripts write that file one object per line and parse it with `sed`, so keep that layout if you touch the serialisation.
- `-CopyFallback` / `--copy-fallback` copies instead of linking when symlinks are not permitted; copies are recorded with `mode: copy` and are never auto-removed.

The `.idea/` directory is a local IDE artifact and is gitignored.
