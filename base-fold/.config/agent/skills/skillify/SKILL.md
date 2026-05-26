---
name: skillify
description: Convert a freshly completed task or described workflow into a reusable skill. Use when the user invokes $skillify, asks to create a skill from the current process, wants generic repeatable steps captured, or requests a skill with optional name/destination clauses such as "$skillify as Spec to English in ~/.agent_skills" or "$skillify in projectname".
---

# Skillify

Use this skill to turn a completed or described workflow into a reusable skill folder. The default output location is adjacent to this `skillify` skill. If the user provides `as <NAME>` or `in <DIRECTORY>`, infer the intended name or destination from natural language and honor it.

## Workflow

1. Infer the skill name and destination from the user's request.
2. If there is no explicit name, infer a concise hyphen-case name from the workflow. Prefer action-oriented names under 64 characters.
3. If there is no explicit destination, create the new skill adjacent to this `skillify` skill; use the parent directory of the loaded `skillify/SKILL.md`.
4. Identify concrete examples from the just-completed task or the user's description. If the source workflow is ambiguous, ask one concise clarifying question.
5. Decompose the workflow into generic, repeatable steps.
6. Classify each step:
   - LLM-suited: translation, judgment, synthesis, naming, prioritization, visual QA, or context-specific choices.
   - Script-suited: deterministic parsing, extraction, rendering, file transforms, validation, API calls with stable parameters, and repetitive boilerplate.
7. Create the destination skill folder. Prefer the system `skill-creator` initializer when available. If it is not available or is blocked, use:

```bash
python <skill-dir>/scripts/create_skill_skeleton.py <skill-name> --path <destination> --resources scripts
```

8. Author scripts for the script-suited steps first. Keep scripts parameterized, deterministic, and runnable without loading large context.
9. Write `SKILL.md` with concise frontmatter and body instructions. Include when to invoke each script, where LLM judgment is required, and validation steps.
10. Add `agents/openai.yaml` with `display_name`, `short_description`, and a `default_prompt` that explicitly mentions `$<skill-name>`.
11. Run script smoke tests and validate the skill:

```bash
python <skill-creator-dir>/scripts/quick_validate.py <destination>/<skill-name>
```

If `quick_validate.py` is unavailable, at minimum verify `SKILL.md` has valid YAML frontmatter with `name` and `description`, and the folder name matches the skill name.

## Destination Rules

- No `in` clause: create the skill adjacent to this `skillify` skill, meaning in the same parent directory as the loaded `skillify` folder.
- Absolute or `~` path: use that directory.
- Relative path containing `/`: resolve from the current working directory.
- Bare names such as `projectname`: infer the intended skill directory from the user's active workspace and known local conventions. Do not assume a fixed folder name such as `agent_skills`; inspect or ask if the destination is ambiguous.

## Quality Bar

- Do not encode one-off facts as universal instructions.
- Do not put generated reports, README files, changelogs, or process notes in the skill.
- Keep the skill lean; move only reusable deterministic code into `scripts/`.
- Test every new script with representative inputs before finishing.
