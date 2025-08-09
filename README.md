# slack-status-cli

Slack のステータスを CLI から簡単に変更するためのスクリプトです。

## 概要

このスクリプトを使うと、ターミナルから Slack のステータス（テキスト、絵文字、有効期限）を設定できます。

## 使い方

### 事前準備

1.  Slack User OAuth Token が必要です。以下のいずれかの方法で設定してください。
    *   **Keychain に登録:** `security add-generic-password -a slack-status -s slack-user-token -w <your_token>`
    *   **環境変数 `SLACK_TOKEN` に設定:** `export SLACK_TOKEN=<your_token>`

### 基本的な使い方

```bash
./slack-status.sh -e :coffee: -t "作業中" -m 60  # 60分間ステータスを「作業中」に設定
./slack-status.sh --clear  # ステータスをクリア
```

### オプション

*   `-e, --emoji`: 絵文字（例: `:coffee:`）。省略時は `:zaitakuwork:`
*   `-t, --text`: ステータス文字列（任意）
*   `-m, --minutes`: 期限（分）。省略時は期限なし
*   `--clear`: ステータスをクリア
*   `-h, --help`: ヘルプを表示

### 環境変数

*   `OAUTH_TOKEN`: Slack User OAuth Token (xoxp-\*)。Keychain に登録されていない場合に利用。

## インストール

1.  スクリプトをダウンロードします。
2.  実行権限を付与します: `chmod +x slack-status.sh`
3.  必要に応じて、スクリプトを PATH の通ったディレクトリに移動します。

## 依存関係

*   `curl`
*   `python3`
*   `date` (GNU date または BSD date)
*   `security` (macOS のみ。Keychain を使用する場合)

## ライセンス

MIT
