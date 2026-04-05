# 🌍 Global Engineering Standards (CLAUDE.md)

## 🎯 Project Overview

Strict production standards for DevOps and Data Science tooling, optimized for the French ecosystem. This guide applies by default to all projects handled via Claude Code CLI or Zed.

## 🗣 Language & Writing Style

- **Default Language**: All interactions, explanations, and responses must be in **French** (Français) unless explicitly requested otherwise.
- **Tone & Vocabulary**: Use a professional yet accessible vocabulary. Avoid overly simplistic terms as well as overly formal or literary language. The goal is technical efficiency, not literature.
- **Ethics**: All content must remain **politically correct** and professional at all times.
- **Code/Docs**: Technical content (code, variable names, docstrings, git commits) remains in **English** as per industry standards.

## 🛠 Command Palette (Modern Tooling)

Claude must prioritize `uv` to ensure performance and isolation:

- **Environment**: `uv sync` (preferred), or `uv venv` + `source .venv/bin/activate`.
- **Execution**: `uv run <script.py>` (preferred method for isolation).
- **Dependencies**: `uv add <package>`, `uv remove <package>`.
- **Quality**: `uv run ruff check . --fix` && `uv run pytest`.

## 📏 Coding Standards (Enforced)

### 🐍 Python (PEP 8 Enhanced)

- **Package Manager**: Always use `uv`. Never use `pip` or `poetry`.
- **Line Length**: Strictly **88 characters** maximum (Black/Ruff style).
- **Type Hinting**: Required for all function signatures.
- **Docstrings**: Google Style (Napoleon).

### 🐚 Shell (Bash/SH) & C

- **Line Length**: Strictly **80 characters** maximum.
- **Safety (Bash)**: Always use `set -euo pipefail`.
- **Formatting**: Use `\` for multi-line commands to maintain the 80-char limit.

### 📊 Data Handling (Localization: FR)

- **CSV Format**: Default delimiter is `;` (semicolon).
- **Encoding**: Mandatory UTF-8.
- **IO Functions**: Always specify `sep=';'` or `delimiter=';'` (Pandas/Polars).
- **Numbers**: Use `.` for raw data. Use `,` only if a final "FR" report is explicitly requested.

## 🖼 Visuals & Documentation

### 🧜‍♂️ Diagrams (Mermaid.js v10+)

- **Structures**:
  - `flowchart TD`: Vertical workflows, decision logic, algorithms.
  - `flowchart LR`: Data pipelines, linear ETL flows.
  - `sequenceDiagram`: API interactions and inter-module exchanges.
- **Shapes (flowchart)**:
  - `([ ... ])`: Start/End of program or function.
  - `[[ ... ]]`: External function call or sub-routine.
  - `[/ ... /]`: Data or file Input/Output (I/O).
  - `{ ... }`: Conditional branching (if, while, switch).
- **Error Handling**: Explicitly trace error exits (exit 1, raise) to a styled `error` node.
- **Color Palette (classDef)**:
  - `classDef startStop fill:#e1f5fe,stroke:#01579b` (Green/Blue: Success)
  - `classDef error fill:#ffebee,stroke:#c62828` (Pale Red: Error)
  - `classDef logic fill:#e8eaf6,stroke:#1a237e` (Lavender Blue: Process)
  - `classDef data fill:#fff3e0,stroke:#e65100` (Pale Orange: I/O)
- **Application**: Every node must receive its class (inline `:::className` or block). Always include a `title:` at the top of the block.

## 🧠 Smart Workflow

1. **Analyze**: Always read `pyproject.toml` (source of truth) before modifying code.
2. **Autonomy**: If `ruff` or `pytest` fails, analyze the error, fix it, and re-run automatically.
3. **Plan**: Propose an action plan if > 3 files are impacted or architecture changes.
4. **Git**: Commit messages in Conventional Commits format (`feat:`, `fix:`, `docs:`, `style:`).

## 📂 Architecture Note (Standard)

- `/src`: Main source code.
- `/scripts`: Automation scripts (Max 80 chars/line).
- `/data`: CSV files (Semicolon delimited).
