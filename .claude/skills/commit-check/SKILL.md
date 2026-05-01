---
name: commit-check
description: コミット前の品質ゲート。プロジェクトの lint、型チェック、関連テストをステージ済み/直近変更ファイルに対して実行し、誤って混入したシークレットや巨大バイナリをスキャンする。`git commit` の直前、または編集後に緑判定を取りたいときに使う。
---

コミットされる前に、プロジェクトを意識した高速な正気度チェックを実行します。コミットも push もしません。報告のみです。

## 進め方

1. **プロジェクト形を検出する。**
   - `package.json`（ルート + workspace 各パッケージ）を読む。`scripts.lint`、`scripts.typecheck` / `tsc`、`scripts.test` を抽出。
   - 通例にフォールバック: `npm run lint`、`npx tsc --noEmit`、`npm test`。
   - 非 JS プロジェクトでは: `pyproject.toml`（ruff/mypy/pytest）、`Cargo.toml`（clippy/cargo test）、`go.mod`（go vet, go test）を検出。

2. **何が変わったかを特定する。**
   ```bash
   git diff --name-only --staged       # ステージあり
   git diff --name-only                 # なければ作業ツリー差分
   ```
   どちらも空なら「チェック対象なし」と報告して終わる。

3. **チェックを実行する。可能な限り変更ファイルにスコープを絞る。**
   - **Lint** — `npx eslint <files>`（または `ruff check <files>`）。
   - **型チェック** — 通常はプロジェクト全体（`npx tsc --noEmit`）。スコープ絞りは難しい。
   - **フォーマット** — `npx prettier --check <files>`。
   - **テスト** — 変更ファイル関連のテストを実行: `npm test -- --findRelatedTests <files>`（Jest）または `npx vitest run --related <files>`。関連検出ツールがなければ、変更パッケージの全テストにフォールバック。

4. **シークレットスキャン。** 高リスクパターンをステージ済みファイルから grep:
   ```
   AKIA[0-9A-Z]{16}             # AWS access key
   sk_live_[0-9a-zA-Z]{24,}     # Stripe live key
   ghp_[0-9a-zA-Z]{36}          # GitHub PAT
   -----BEGIN.*PRIVATE KEY-----
   ```
   加えて `.env*`, `*.pem`, `*.key` がステージされていないかをヒューリスティック確認。

5. **巨大ファイルチェック。** 1 MB 超のステージ済みファイルを警告。バイナリは git に入れたくないことがほとんど。

## 出力フォーマット

```
## commit-check

### スコープ
<N ファイルステージ済み | 作業ツリー変更>: file1, file2, ...

### 結果
- Lint:        PASS / FAIL (<件数>)
- 型チェック:  PASS / FAIL (<最初のエラー>)
- フォーマット: PASS / FAIL
- テスト:      PASS / FAIL (<失敗テスト名>)
- シークレット: CLEAN / FOUND (<file>:<line> <種別>)
- 巨大ファイル: NONE / <file> (<size>)

### 判定
<緑: コミット OK | 赤: 上記を直してから>

### 修正候補
- <失敗があるときのみ>
```

## ルール

- **プロジェクトが対応していないコマンドは実行しない。** `package.json` に `lint` script も eslint 設定もないなら、lint をスキップして「lint 設定なし」と述べる。
- **自動修正しない。** `npx eslint --fix` 等を案内するが、実行はユーザーが行う。
- **コミットしない。** これはチェックスキルでありアクションではない。
- **高速にする。** 全リポジトリ実行よりスコープ実行を優先。例外的に全リポジトリ `tsc` は TS の制約上仕方ない。
- チェックが遅い（>30 秒）場合は警告し、フラグでスキップ可能にする。
- 赤判定はブロッカーではなく情報。コミット強行するかはユーザー判断。
