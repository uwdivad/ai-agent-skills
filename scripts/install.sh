#!/usr/bin/env bash
# Install skills into Claude Code and/or Codex user-level skill directories on macOS/Linux.
# Mirrors scripts/install.ps1: one symbolic link per skill directory, tracked in
# .skill-install-state.json so uninstall.sh only removes what this installer created.
#
# Usage: scripts/install.sh [--agent all|claude|codex] [--force] [--copy-fallback] [--dry-run]
set -euo pipefail

AGENT='all'
FORCE=0
COPY_FALLBACK=0
DRY_RUN=0

usage() {
    sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
    case "$1" in
        --agent) AGENT="$(printf '%s' "${2:-}" | tr '[:upper:]' '[:lower:]')"; shift 2 ;;
        --agent=*) AGENT="$(printf '%s' "${1#*=}" | tr '[:upper:]' '[:lower:]')"; shift ;;
        --force) FORCE=1; shift ;;
        --copy-fallback) COPY_FALLBACK=1; shift ;;
        --dry-run|--what-if) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done
case "$AGENT" in all|claude|codex) ;; *) echo "--agent must be all, claude or codex" >&2; exit 2 ;; esac

REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
SOURCE="$REPO/skills"
MANIFEST="$REPO/.skill-install-state.json"

DESTINATIONS=()
if [ "$AGENT" = all ] || [ "$AGENT" = claude ]; then DESTINATIONS+=("$HOME/.claude/skills"); fi
if [ "$AGENT" = all ] || [ "$AGENT" = codex ]; then DESTINATIONS+=("$HOME/.agents/skills"); fi

# State records are kept as "path<TAB>source<TAB>mode" lines in memory and
# serialised to a fixed, one-object-per-line JSON layout that read_records() can parse back.
RECORDS=()
read_records() {
    [ -f "$MANIFEST" ] || return 0
    while IFS= read -r line; do
        case "$line" in *'"path"'*) ;; *) continue ;; esac
        local p s m
        p="$(printf '%s' "$line" | sed -E 's/.*"path": *"([^"]*)".*/\1/')"
        s="$(printf '%s' "$line" | sed -E 's/.*"source": *"([^"]*)".*/\1/')"
        m="$(printf '%s' "$line" | sed -E 's/.*"mode": *"([^"]*)".*/\1/')"
        RECORDS+=("$p	$s	$m")
    done < "$MANIFEST"
}
write_records() {
    {
        echo '['
        local i n="${#RECORDS[@]}"
        for ((i = 0; i < n; i++)); do
            IFS=$'\t' read -r p s m <<< "${RECORDS[$i]}"
            local sep=','
            [ "$i" -eq $((n - 1)) ] && sep=''
            printf '  {"path": "%s", "source": "%s", "mode": "%s"}%s\n' "$p" "$s" "$m" "$sep"
        done
        echo ']'
    } > "$MANIFEST"
}
drop_record() { # remove any existing record for a path
    local keep=() r
    for r in "${RECORDS[@]+"${RECORDS[@]}"}"; do
        [ "${r%%	*}" = "$1" ] || keep+=("$r")
    done
    RECORDS=("${keep[@]+"${keep[@]}"}")
}

read_records

for dest in "${DESTINATIONS[@]}"; do
    if [ ! -d "$dest" ]; then
        echo "Create directory: $dest"
        [ "$DRY_RUN" -eq 1 ] || mkdir -p "$dest"
    fi
    for skill_dir in "$SOURCE"/*/; do
        skill_dir="${skill_dir%/}"
        name="$(basename "$skill_dir")"
        if [ ! -f "$skill_dir/SKILL.md" ]; then
            echo "Missing SKILL.md: $skill_dir" >&2
            exit 1
        fi
        target="$dest/$name"
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ "$FORCE" -ne 1 ]; then
                echo "WARNING: Skipping occupied path (use --force to replace): $target" >&2
                continue
            fi
            if [ -L "$target" ]; then
                echo "Remove existing link: $target"
                [ "$DRY_RUN" -eq 1 ] || rm "$target"   # removes the link, NEVER its target
            else
                # Refuse to delete existing real directories/files, even with --force
                echo "WARNING: Refusing to replace a real path: $target (move it manually)" >&2
                continue
            fi
        fi
        mode='symlink'
        if [ "$DRY_RUN" -eq 1 ]; then
            echo "Would link $name -> $target"
            continue
        fi
        if ! ln -s "$skill_dir" "$target" 2>/dev/null; then
            if [ "$COPY_FALLBACK" -ne 1 ]; then
                echo "Cannot create symlink at $target. Check permissions, or pass --copy-fallback." >&2
                exit 1
            fi
            cp -R "$skill_dir" "$target"
            mode='copy'
            echo "WARNING: Installed copy at $target. Copies do not update automatically; re-run installer after changes." >&2
        fi
        drop_record "$target"
        RECORDS+=("$target	$skill_dir	$mode")
        echo "Installed $name -> $target ($mode)"
    done
done

[ "$DRY_RUN" -eq 1 ] || write_records
echo 'Restart Claude Code and Codex to refresh skill discovery.'
