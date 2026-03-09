# Demo Prompt — dbt Agentic Development

## Overview

This demo follows a before/after structure. The **exact same prompt** is given to Claude Code twice:

1. **Before** — No dbt Agent Skills, no dbt MCP Server installed
2. **After** — Both tools installed and configured

The difference in output quality makes the argument.

---

## Before Prompt (Without Context)

> Run this in a fresh Claude Code session with NO dbt Agent Skills or MCP Server configured.

```
I'm working in the jaffle_shop dbt project with a DuckDB adapter.

Add a staging model that joins raw orders to raw customers so we have
customer info on each order. Include appropriate tests.
```

**What to capture:** Screenshot the generated model file(s), YAML, and tests. Note naming conventions, whether ref() is used, and test coverage.

---

## After Prompt (With Context)

> Run this AFTER installing dbt Agent Skills (`npx skills add dbt-labs/dbt-agent-skills`) and configuring dbt MCP Server (`claude mcp add dbt`).

```
I'm working in the jaffle_shop dbt project with a DuckDB adapter.

Add a staging model that joins raw orders to raw customers so we have
customer info on each order. Include appropriate tests.
```

**What to capture:** Screenshot the same outputs. Compare naming, ref() usage, YAML structure, test patterns, and lineage awareness against the "before" output.

---

## Bonus Prompt (Lineage-Aware Test Audit)

> Run this after the "after" prompt to show deeper lineage awareness.

```
Audit the test coverage across the jaffle_shop project. Identify gaps
in test coverage, but don't recommend re-testing pass-through columns
that are already tested in upstream models.
```

**What to capture:** Screenshot the audit output. Highlight that it respects existing upstream tests instead of blindly adding redundant coverage.

---

## XML Prompt (Combined)

For reference, here's the structured XML version used in the video brief:

```xml
<context>
  <project>jaffle_shop — dbt's canonical demo project</project>
  <adapter>DuckDB (local, zero setup)</adapter>
  <goal>Show before/after quality of Claude Code's dbt output</goal>
</context>

<before>
  <!-- Run this BEFORE installing dbt Agent Skills or MCP Server -->
  I'm working in the jaffle_shop dbt project with a DuckDB adapter.

  Add a staging model that joins raw orders to raw customers so we have
  customer info on each order. Include appropriate tests.
</before>

<after>
  <!-- Run this AFTER installing dbt Agent Skills + MCP Server -->
  I'm working in the jaffle_shop dbt project with a DuckDB adapter.

  Add a staging model that joins raw orders to raw customers so we have
  customer info on each order. Include appropriate tests.
</after>

<bonus>
  Audit the test coverage across the jaffle_shop project. Identify gaps,
  but don't re-test pass-through columns that are already tested upstream.
</bonus>
```
