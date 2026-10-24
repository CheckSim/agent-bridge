---
name: cross-agent-memory
description: Shared memory protocol between Antigravity CLI (agy) and Claude Code (claude). Ensures project decisions, architectural rules, and session handoffs are synchronized via AGENTS.md and CLAUDE.md.
---

# Cross-Agent Memory & Handoff Protocol

This skill enables persistent shared memory and bidirectional handoffs between Google Antigravity CLI (`agy`) and Anthropic Claude Code (`claude`).

## 1. Project-Level Persistent Memory (`AGENTS.md` / `CLAUDE.md`)
* Whenever working in a project repository, check if `AGENTS.md` or `CLAUDE.md` exists in the workspace root.
* If present, read it before executing tasks: it contains architectural decisions, established conventions, and context shared across both agents.
* When you make important architectural choices, refactorings, or establish new standards, record a brief note in `AGENTS.md` so that future sessions (in either `agy` or `claude`) immediately inherit that knowledge.

## 2. Session Handoff (`agy2claude` & `claude2agy`)
* The user can switch between `agy` and `claude` at any time using:
  * `agy2claude`: Transfers the current Antigravity session context into Claude Code and launches Claude.
  * `claude2agy`: Transfers the current Claude Code session context into Antigravity CLI and launches Antigravity.
  * `agent-status`: Displays the latest session status of both agents for the current workspace.
* When receiving a handoff prompt starting with `[CROSS-AGENT HANDOFF ...]`, acknowledge the context briefly, summarize the current task status, and ask the user how to proceed.
