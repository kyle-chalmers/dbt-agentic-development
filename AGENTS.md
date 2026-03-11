# AI Agent Instructions: dbt Agentic Development

> IMPORTANT: Everything in this repo is public-facing, so do not place any sensitive info here and make sure to distinguish between what should be internal-facing info (e.g. secrets, PII, recording guides/scripts), and public-facing info (instructions, how-to guides, actual code utilized). If there is information that Claude Code and other AI tools needs across sessions but should not be published, put it in the `.internal/` folder which is ignored by git per the `.gitignore`.

## Project Overview

This is a demo repository for a **KC Labs AI YouTube video** — a practical setup tutorial showing how to use AI coding assistants with dbt, from installing dbt through building convention-aware, lineage-informed models.

**Audience**: Analytics engineers, data professionals, and developers using dbt
**Demo Subject**: Full setup guide for dbt Agent Skills + dbt MCP Server with Claude Code
**Demo Project**: jaffle_shop (dbt's canonical demo project) with DuckDB adapter

> **Claude Code**: If `.internal/OWNER_CONFIG.md` exists, read it at the start of each session and use those concrete values (org URLs, resource names, emails) for all commands.
>
> **Viewers cloning this repo**: Create your own `.internal/OWNER_CONFIG.md` with your personal values (DevOps org, project, email). Then follow the README setup steps to install dbt and the AI tooling.

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
claude mcp add dbt -e DBT_PROJECT_DIR=$(pwd) -e DBT_PATH=$(which dbt) -- uvx dbt-mcp
```

What it provides:
- Live DAG lineage (which models depend on which)
- Column-level schema info (names, types, descriptions)
- Existing test coverage (what's already tested)
- Source definitions and freshness
- Project configuration and variables
- dbt CLI tools (run, test, compile, list, build, show, parse)
- Codegen tools (generate model YAML, source YAML, staging models)

> **Important:** If the MCP server only exposes docs tools, it can't find the dbt project or binary. Set both `DBT_PROJECT_DIR` (absolute path to the directory containing `dbt_project.yml`) and `DBT_PATH` (output of `which dbt`) in `.mcp.json`. Both are required for the CLI and codegen tools to load — the server does not auto-discover either.

#### CLI vs MCP: Output Comparison

| Capability | dbt CLI | dbt MCP Server |
| ---------- | ------- | -------------- |
| Run / test / build | Streams full log — per-model status, timing, PASS/WARN/ERROR counts | Returns `"OK"` |
| List resources | `dbt ls` → flat FQN strings | `mcp__dbt__list` → same flat FQN strings |
| Compile SQL | `dbt compile` → **prints rendered SQL** | `mcp__dbt__compile` → returns `"OK"` |
| Preview data | `dbt show` → formatted table | `mcp__dbt__show` → structured JSON |
| Column schemas + tests | Requires parsing `target/manifest.json` (partial) | `get_node_details_dev` → full structured JSON per node |
| DAG lineage | `dbt ls --output json` → flat NDJSON, reconstruct graph manually | `get_lineage_dev` → nested parent/child graph |
| dbt docs search | No CLI equivalent | `search_product_docs` |

#### When to Use CLI vs MCP

Both are available at all times. Choose based on what gives better results:

| Use CLI when… | Use MCP when… |
| ------------- | ------------- |
| Inspecting compiled SQL (`dbt compile` prints it; MCP just returns `"OK"`) | Querying lineage (`get_lineage_dev` returns a nested graph; CLI returns a flat list) |
| Diagnosing run/test failures (CLI streams per-model status, timing, PASS/WARN/ERROR counts; MCP returns `"OK"`) | Looking up column schemas, data types, or test coverage for a specific model (`get_node_details_dev`) |
| Listing resources — output is identical either way | Searching dbt product docs (`search_product_docs` — no CLI equivalent) |

#### MCP Fallback

If the MCP server is unavailable or not responding, fall back to equivalent dbt CLI commands:

| MCP Tool | CLI Fallback | Notes |
| -------- | ------------ | ----- |
| `mcp__dbt__run` | `dbt run --select <model>` | |
| `mcp__dbt__test` | `dbt test --select <model>` | |
| `mcp__dbt__build` | `dbt build --select <model>` | |
| `mcp__dbt__compile` | `dbt compile --select <model>` | CLI actually prints rendered SQL — more useful for inspection |
| `mcp__dbt__list` | `dbt ls` | Identical output |
| `mcp__dbt__show` | `dbt show --select <model> --limit N` | CLI output is a formatted table, not JSON |
| `mcp__dbt__parse` | `dbt parse` | CLI is silent on success |
| `get_node_details_dev` | `dbt ls --select <model> --output json --output-keys unique_id name resource_type columns depends_on config` | Partial — missing descriptions, data_type, patch_path, tests list |
| `get_lineage_dev` | `dbt ls --select +<model>+ --output json --output-keys unique_id name resource_type depends_on` | Returns flat NDJSON — reconstruct graph from `depends_on.nodes`; no children direction |
| `search_product_docs` | No CLI equivalent | Use web search |

> **Note:** CLI fallbacks for `get_node_details_dev` and `get_lineage_dev` return partial or unstructured data. Lineage-aware and metadata-heavy tasks (e.g. test coverage audits) are less reliable without MCP.

### DuckDB

- In-process analytical database — no server to install or manage
- Configured via `profiles.yml` (created during `dbt init`)
- Database file: `dev.duckdb` (auto-created in project directory)

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

The demo follows a progressive tutorial structure — each step builds on the previous one:

1. **What + Why** — Quick overview of dbt Agent Skills (conventions) and dbt MCP Server (live metadata), and why both matter together
2. **Install dbt** — `pip install dbt-core dbt-duckdb`
3. **Confirm Baseline** — `dbt run` + `dbt test` from repo root to verify jaffle_shop works
4. **Install dbt Agent Skills** — `npx skills add dbt-labs/dbt-agent-skills` — show what gets added to CLAUDE.md
5. **Configure dbt MCP Server** — `claude mcp add dbt -- uvx dbt-mcp` — show what metadata becomes available
6. **Build with AI Context** — Ask Claude Code to add a staging model — show convention-aware output (correct naming, ref(), proper tests)
7. **Lineage-Aware Test Audit + Enhancement** — Audit test coverage with lineage awareness, implement missing tests, then propose and build a meaningful enhancement using the new columns

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
