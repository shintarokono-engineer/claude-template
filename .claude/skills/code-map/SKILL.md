---
name: code-map
description: Generate a visual codebase map — directory tree with one-line responsibilities plus a Mermaid diagram of major module dependencies. Use when onboarding to a project, when the user asks "how is this codebase organized?", or before a large refactor.
---

You produce a scannable, accurate map of the codebase. Not an exhaustive index — a tour.

## Process

1. **Top-level layout.** `ls` the repo root. Identify the entry-point folders (typically `src/`, `app/`, `packages/`, `apps/`, `services/`).
2. **Two levels deep.** For each top-level folder, list its immediate children with a one-line responsibility derived from reading `index.ts` / a representative file / the folder's README.
3. **Detect the architecture style.** Frontend SPA, Next.js app router, monorepo (workspaces?), microservices, library? State this up front.
4. **Identify cross-cutting concerns.** Where do types live? Tests? Configs? Build outputs?
5. **Build a dependency diagram.** For 5–10 of the most important modules, show what depends on what. Use Mermaid `flowchart`.

## Output format

```markdown
# Codebase map

## Architecture
<one paragraph: SPA / monorepo / RSC / etc., key frameworks, package manager>

## Layout

```
project/
├── src/
│   ├── components/    # presentational UI building blocks
│   ├── features/      # feature-scoped logic (one folder per feature)
│   ├── hooks/         # shared hooks
│   ├── lib/           # framework-agnostic utilities
│   └── api/           # API client + types
├── tests/             # integration + e2e
└── package.json
```

## Module dependencies

```mermaid
flowchart LR
  components --> hooks
  features --> components
  features --> api
  features --> hooks
  api --> lib
  hooks --> lib
```

## Conventions worth knowing
- <thing>: <where>
- ...

## Where to start reading
1. `<entrypoint file>` — application boot
2. `<key feature folder>` — pick one feature and read end-to-end first
3. `<test setup>` — to understand testing approach
```

## Rules

- **Mermaid only when it adds clarity.** If there are <5 meaningful arrows, skip the diagram and just write prose.
- **Don't list every file.** Stop at directories whose contents are predictable.
- **Verify by reading.** If you label a folder "API client", confirm by opening at least one file inside.
- **State unknowns.** "I couldn't determine the purpose of `src/foo/` — it has 3 files with mixed concerns." Better than fabricating.
- Keep the whole map under one screen. If the project is huge, map one slice at a time and ask which slice the user wants next.

## Variants the user might ask for

- **"map the auth flow"** — trace login → session → protected route. Render as a sequence diagram.
- **"map the data flow"** — DB → API → client. Flowchart with persistence at the bottom.
- **"map the test pyramid"** — unit / integration / e2e folders, with counts.

For each variant, follow the same pattern: read enough to be accurate, render minimally, label honestly.
