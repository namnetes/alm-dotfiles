# Claude Instructions — Python & Bash

## Package Manager

- Always use `uv`. Never suggest `pip` or `poetry`.
- Setup: `uv sync`
- Add dependency: `uv add <package>`
- Run script: `uv run <script.py>`
- Run tests: `uv run pytest`
- Lint/fix: `uv run ruff check . --fix`

## Python Standards

- Python version: **3.12+**.
- Line length: **88 characters** maximum (Ruff/Black style).
- Type hints required on **all** function and method signatures (parameters
  and return type).
- f-strings for all string formatting; no `%` formatting, no `.format()`.
- `pathlib.Path` for all file-system paths; never `os.path`.
- `logging` module for all output in production code; `print()` only in
  one-off scripts or CLI entry points.
- Specific exceptions only — never bare `except:` or `except Exception:`.

### Python Naming conventions

| Element                 | Convention            | Example                         |
| ----------------------- | --------------------- | ------------------------------- |
| Variable / function     | `snake_case`          | `record_count`, `read_csv_file` |
| Class                   | `PascalCase`          | `CsvReader`, `SortKey`          |
| Constant (module-level) | `UPPER_SNAKE_CASE`    | `DEFAULT_DELIMITER`             |
| Private helper          | `_leading_underscore` | `_parse_header`                 |

### Documentation — accessibility first

**Goal: every source file must be readable and understandable by a beginner
with no prior context.** Assume the reader knows Python basics but nothing
about the business domain.

#### Module docstring (mandatory on every `.py` file)

```python
"""
Short one-line summary of what this module does.

Longer description if needed: explain the purpose, the inputs it expects,
the outputs it produces, and any important limitation or assumption.

Example:
    uv run script.py --input data/customers.csv
"""
```

#### Function / method docstring — Google Style

Mandatory on all public functions; strongly recommended on private helpers
> 5 lines.

```python
def compute_balance(
    debit: Decimal,
    credit: Decimal,
    initial: Decimal = Decimal("0"),
) -> Decimal:
    """Calculate the net balance after applying debit and credit.

    Positive result means credit exceeds debit. The function does not
    raise on negative balances — callers must validate the result if
    a negative balance is not allowed in the business context.

    Args:
        debit: Total amount debited (must be >= 0).
        credit: Total amount credited (must be >= 0).
        initial: Starting balance before this transaction. Defaults to 0.

    Returns:
        Net balance as a Decimal: initial + credit - debit.

    Raises:
        ValueError: If debit or credit is negative.
    """
```

Rules:

- `Args` section required as soon as there is at least one parameter.
- `Returns` section required unless the function returns `None`.
- `Raises` section required for every exception the function can raise.
- Write in plain, jargon-free language. Spell out abbreviations on first use.
- Include a short usage `Example:` block for any non-trivial public function.

#### Inline comments

- Use inline comments **only** for logic that is not self-evident from the
  code itself — explain _why_, not _what_.
- Write in complete sentences, starting with a capital letter.
- Keep them short; if an explanation needs more than 2 lines, move it to
  the docstring.

```python
# Good — explains a non-obvious business rule
credit_limit = base_limit * 1.10  # 10 % grace margin per policy ref. FIN-42

# Bad — restates the code
credit_limit = base_limit * 1.10  # multiply base_limit by 1.10
```

## Shell / Bash Standards

- Line length: **80 characters** maximum.
- Always start scripts with `set -euo pipefail`.
- Use `\` for line continuation to respect the 80-char limit.

## Data Handling (FR locale)

- CSV delimiter: `;` (semicolon).
- Encoding: UTF-8.
- Always specify `sep=';'` or `delimiter=';'` in Pandas/Polars IO calls.
- Use `.` as decimal separator for raw data.
