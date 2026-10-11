#!/usr/bin/env python3
"""Validate all skills without third-party dependencies. Run: python scripts/validate.py"""
from pathlib import Path
import re
import sys
ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / 'skills'
REQUIRED = {'fastapi-code-review', 'python-code-review', 'repository-explorer', 'system-design-review', 'ai-pipeline-review'}
SLUG = re.compile(r'^[a-z][a-z0-9-]*$')

def validate() -> list[str]:
    errors = []
    names = set()
    for folder in sorted(SKILLS.iterdir()):
        if not folder.is_dir():
            continue
        skill = folder / 'SKILL.md'
        if not skill.is_file():
            errors.append(f'{folder.name}: SKILL.md missing')
            continue
        text = skill.read_text(encoding='utf-8-sig')
        if not text.startswith('---\n'):
            errors.append(f'{folder.name}: missing YAML frontmatter')
            continue
        parts = text.split('---\n', 2)
        if len(parts) != 3:
            errors.append(f'{folder.name}: unterminated YAML frontmatter')
            continue
        fields = {}
        for line in parts[1].splitlines():
            if line.strip() and not line.startswith((' ', '#')):
                match = re.fullmatch(r'([a-zA-Z_][a-zA-Z0-9_-]*):\s*(.*)', line)
                if match:
                    fields[match.group(1)] = match.group(2).strip().strip('"\'')
        name = fields.get('name', '')
        desc = fields.get('description', '')
        if name != folder.name or not SLUG.fullmatch(name):
            errors.append(f'{folder.name}: name must match kebab-case directory')
        if name in names:
            errors.append(f'{folder.name}: duplicate name')
        names.add(name)
        if not desc or len(desc) > 1024:
            errors.append(f'{folder.name}: description required, <=1024 chars')
        if len(parts[2].strip()) < 150:
            errors.append(f'{folder.name}: instructions too short')
        if len(text) > 100_000:
            errors.append(f'{folder.name}: SKILL.md >100KB; split references')
        print(f'CHECK {folder.name}: {len(text)} characters')
    for missing in sorted(REQUIRED - names):
        errors.append(f'Missing required skill: {missing}')
    return errors

if __name__ == '__main__':
    issues = validate()
    if issues:
        for issue in issues:
            print('ERROR:', issue, file=sys.stderr)
        sys.exit(1)
    print('PASS: all skill manifests validated')
