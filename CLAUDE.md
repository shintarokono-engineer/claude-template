# <Project Name>

> このファイルはプロジェクト参画時にプロジェクト固有の情報で埋めること。`<...>` プレースホルダーは全て置換する。空のセクションは削除。

## Project Overview

<1〜2 行で「これは何のプロジェクトか」を説明>

## Tech Stack

- **Frontend**: React + TypeScript / <Vite | Next.js | Remix | ...>
- **Backend**: <Node | Python | Go | ...>
- **DB**: <Postgres | MySQL | DynamoDB | ...>
- **Package manager**: <npm | pnpm | yarn>
- **Test**: <Vitest | Jest | Playwright | ...>
- **CI**: <GitHub Actions | CircleCI | ...>
- **Deploy**: <Vercel | AWS | ...>

## Directory Map

```
.
├── src/
│   ├── components/   # <埋める>
│   ├── features/     # <埋める>
│   ├── hooks/        # <埋める>
│   ├── lib/          # <埋める>
│   └── api/          # <埋める>
├── tests/
└── ...
```

> 詳細マップが必要なら `/code-map` skill を実行。

## Coding Conventions

- **Naming**: <camelCase / kebab-case など>
- **Imports**: <絶対パス `@/...` 利用 / 相対パスのみ など>
- **Components**: <function component / React.FC 不使用 など>
- **Types**: <strict mode / `any` 禁止 / 例外は `as unknown as T` など>
- **Formatter**: <Prettier with .prettierrc>
- **Linter**: <ESLint config の場所>

## Workflow

- **Branch**: `<feature/...> | <fix/...>` from `<main | develop>`
- **PR**: <Conventional Commits / 1 PR = 1 概念>
- **Commit**: <Conventional Commits / Squash on merge など>
- **Review**: <最低 1 名 / CI green 必須 など>

## Common Commands

```bash
<npm install>          # 依存導入
<npm run dev>          # 開発サーバー
<npm test>             # 全テスト
<npm run lint>         # lint
<npx tsc --noEmit>     # 型チェック
<npm run build>        # 本番ビルド
```

## Do / Don't

**Do**

- <プロジェクト固有のルール>

**Don't**

- <プロジェクト固有の禁止事項>
- 機密情報をログに出さない
- `git push --force` を main/develop に対して使わない

## References

- 内部 Wiki: <URL>
- Figma: <URL>
- ADR: `docs/adr/`
- API spec: <URL>

## Claude Code セットアップ

このリポジトリは `~/claude-template/` から派生した `.claude/` 設定を含む。
利用可能な subagent / skill は `.claude/agents/` と `.claude/skills/` 配下を参照。

主な使い方:

- 計画立案 → `planner` agent
- コード探索 → `explorer` agent
- レビュー → `code-reviewer` / `react-reviewer` / `security-reviewer` agent
- React 健全性監査 → `react-doctor` skill
- コミット前チェック → `commit-check` skill
- 構造可視化 → `code-map` skill
