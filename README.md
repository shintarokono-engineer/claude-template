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
│   │   ├── understanding-ticket/     # チケット読解 → 要件構造化
│   │   ├── exploring-related-code/   # 機能起点でコード探索（旧 code-map 吸収）
│   │   ├── planning-implementation/  # 実装計画（Phase 分け）
│   │   ├── reviewing-own-changes/    # PR 前セルフレビュー
│   │   ├── writing-pr-description/   # PR 説明書き
│   │   ├── investigating-error/      # エラー調査（症状→仮説→検証）
│   │   ├── responding-to-review/     # レビューコメント対応
│   │   ├── debugging-failing-test/   # 落ちテスト調査
│   │   ├── writing-release-notes/    # リリースノート
│   │   ├── writing-verification-checklist/ # 動作確認観点（コピペ用 markdown）
│   │   ├── documenting-env-vars/     # env 変数のドキュメント化
│   │   ├── reviewing-dependency/     # 依存パッケージ追加レビュー
│   │   ├── running-react-doctor/     # react-doctor CLI ラッパー
│   │   └── checking-commit/          # コミット前チェック
│   ├── output/                       # skill 成果物の保存先（git 管轄外）
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
- `anthropics/skills` から **公式 skill 5 個をデフォルト取り込み**: `skill-creator`, `mcp-builder`, `frontend-design`, `webapp-testing`, `doc-coauthoring`

#### オプション

```bash
# Office 系 skill を opt-in 追加（POSIX）
~/claude-template/apply.sh /path/to/project --add docx --add pdf

# 同 (PowerShell)
~\claude-template\apply.ps1 C:\path\to\project -Add docx,pdf

# 公式 skill を取り込まない
~/claude-template/apply.sh /path/to/project --no-official
~\claude-template\apply.ps1 C:\path\to\project -NoOfficial
```

opt-in 可能な公式 skill: `docx`, `pdf`, `pptx`, `xlsx`

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

## 含まれる自作 skill（14 個）

全 skill は **必要情報を `AskUserQuestion` でユーザーから収集してから動く** ヒアリング駆動設計。成果物は `.claude/output/<skill-name>/` に書き出す（git 管轄外）。

frontmatter には `disable-model-invocation: true` を設定済み（手動 `/skill-name` 起動限定 + Claude のコンテキスト節約）。auto 起動を許可したい skill は当該行を削除。

### 開発ループ核（毎タスク）

| Skill | 用途 |
|---|---|
| `understanding-ticket` | チケット/issue 読解 → 要件・受け入れ条件・不明点を構造化 |
| `exploring-related-code` | 機能起点でコード探索 → ディレクトリツリー / Mermaid 図 |
| `planning-implementation` | 実装計画（Phase 分け / リスク / Rollback） |
| `reviewing-own-changes` | PR 前セルフレビュー（命名・設計・テスト・性能・セキュリティ） |
| `writing-pr-description` | PR 説明書き（What/Why/How / Test plan / Risks） |
| `investigating-error` | エラー調査（症状 → 仮説複数 → 検証手順 → 修正方針） |

### 開発ループ周辺（週次〜不定期）

| Skill | 用途 |
|---|---|
| `writing-verification-checklist` | 動作確認観点を copy-paste 可能な markdown checklist で出力 |
| `responding-to-review` | レビューコメント対応（修正 / 反論 / 別 PR / 既対応に分類） |
| `debugging-failing-test` | 落ちテスト調査（テスト誤 / 実装誤 / 環境 / フレーキー判別） |
| `writing-release-notes` | リリースノート（破壊的変更を最上位、読者別トーン） |

### プロジェクト初期/保守

| Skill | 用途 |
|---|---|
| `documenting-env-vars` | `.env.example` から env 変数を表形式でドキュメント化 |
| `reviewing-dependency` | 依存追加判断材料（ライセンス・サイズ・脆弱性・代替候補） |

### 実行型ゲート

| Skill | 用途 |
|---|---|
| `running-react-doctor` | `npx react-doctor` 実行 + 優先度付き修正提案 |
| `checking-commit` | コミット前チェック（lint/typecheck/関連テスト/秘密情報スキャン） |

## デフォルトで取り込まれる公式 skill（5 個）

`apply.sh` / `apply.ps1` が `anthropics/skills` から自動取得:

| Skill | 用途 |
|---|---|
| `skill-creator` | skill 作成 + eval 駆動開発支援（メタ運用の中核） |
| `mcp-builder` | MCP サーバー作成（Python FastMCP / TS MCP SDK） |
| `frontend-design` | 高品質な Web UI 作成（React コンポーネント、ページ、ダッシュボード） |
| `webapp-testing` | Playwright で web app テスト・UI 検証 |
| `doc-coauthoring` | 構造化文書（spec / RFC / decision doc）の共同執筆 |

## opt-in できる公式 skill（4 個）

`--add <skill>` / `-Add <skill>` で個別追加:

| Skill | 用途 |
|---|---|
| `docx` | Word 文書の作成・読み取り・編集 |
| `pdf` | PDF 操作（読取・結合・分割・OCR・フォーム入力） |
| `pptx` | PowerPoint プレゼン作成・編集 |
| `xlsx` | スプレッドシート（.xlsx/.csv/.tsv）操作 |

## ビルトインとの棲み分け

Claude Code には以下のビルトインがあるため、テンプレ側では重複させていない:

- `/init` — CLAUDE.md 初期化
- `/review` — PR レビュー
- `/security-review` — セキュリティレビュー
- `/simplify` — コード簡素化
- `/loop`, `/schedule` — 定期実行
- `/claude-api` — Claude API 開発支援（公式 skill `claude-api` バンドル済み）

テンプレの `code-reviewer` / `security-reviewer` は、組織固有の観点（独自規約・社内基準）を加味する余地として残してある。プロジェクトで不要なら削除して構わない。

## skill 出力ディレクトリ

各 skill が生成する成果物は `.claude/output/<skill-name>/<YYYY-MM-DD-HHmm>-<topic>.md` に保存される。これは `.claude/output/.gitignore` で git 除外済み。

チームで共有したい成果物（spec / decision doc 等）は `docs/` 等に手動で移動すること。

## カスタマイズ指針

- **agent / skill を追加したい**: 公式の `skill-creator` を起動するのが推奨。`.claude/agents/foo.md` / `.claude/skills/foo/SKILL.md` を直接書いてもよい。
- **既存を変えたい**: そのままファイルを編集。テンプレ側を更新するか、プロジェクト側だけで持つかは判断。
- **テンプレ側を更新**: `~/claude-template/` で編集して `git commit`。既存プロジェクトには反映されないので、必要なら手動で再適用。

## メンテナンス

```bash
cd ~/claude-template
git status
git diff
git commit -am "tweak: <what>"
```
