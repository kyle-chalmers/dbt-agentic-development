# Demo Prompts — dbt Agentic Development

## Overview

This demo follows a **progressive tutorial** structure. Each step builds on the previous one, walking through the full setup from installing dbt to building convention-aware models with AI context.

---

## Step 1: Install dbt and Verify the Project

> Clone the repo and install dbt. The jaffle_shop project is already included at the repo root.

```bash
git clone https://github.com/kyle-chalmers/dbt-agentic-development.git
cd dbt-agentic-development

python3 -m venv .venv
source .venv/bin/activate
pip install dbt-core dbt-duckdb

dbt run
dbt test
```

**What to show:** The installation flow and successful `dbt run` + `dbt test` output confirming the baseline works.

---

## Step 2: Install AI Tooling

> Add dbt Agent Skills and configure the dbt MCP Server.

```bash
# Install dbt conventions into Claude Code
npx skills add dbt-labs/dbt-agent-skills

# Connect Claude Code to live project metadata
claude mcp add dbt -e DBT_PROJECT_DIR=$(pwd) -e DBT_PATH=$(which dbt) -- uvx dbt-mcp
```

**What to show:** Both commands running, then open CLAUDE.md to show the conventions that were added. Optionally show the MCP connection confirming in Claude Code.

---

## Step 3: Build a Model with AI Context

> Ask Claude Code to create a new staging model.

```
I'm working in the jaffle_shop dbt project with a DuckDB adapter.

Add a staging model that joins raw orders to raw customers so we have
customer info on each order. Include appropriate tests and run them yourself. Report back to me the findings.
```

**What to show:** Claude Code generating the model with correct naming (stg_[source]__[entity]), ref() usage, and proper YAML tests. Run `dbt run` and `dbt test` on the new model to confirm it works.

---

## Step 4: Lineage-Aware Test Audit (Aha Moment)

> Ask Claude Code to audit test coverage using its lineage knowledge.

```
Audit the test coverage across the jaffle_shop project.
For each model, use lineage to check what's already tested in upstream models.
Don't re-test pass-through columns that are already covered.
Show me which tests exist upstream so I can see you've checked.
Then implement the missing tests where genuine gaps exist.
Finally, based on the new data now available (amounts, payment methods, countries),
suggest and build one meaningful enhancement, such as a mart model with revenue
aggregation or customer segmentation, that wasn't possible before.
```

**What to show:** Claude surfacing which columns are already tested upstream (lineage awareness made visible), implementing only the genuine gaps, then proposing and building a concrete enhancement — such as `fct_orders` with revenue aggregation or `dim_customers` with country segmentation.

---

