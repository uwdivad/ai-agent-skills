# AI Agent Skills

A single, Git-versioned source of truth for reusable `SKILL.md` workflows across **Claude Code** and **OpenAI Codex**. Each skill lives under `skills/<name>/SKILL.md`; Windows installer creates **per-skill directory symbolic links** into the two user-level agent discovery locations. No copies are needed when symlinks work.

## Included skills

| Skill | Purpose |
| --- | --- |
| `fastapi-code-review` | FastAPI-specific async, DI, security, lifecycle, ORM, and production antipattern audit |
| `python-code-review` | Python correctness, maintainability, concurrency, security, and performance review |
| `repository-explorer` | Architecture, call chains, git history, diagrams, and interview-ready walkthrough |
| `system-design-review` | Requirements, capacity, scaling, reliability, consistency, security and tradeoffs |
| `ai-pipeline-review` | RAG/agents/LLM ingest, retrieval, tools, evaluations, privacy, tracing, and cost |

Skills are **read-only by default**. They prioritize verified findings and request-specific scope over speculative lint-style warnings.

## Install globally on Windows

Requirements: Git, PowerShell 5.1+ and a current Claude Code and/or Codex installation. Python 3.9+ is only needed for validation. Windows Developer Mode (Settings > System > For developers) or administrator privilege is typically required to create symbolic links.

```powershell
git clone https://github.com/YOUR_USERNAME/ai-agent-skills.git "$HOME\ai-agent-skills"
cd "$HOME\ai-agent-skills"
python scripts/validate.py
.\scripts\install.ps1
```

If execution policy blocks the script, use `powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1` for that invocation (review any script before running). If you cannot create symbolic links, run `.\scripts\install.ps1 -CopyFallback` to copy skills instead; copies must be refreshed after edits.

Optional flags:

```powershell
.\scripts\install.ps1 -Agent Claude           # Only Claude
.\scripts\install.ps1 -Agent Codex            # Only Codex
.\scripts\install.ps1 -WhatIf                # Preview
.\scripts\install.ps1 -Force                 # Replace existing symlinks only; never real directories
.\scripts\uninstall.ps1 -WhatIf              # Preview unlink
.\scripts\uninstall.ps1                       # Remove links created by this installer
```

## Install globally on macOS or Linux

Requirements: Git, Bash 3.2+ and a current Claude Code and/or Codex installation. Python 3.9+ is only needed for validation.

```bash
git clone https://github.com/YOUR_USERNAME/ai-agent-skills.git "$HOME/ai-agent-skills"
cd "$HOME/ai-agent-skills"
python3 scripts/validate.py
chmod +x scripts/*.sh
scripts/install.sh
```

Optional flags mirror the PowerShell installer:

```bash
scripts/install.sh --agent claude      # Only Claude
scripts/install.sh --agent codex       # Only Codex
scripts/install.sh --dry-run           # Preview
scripts/install.sh --force             # Replace existing symlinks only; never real directories
scripts/install.sh --copy-fallback     # Copy instead of linking if symlinks fail
scripts/uninstall.sh --dry-run         # Preview unlink
scripts/uninstall.sh                   # Remove links created by this installer
```

**Paths:** `$HOME\.claude\skills\<name>` (Claude Code) and `$HOME\.agents\skills\<name>` (Codex); on macOS/Linux, `~/.claude/skills/<name>` and `~/.agents/skills/<name>`. We link each **skill directory**, not the parent `skills` directory and not the `SKILL.md` file. This avoids known skill-discovery inconsistencies in some Codex releases. Restart both agents after install. If a skill does not appear, check its `SKILL.md`, installed path, and the agent version.

**Safety:** Existing real directories are never deleted, including with `-Force`. Existing paths are skipped by default; `-Force` replaces existing links, so inspect its `-WhatIf` result first. The installer tracks installed paths in ignored `.skill-install-state.json`; the uninstaller removes only recorded links whose target still matches. Copied folders are not automatically deleted. The install state is local to this clone; reinstall if you move the clone.

## Use

In your agent, request the skill by name. Examples:

- `Use fastapi-code-review to audit this FastAPI app, reporting P0–P3 findings with file:line evidence; don't change code.`
- `Use repository-explorer to map the request lifecycle, draw diagrams, and summarize architectural decisions from git history.`
- `Use ai-pipeline-review to check our RAG pipeline for retrieval correctness, prompt injection, tenant isolation, and eval coverage.`

Some agent versions expose these as slash commands or skill-picker entries; invoking them in natural language also works when the skill is discovered.

## Updates and sharing

Edit the canonical `skills/<name>/SKILL.md`, commit, and push. Machines using directory symlinks read your latest *local checkout* immediately after `git pull`; restart the agent if necessary. For sharing, create a private GitHub repository and grant collaborators access, or publish the repo. **Nothing is uploaded to GitHub by this ZIP automatically.** Colleagues clone and run the installer on their own machines.

To pin a version, check out a tag in a separate clone or vendor a skill into a project (copies do not automatically update). For team-specific rules, prefer project-level `.claude/skills/` and `.agents/skills/` directories checked into that team's project. Avoid conflicting duplicate names at user/project level.

## Validate / contribute

```powershell
python scripts/validate.py
python -m unittest discover -s tests -v
```

CI runs the same checks on push and pull request. The validator checks manifest structure, skill names, description presence, and minimum instruction content; it is **not** a full YAML parser or a guarantee of agent behavior. Add good/bad code fixtures and agent-side evaluation runs when skills mature. New skills should contain a `SKILL.md` with frontmatter `name` matching its kebab-case directory and a clear `description` specifying when to invoke it.

## Skill review standards

1. Inspect actual repository code before reporting a defect; search matches alone are not proof.
2. Ground findings in files, lines, plausible failure scenarios, and fixes/tests.
3. Separate verified issues from assumptions and untested risks.
4. Do not modify source, deploy, install new packages, or run destructive operations without approval.
5. Never include secrets, personal data, or confidential source excerpts in shared reports.

## Repository layout

```text
ai-agent-skills/
  skills/
    fastapi-code-review/SKILL.md
    python-code-review/SKILL.md
    repository-explorer/SKILL.md
    system-design-review/SKILL.md
    ai-pipeline-review/SKILL.md
  scripts/install.ps1        # Windows
  scripts/uninstall.ps1
  scripts/install.sh         # macOS / Linux
  scripts/uninstall.sh
  scripts/validate.py
  tests/test_skills.py
  .github/workflows/validate.yml
  README.md
```
