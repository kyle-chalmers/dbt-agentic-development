# dbt Agentic Development

**Give Claude Code a dbt brain — dbt Agent Skills for conventions, dbt MCP Server for live metadata.**

> Built as part of a [KC Labs AI](https://www.youtube.com/@kclabsai) YouTube video. The video walks through the full before/after demo showing how adding dbt-specific context transforms Claude Code's output from generic SQL into convention-aware, lineage-informed dbt models.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Claude Code                          │
│                                                             │
│  ┌─────────────────────┐    ┌────────────────────────────┐  │
│  │  dbt Agent Skills   │    │     dbt MCP Server         │  │
│  │                     │    │                            │  │
│  │  - Naming rules     │    │  - DAG lineage             │  │
│  │  - ref() patterns   │    │  - Column schemas          │  │
│  │  - Test conventions │    │  - Test coverage           │  │
│  │  - Model layers     │    │  - Source definitions      │  │
│  └────────┬────────────┘    └─────────────┬──────────────┘  │
│           │    Conventions                 │  Live metadata  │
│           └──────────┬─────────────────────┘                │
│                      │                                      │
└──────────────────────┼──────────────────────────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │  jaffle_shop   │
              │  (DuckDB)      │
              │                │
              │  models/       │
              │  tests/        │
              │  sources/      │
              └────────────────┘
```

## The Problem

Claude Code writes valid SQL. But without project context, it ignores dbt conventions:

- Hardcodes table names instead of using `ref()`
- Uses generic names like `orders_customers` instead of `stg_jaffle_shop__orders`
- Skips schema YAML files and test definitions
- Doesn't know what's already built in your DAG

The result compiles — but it breaks lineage, naming patterns, and test coverage.

## The Fix

Two tools close the context gap:

| Tool | What It Provides | How It Works |
| ---- | ---------------- | ------------ |
| **dbt Agent Skills** | Conventions — naming, ref(), tests, model layers | Installs rules into Claude Code's CLAUDE.md |
| **dbt MCP Server** | Live metadata — DAG lineage, schemas, test coverage | Connects Claude Code to your dbt project at runtime |

Together, Claude Code writes dbt models that follow your project's patterns and respect existing lineage.

## Prerequisites

| Tool | Version | Purpose |
| ---- | ------- | ------- |
| Python | 3.10+ | dbt runtime |
| dbt Core | 1.9+ | Model compilation and execution |
| dbt-duckdb | 1.9+ | Local database adapter |
| Claude Code | Latest | AI coding assistant |
| Node.js | 18+ | npx for installing skills and MCP server |

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/kyle-chalmers/dbt-agentic-development.git
cd dbt-agentic-development
```

### 2. Install Python dependencies

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Initialize jaffle_shop with DuckDB

```bash
dbt init jaffle_shop
# When prompted:
#   - Which database: duckdb
#   - path: jaffle_shop.duckdb
cd jaffle_shop
dbt run
dbt test
```

### 4. Install dbt Agent Skills

```bash
npx skills add dbt-labs/dbt-agent-skills
```

This adds dbt conventions to your Claude Code configuration. Review the additions in your CLAUDE.md.

### 5. Configure dbt MCP Server

```bash
claude mcp add dbt -- npx -y @anthropic-ai/dbt-mcp@latest
```

This connects Claude Code to your dbt project's live metadata (lineage, schemas, tests).

## Demo Prompt

<details>
<summary>Click to expand the full demo prompt</summary>

```xml
<context>
  <project>jaffle_shop — dbt's canonical demo project</project>
  <adapter>DuckDB (local, zero setup)</adapter>
  <goal>Show before/after quality of Claude Code's dbt output</goal>
</context>

<before>
  <!-- Run this BEFORE installing dbt Agent Skills or MCP Server -->
  Add a staging model that joins raw orders to raw customers so we have
  customer info on each order. Include appropriate tests.
</before>

<after>
  <!-- Run this AFTER installing dbt Agent Skills + MCP Server -->
  Add a staging model that joins raw orders to raw customers so we have
  customer info on each order. Include appropriate tests.
</after>

<bonus>
  Audit the test coverage across the jaffle_shop project. Identify gaps,
  but don't re-test pass-through columns that are already tested upstream.
</bonus>
```

</details>

The full prompt with recording notes is in [`demo/demo_prompt.md`](demo/demo_prompt.md).

## Key Definitions

| Term | Definition |
| ---- | ---------- |
| **dbt Agent Skills** | A package of dbt conventions (naming, ref patterns, testing rules) that installs into Claude Code's context via `npx skills add` |
| **dbt MCP Server** | A Model Context Protocol server that gives Claude Code live access to your dbt project's DAG lineage, column schemas, and test coverage |
| **jaffle_shop** | dbt's canonical demo project — a fake e-commerce dataset with customers, orders, and payments |
| **ref()** | dbt's function for referencing other models — enables automatic lineage tracking |
| **Lineage** | The dependency graph (DAG) showing how models connect — which models feed into which |
| **DuckDB** | An in-process analytical database — runs locally with zero setup, perfect for dbt demos |

## Project Structure

```
dbt-agentic-development/
├── README.md                 # This file — overview, setup, demo prompt
├── CLAUDE.md                 # AI context for Claude Code sessions
├── .env.example              # Environment variable template
├── .gitignore                # Excludes .env, .internal/, dbt artifacts
├── requirements.txt          # dbt-core, dbt-duckdb
├── demo/
│   └── demo_prompt.md        # Full demo prompt with recording notes
├── output/                   # Before/after screenshots during recording
├── diagram.excalidraw        # Architecture overview (editable)
└── diagram.png               # Architecture overview (rendered)
```

> **Note:** jaffle_shop is NOT included in this repo. You initialize it yourself (`dbt init jaffle_shop`) during setup. This keeps the repo focused on the Claude Code + dbt tooling configuration.

## Cost

**Free.** Everything runs locally:

- DuckDB — embedded database, no server
- dbt Core — open source
- jaffle_shop — sample data included
- dbt Agent Skills — open source
- dbt MCP Server — open source

No cloud accounts, API keys, or subscriptions required.

## Resources

- [dbt Agent Skills](https://github.com/dbt-labs/dbt-agent-skills) — Convention package for AI coding assistants
- [dbt MCP Server](https://github.com/anthropic-ai/dbt-mcp) — Model Context Protocol server for dbt
- [dbt Core Documentation](https://docs.getdbt.com/) — Official dbt docs
- [jaffle_shop](https://github.com/dbt-labs/jaffle_shop) — dbt's demo project
- [DuckDB](https://duckdb.org/) — In-process analytical database
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's CLI for Claude
