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

> 詳細マップが必要なら `/exploring-related-code` skill を実行。

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

### 開発ループ別の主な skill

| 場面 | skill / agent |
|---|---|
| チケット受領直後 | `/understanding-ticket` skill |
| 着手前のコード調査 | `/exploring-related-code` skill |
| 実装計画 | `/planning-implementation` skill, `planner` agent |
| 実装 | `/loop` ビルトイン or 手動 |
| コミット直前 | `/checking-commit` skill |
| PR 直前のセルフレビュー | `/reviewing-own-changes` skill |
| PR 説明書き | `/writing-pr-description` skill |
| レビューコメント対応 | `/responding-to-review` skill |
| エラー/障害調査 | `/investigating-error` skill |
| 落ちたテストの調査 | `/debugging-failing-test` skill |
| リリースノート作成 | `/writing-release-notes` skill |
| React 健全性監査 | `/running-react-doctor` skill |
| 依存パッケージ追加検討 | `/reviewing-dependency` skill |
| env 変数のドキュメント化 | `/documenting-env-vars` skill |
| 仕様書/RFC/decision doc 共同執筆 | `/doc-coauthoring` skill (公式) |
| UI 作成 | `/frontend-design` skill (公式) |
| UI テスト | `/webapp-testing` skill (公式) |
| MCP サーバー作成 | `/mcp-builder` skill (公式) |
| 新 skill の作成 | `/skill-creator` skill (公式) |
| レビュー（汎用） | `/review` ビルトイン or `code-reviewer` agent |
| セキュリティレビュー | `/security-review` ビルトイン or `security-reviewer` agent |
| React 特化レビュー | `react-reviewer` agent |
| テスト作成 | `test-writer` agent |
| バグ修正 | `debugger` agent |
| リファクタ | `refactorer` agent |
| ドキュメント作成 | `docs-writer` agent |

skill の出力は `.claude/output/<skill-name>/` に保存される（git 管轄外）。
