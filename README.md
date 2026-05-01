# claude-template

汎用最適化された Claude Code 設定テンプレート。新しいプロジェクトに参画したら、ここから `.claude/` 一式と `CLAUDE.md` をコピーして即運用開始するためのもの。

## 想定スタック

- **Frontend**: React + TypeScript（Vite / Next.js / Remix / RN いずれも可）
- **Backend**: 技術非依存（Node / Python / Go / Rust など）

## 中身

```
.
├── .claude/
│   ├── agents/                       # 9 体の subagent
│   │   ├── planner.md                # 実装計画
│   │   ├── explorer.md               # 読み取り専用コード探索
│   │   ├── code-reviewer.md          # 汎用レビュー
│   │   ├── react-reviewer.md         # React/TS 特化レビュー
│   │   ├── security-reviewer.md      # セキュリティレビュー
│   │   ├── test-writer.md            # テスト作成
│   │   ├── debugger.md               # バグ調査・修正
│   │   ├── refactorer.md             # 振る舞い保存リファクタ
│   │   └── docs-writer.md            # README/JSDoc/ADR
│   ├── skills/
│   │   ├── react-doctor/SKILL.md     # react-doctor CLI ラッパー
│   │   ├── code-map/SKILL.md         # コードベース構造可視化 (Mermaid)
│   │   └── commit-check/SKILL.md     # コミット前チェック
│   ├── settings.json                 # permissions + 軽量 hooks
│   └── settings.local.json.example   # 個人ローカル上書き例
├── mcp.example.json                  # MCP サーバー雛形
├── CLAUDE.md                         # プロジェクトルート用テンプレ
├── apply.sh                          # 適用ヘルパー (POSIX)
├── apply.ps1                         # 適用ヘルパー (PowerShell)
└── README.md                         # このファイル
```

## 使い方

### 1. プロジェクトに適用

```bash
# POSIX (macOS/Linux/WSL/Git Bash)
~/claude-template/apply.sh /path/to/project

# Windows PowerShell
~\claude-template\apply.ps1 C:\path\to\project
```

スクリプトがやること:

- `.claude/` 一式をプロジェクト直下にコピー（既存ファイルは上書きしない）
- `CLAUDE.md` をコピー（既存があれば上書きしない）
- `mcp.example.json` をコピー

### 2. プロジェクト固有情報を埋める

- `CLAUDE.md` の `<...>` プレースホルダーを実プロジェクト情報に置換
- 不要セクションは削除
- 各 agent / skill のうち不要なものは削除（`.claude/agents/foo.md` を消すだけ）

### 3. MCP を使うなら

```bash
mv mcp.example.json .mcp.json
# 必要な server のキーから `_` プレフィックスを外し、トークンを env で設定
```

`.mcp.json` 実体は `.gitignore` で除外推奨。

### 4. 個人ローカル設定を使うなら

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
# 編集。これは git 管理しない（.gitignore 推奨）
```

## 含まれる subagent

| Agent | 役割 |
|---|---|
| `planner` | 実装計画作成（goal / 影響範囲 / リスク / 手順） |
| `explorer` | 読み取り専用のコード検索・コール経路追跡 |
| `code-reviewer` | 汎用 PR レビュー |
| `react-reviewer` | React/TS 特化レビュー（hooks 規則・re-render・a11y・TS 厳格性） |
| `security-reviewer` | OWASP/秘密情報/IDOR/SSRF などセキュリティ観点 |
| `test-writer` | テスト作成（Vitest/Jest/Playwright/言語非依存） |
| `debugger` | バグ再現 → root cause → 最小修正 + 回帰テスト |
| `refactorer` | 振る舞いを保存するリファクタ |
| `docs-writer` | README/JSDoc/ADR |

## 含まれる skill

| Skill | 用途 |
|---|---|
| `react-doctor` | `npx react-doctor` を実行し、健全性スコアと優先度付き修正提案 |
| `code-map` | リポジトリ構造を Mermaid 図 + 一行説明で可視化 |
| `commit-check` | コミット前の lint / typecheck / 関連テスト / 秘密情報スキャン |

## ビルトインとの棲み分け

Claude Code には以下のビルトインがあるため、テンプレ側では重複させていない:

- `/init` — CLAUDE.md 初期化
- `/review` — PR レビュー
- `/security-review` — セキュリティレビュー
- `/simplify` — コード簡素化
- `/loop`, `/schedule` — 定期実行

テンプレの `code-reviewer` / `security-reviewer` は、組織固有の観点（独自規約・社内基準）を加味する余地として残してある。プロジェクトで不要なら削除して構わない。

## カスタマイズ指針

- **agent / skill を追加したい**: `.claude/agents/foo.md` を新規作成。frontmatter に `name`, `description`, `tools`, `model` を書く。
- **既存を変えたい**: そのままファイルを編集。テンプレ側を更新するか、プロジェクト側だけで持つかは判断。
- **テンプレ側を更新**: `~/claude-template/` で編集して `git commit`。既存プロジェクトには反映されないので、必要なら手動で再適用。

## メンテナンス

```bash
cd ~/claude-template
git status
git diff
git commit -am "tweak: <what>"
```
