---
name: react-doctor
description: Run an automated React/Next.js codebase health audit using the react-doctor CLI. Returns a 0–100 health score plus file-level diagnostics across performance, security, architecture, bundle size, accessibility, and dead code. Use after non-trivial React changes, before PRs, or when investigating "the codebase feels slow / messy."
---

You wrap the [react-doctor](https://github.com/millionco/react-doctor) CLI and turn its output into actionable next steps.

## When to use this skill

- After a non-trivial React/TS change, as a sanity check before opening a PR.
- When the user asks for a "code health" or "anti-pattern" review of the React side of the project.
- Periodically as part of `react-reviewer` agent's workflow.
- **Skip** for tiny changes (typo, single-line fix, non-React code).

## How to run

```bash
npx -y react-doctor@latest .
```

Run from the project root. No installation needed. The tool auto-detects React, Next.js, Vite, Remix, or React Native.

### Useful flags (check `--help` for the current set)

- `--json` — machine-readable output, easier to parse and quote selectively.
- `--changed` — restrict analysis to files changed vs. main branch (faster on large repos, more relevant for PR reviews).

## What it checks

60+ rules across:

- **Performance** — re-render hot spots, missing memoization where it matters, unnecessary effects.
- **Architecture** — component boundaries, prop drilling, server/client split.
- **Bundle size** — heavy imports, untreeshakable patterns.
- **Security** — `dangerouslySetInnerHTML`, exposed env vars, unsafe redirects.
- **Accessibility** — missing labels, keyboard handling, semantic HTML.
- **Dead code** — unreachable branches, unused exports.

## How to present results

1. Run the command and capture output.
2. **Lead with the score** ("Health: 78/100").
3. **Group findings by severity**, not by rule. The user cares about what to fix first, not which rule fired.
4. For each high-priority finding, quote the file:line and propose a concrete fix.
5. **Don't dump the full output.** Summarize. Link the user to the raw output if they want more.

### Output template

```
## react-doctor: <SCORE>/100

## Top issues to fix
1. **<file.tsx:line>** — <issue summary>
   <one-line fix>
2. ...

## Lower priority
- <file:line> — <issue> (optional fix)

## What's healthy
<short list of things the audit found good — don't pad>

## Run again with
`npx -y react-doctor@latest --json .` for the full machine-readable report.
```

## Rules

- If the tool fails to run (e.g. not a React project), say so and stop. Don't fabricate findings.
- Don't auto-apply fixes. Recommend, let the user decide.
- If the score is high (>90) and the user asked for a routine review, say "looks healthy" and move on. Don't manufacture concerns.
- Cite issues by file:line, not by rule ID alone.
