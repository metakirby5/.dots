#!/usr/bin/env python3
"""Create a minimal skill skeleton."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


def progress(message: str) -> None:
    print(f"[progress] {message}", file=sys.stderr, flush=True)


def normalize_name(value: str) -> str:
    normalized = re.sub(r"[^A-Za-z0-9]+", "-", value.lower()).strip("-")
    if not normalized:
        raise ValueError("Skill name cannot be empty")
    if len(normalized) > 63:
        normalized = normalized[:63].rstrip("-")
    return normalized


def title_from_name(value: str) -> str:
    return " ".join(part.capitalize() for part in normalize_name(value).split("-"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("name", help="Skill name or display title.")
    parser.add_argument("--path", type=Path, required=True, help="Directory that will contain the skill folder.")
    parser.add_argument("--resources", default="", help="Comma-separated resource dirs: scripts,references,assets.")
    parser.add_argument("--display-name")
    parser.add_argument("--short-description", default="Reusable workflow")
    parser.add_argument("--default-prompt")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    skill_name = normalize_name(args.name)
    display_name = args.display_name or title_from_name(skill_name)
    destination = args.path.expanduser().resolve()
    skill_dir = destination / skill_name
    progress(f"Creating skill skeleton at {skill_dir}")
    if skill_dir.exists() and not args.force:
        raise FileExistsError(f"{skill_dir} already exists; pass --force to update the skeleton")
    skill_dir.mkdir(parents=True, exist_ok=True)
    (skill_dir / "agents").mkdir(exist_ok=True)

    description = "[TODO: Describe what this skill does and exactly when to use it.]"
    skill_md = f"""---
name: {skill_name}
description: {description}
---

# {display_name}

## Overview

[TODO: Explain the repeatable task this skill enables in 1-2 sentences.]

## Workflow

1. [TODO: Add the first step.]
2. [TODO: Add the next step.]

## Scripts

[TODO: List deterministic scripts and when to invoke them, or delete this section.]
"""
    (skill_dir / "SKILL.md").write_text(skill_md, encoding="utf-8")

    default_prompt = args.default_prompt or f"Use ${skill_name} to complete this repeatable workflow."
    openai_yaml = f"""interface:
  display_name: "{display_name}"
  short_description: "{args.short_description}"
  default_prompt: "{default_prompt}"
"""
    (skill_dir / "agents" / "openai.yaml").write_text(openai_yaml, encoding="utf-8")

    for resource in [r.strip() for r in args.resources.split(",") if r.strip()]:
        if resource not in {"scripts", "references", "assets"}:
            raise ValueError(f"Unknown resource directory: {resource}")
        progress(f"Creating resource directory: {resource}")
        (skill_dir / resource).mkdir(exist_ok=True)

    progress("Skill skeleton ready")
    print(skill_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
