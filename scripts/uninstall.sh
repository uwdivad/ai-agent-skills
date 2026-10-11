#!/usr/bin/env bash
# Remove skill symlinks recorded by scripts/install.sh on macOS/Linux.
# Mirrors scripts/uninstall.ps1: only recorded symlinks whose target still points at this
# clone are removed. Copies and real directories are never deleted.
#
# Usage: scripts/uninstall.sh [--agent all|claude|codex] [--dry-run]
set -euo pipefail

AGENT='all'
DRY_RUN=0

usage() {
    sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
    case "$1" in
        --agent) AGENT="$(printf '%s' "${2:-}" | tr '[:upper:]' '[:lower:]')"; shift 2 ;;
        --agent=*) AGENT="$(printf '%s' "${1#*=}" | tr '[:upper:]' '[:lower:]')"; shift ;;
        --dry-run|--what-if) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done
case "$AGENT" in all|claude|codex) ;; *) echo "--agent must be all, claude or codex" >&2; exit 2 ;; esac

REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
MANIFEST="$REPO/.skill-install-state.json"
CLAUDE_ROOT="$HOME/.claude/skills/"
CODEX_ROOT="$HOME/.agents/skills/"

if [ ! -f "$MANIFEST" ]; then
    echo 'Nothing recorded for uninstall.'
    exit 0
fi

REMAINING=()
while IFS= read -r line; do
    case "$line" in *'"path"'*) ;; *) continue ;; esac
    path="$(printf '%s' "$line" | sed -E 's/.*"path": *"([^"]*)".*/\1/')"
    source="$(printf '%s' "$line" | sed -E 's/.*"source": *"([^"]*)".*/\1/')"
    mode="$(printf '%s' "$line" | sed -E 's/.*"mode": *"([^"]*)".*/\1/')"
    record="$path	$source	$mode"

    is_claude=0; is_codex=0
    case "$path" in "$CLAUDE_ROOT"*) is_claude=1 ;; esac
    case "$path" in "$CODEX_ROOT"*) is_codex=1 ;; esac
    if { [ "$AGENT" = claude ] && [ "$is_claude" -ne 1 ]; } || { [ "$AGENT" = codex ] && [ "$is_codex" -ne 1 ]; }; then
        REMAINING+=("$record"); continue
    fi

    if [ ! -e "$path" ] && [ ! -L "$path" ]; then
        continue   # already gone; drop the record
    fi
    if [ "$mode" != symlink ] || [ ! -L "$path" ]; then
        echo "WARNING: Not removing non-symlink entry: $path (remove manually if desired)" >&2
        REMAINING+=("$record"); continue
    fi
    actual="$(readlink "$path")"
    if [ -z "$actual" ] || [ "${actual%/}" != "${source%/}" ]; then
        echo "WARNING: Link target changed; not removing: $path" >&2
        REMAINING+=("$record"); continue
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would unlink $path"
        REMAINING+=("$record")
    else
        rm "$path"   # removes the link, NEVER its target
        echo "Unlinked $path"
    fi
done < "$MANIFEST"

if [ "$DRY_RUN" -eq 1 ]; then
    exit 0
fi
{
    echo '['
    n="${#REMAINING[@]}"
    for ((i = 0; i < n; i++)); do
        IFS=$'\t' read -r p s m <<< "${REMAINING[$i]}"
        sep=','
        [ "$i" -eq $((n - 1)) ] && sep=''
        printf '  {"path": "%s", "source": "%s", "mode": "%s"}%s\n' "$p" "$s" "$m" "$sep"
    done
    echo ']'
} > "$MANIFEST"
