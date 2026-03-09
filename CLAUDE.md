# Claude Code Instructions: dbt Agentic Development

> IMPORTANT: Everything in this repo is public-facing, so do not place any sensitive info here and make sure to distinguish between what should be internal-facing info (e.g. secrets, PII, recording guides/scripts), and public-facing info (instructions, how-to guides, actual code utilized). If there is information that Claude Code needs across sessions but should not be published, put it in the `.internal/` folder which is ignored by git per the `.gitignore`.

## Project Overview

This is a demo repository for a **KC Labs AI YouTube video** showing how dbt Agent Skills and dbt MCP Server transform Claude Code's dbt output quality — from generic SQL to convention-aware, lineage-informed models.

**Audience**: Analytics engineers, data professionals, and developers using dbt
**Demo Subject**: Before/after comparison of Claude Code writing dbt models with vs. without agentic context (dbt Agent Skills + dbt MCP Server)
**Demo Project**: jaffle_shop (dbt's canonical demo project) with DuckDB adapter

> **Claude Code**: If `.internal/OWNER_CONFIG.md` exists, read it at the start of each session and use those concrete values (org URLs, resource names, emails) for all commands.
>
> **Viewers cloning this repo**: Create your own `.internal/OWNER_CONFIG.md` with your personal values (DevOps org, project, email). Then follow the README setup steps to initialize jaffle_shop and install the dbt tooling.

## Available Tools

### dbt CLI

- **Run models**: `dbt run` (all models) or `dbt run --select model_name`
- **Run tests**: `dbt test` (all tests) or `dbt test --select model_name`
- **Generate docs**: `dbt docs generate`
- **Serve docs**: `dbt docs serve` (opens browser with DAG visualization)
- **List resources**: `dbt ls` (list all models, tests, sources)
- **Compile SQL**: `dbt compile --select model_name` (render Jinja without executing)
- **Adapter**: DuckDB (runs locally, zero database setup)

### dbt Agent Skills

Installs dbt-specific conventions and patterns into Claude Code's CLAUDE.md:

```bash
npx skills add dbt-labs/dbt-agent-skills
```

What it provides:
- Naming conventions (e.g., `stg_[source]__[entity]`, `int_[entity]_[verb]`, `fct_[entity]`, `dim_[entity]`)
- ref() and source() usage patterns
- Test patterns (unique, not_null, relationships, accepted_values)
- YAML schema file conventions
- Model organization (staging → intermediate → marts)

### dbt MCP Server

Connects Claude Code to live dbt project metadata:

```bash
claude mcp add dbt -- npx -y @anthropic-ai/dbt-mcp@latest
```

What it provides:
- Live DAG lineage (which models depend on which)
- Column-level schema info (names, types, descriptions)
- Existing test coverage (what's already tested)
- Source definitions and freshness
- Project configuration and variables

### DuckDB

- In-process analytical database — no server to install or manage
- Configured via `profiles.yml` (created during `dbt init`)
- Database file: `jaffle_shop.duckdb` (auto-created in project directory)

### Azure DevOps (Ticket Tracking)

- **az boards**: Create and manage work items
  - Always include `--org "$AZURE_DEVOPS_ORG" --project "$AZURE_DEVOPS_PROJECT"`
  - State lifecycle: `To Do` → `Doing` → `Done`
  - If ticket tracking is unavailable, note it and continue

## dbt Conventions

### Naming

| Layer | Pattern | Example |
| ----- | ------- | ------- |
| Staging | `stg_[source]__[entity]` | `stg_jaffle_shop__orders` |
| Intermediate | `int_[entity]_[verb]` | `int_orders_pivoted` |
| Marts (fact) | `fct_[entity]` | `fct_orders` |
| Marts (dimension) | `dim_[entity]` | `dim_customers` |

### ref() Pattern

Always use `{{ ref('model_name') }}` — never hardcode table names:

```sql
-- Correct
SELECT * FROM {{ ref('stg_jaffle_shop__orders') }}

-- Wrong
SELECT * FROM jaffle_shop.stg_jaffle_shop__orders
```

### Testing

- Every model should have a `.yml` schema file with at least `unique` and `not_null` on primary keys
- Use `relationships` tests for foreign keys
- Use `accepted_values` for enum/status columns
- Don't test pass-through columns that are already tested upstream

### Model Organization

```
models/
├── staging/           # 1:1 with source tables, light transformations
│   ├── stg_jaffle_shop__customers.sql
│   └── _stg_jaffle_shop.yml
├── intermediate/      # Business logic joins, reshaping
│   └── int_orders_pivoted.sql
└── marts/             # Final business entities
    ├── dim_customers.sql
    └── fct_orders.sql
```

## Environment Configuration

| Variable | Required | Description |
| -------- | -------- | ----------- |
| `DBT_PROFILES_DIR` | No | Custom `profiles.yml` location (default: `~/.dbt/`) |

No cloud credentials needed — DuckDB runs entirely local.

## Demo Flow

The demo follows a before/after structure showing Claude Code's dbt output quality:

0. **Create Ticket** — Azure DevOps work item to track the demo build
1. **Initialize jaffle_shop** — `dbt init jaffle_shop` with DuckDB adapter, run `dbt run` + `dbt test` to establish baseline
2. **Baseline Confirmed** — Show jaffle_shop models running and passing tests
3. **BEFORE: Ask Claude Code to Add a Model** — "Add a staging model that joins orders to customers" — capture output WITHOUT dbt context (generic SQL, wrong naming, no ref(), no tests)
4. **Install dbt Agent Skills** — `npx skills add dbt-labs/dbt-agent-skills` — show what gets added to CLAUDE.md
5. **Configure dbt MCP Server** — `claude mcp add dbt -- npx -y @anthropic-ai/dbt-mcp@latest` — show what metadata becomes available
6. **AFTER: Same Prompt WITH Context** — Exact same request — capture output WITH dbt Agent Skills + MCP Server (correct naming, ref(), proper tests, lineage-aware)
7. **Bonus: Lineage-Aware Test Audit** — "Audit test coverage — don't re-test pass-through columns already tested upstream"
8. **Close Ticket** — Update work item to Done with summary

## Operating Principles

### Show Your Reasoning

- Announce intent before action — say what you're about to do and why
- Show the actual dbt commands being run — don't execute silently
- Explain design choices briefly so the audience understands *why*, not just *what*
- Example: "Using ref() instead of hardcoded table names so dbt tracks lineage automatically"

### Verify Your Work

- After every `dbt run`, confirm models compiled and ran successfully
- After every `dbt test`, confirm all tests passed
- After creating a model, verify it appears in `dbt ls`
- If results look wrong or tests fail, flag it immediately

### Keep It Reviewable

- Every model and test should be readable by a colleague in under 30 seconds
- Prefer structured output (tables, bullet points) over prose
- One model per file — follow dbt's single-responsibility pattern

### Handle Failures Gracefully

- When a dbt command fails, explain what happened in one sentence and fix it
- Don't retry the same failing command endlessly — diagnose, fix, move on
- If a non-critical step fails (e.g., ticket tracking), skip it and continue

### Protect Sensitive Data

- Never print credentials or API keys in terminal output
- Use environment variables for all secrets
- `profiles.yml` is gitignored — it may contain database credentials
