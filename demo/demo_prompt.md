# Demo Prompts — dbt Agentic Development

## Overview

This demo follows a **progressive tutorial** structure. Each step builds on the previous one, walking through the full setup from installing dbt to building convention-aware models with AI context.

---

## Step 1: Install dbt and Initialize jaffle_shop

> Run these commands to set up the dbt project from scratch.

```bash
python -m venv .venv
source .venv/bin/activate
pip install dbt-core dbt-duckdb

dbt init jaffle_shop
# Choose: duckdb adapter, path: jaffle_shop.duckdb

cd jaffle_shop
dbt run
dbt test
```

**What to show:** The full installation flow, dbt init prompts, and successful `dbt run` + `dbt test` output confirming the baseline works.

---

## Step 2: Install AI Tooling

> Add dbt Agent Skills and configure the dbt MCP Server.

```bash
# Install dbt conventions into Claude Code
npx skills add dbt-labs/dbt-agent-skills

# Connect Claude Code to live project metadata
claude mcp add dbt -- npx -y @anthropic-ai/dbt-mcp@latest
```

**What to show:** Both commands running, then open CLAUDE.md to show the conventions that were added. Optionally show the MCP connection confirming in Claude Code.

---

## Step 3: Build a Model with AI Context

> Ask Claude Code to create a new staging model.

```
I'm working in the jaffle_shop dbt project with a DuckDB adapter.

Add a staging model that joins raw orders to raw customers so we have
customer info on each order. Include appropriate tests.
```

**What to show:** Claude Code generating the model with correct naming (stg_[source]__[entity]), ref() usage, and proper YAML tests. Run `dbt run` and `dbt test` on the new model to confirm it works.

---

## Step 4: Lineage-Aware Test Audit (Aha Moment)

> Ask Claude Code to audit test coverage using its lineage knowledge.

```
Audit the test coverage across the jaffle_shop project. Identify gaps
in test coverage, but don't recommend re-testing pass-through columns
that are already tested in upstream models.
```

**What to show:** Claude Code checking upstream test coverage via MCP and correctly skipping redundant tests. Highlight that it knows `customer_id` is already tested upstream.

---

## Recording Notes

- **Friction is content**: If something breaks during installation, show it. The "learning together" angle means honest setup walkthroughs, not polished after-the-fact demos.
- **Quick context, not full "before"**: When showing the model output in Step 3, briefly mention (15 seconds) what generic output would look like without these tools. No need for a full before/after comparison.
- **Multi-tool mention**: After the demo, verbally note that dbt Agent Skills also work with Cursor, Windsurf, and Codex.
- **Total demo time**: Steps 1-4 should take roughly 10-12 minutes on screen.
