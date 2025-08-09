#!/bin/sh
set -euo pipefail

get_token() {
  local t=""
  if command -v security >/dev/null 2>&1; then
    t=$(security find-generic-password -s slack-user-token -a slack-status -w 2>/dev/null || true)
  fi
  if [[ -z "${t}" ]]; then
    t="${SLACK_TOKEN:-}"
  fi
  if [[ -z "${t}" ]]; then
    echo "ERROR: Slack token not found. Set Keychain item (slack-user-token) or SLACK_TOKEN env." >&2
    exit 1
  fi
  echo "${t}"
}

# デフォルト
OAUTH_TOKEN=$(get_token)
EMOJI=""
TEXT=""
EXP=0  # 0 = 期限なし

usage() {
  cat <<USAGE
Usage:
  slack-status-lite [-e :emoji:] [-t "text"] [-m minutes]
  slack-status-lite --clear

Options:
  -e, --emoji       絵文字（例: :coffee:）。省略時は :zaitakuwork:
  -t, --text        ステータス文字列（任意）
  -m, --minutes     期限（分）。省略時は期限なし
  --clear           ステータスをクリア
Env:
  OAUTH_TOKEN       Slack User OAuth Token (xoxp-*)
USAGE
}

# macOS(BSD) / Linux(GNU) 両対応でUNIX時刻を計算
to_exp() {
  local mins="${1:-0}"
  if [[ -z "$mins" || "$mins" == "0" ]]; then echo 0; return; fi
  if date -v+1M >/dev/null 2>&1; then
    date -v+"$mins"M +%s
  else
    date -d "+$mins minutes" +%s
  fi
}

[[ "${1:-}" == "" ]] && usage && exit 2

# 引数パース
while (( "$#" )); do
  case "$1" in
    -e|--emoji)   EMOJI="$2"; shift 2 ;;
    -t|--text)    TEXT="$2";  shift 2 ;;
    -m|--minutes) EXP=$(to_exp "$2"); shift 2 ;;
    --clear)      CLEAR=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

: "${OAUTH_TOKEN:?ERROR: OAUTH_TOKEN 環境変数を設定してください (xoxp-...)}"

if [[ "${CLEAR:-0}" == "1" ]]; then
  PAYLOAD='{"profile":{"status_text":"","status_emoji":"","status_expiration":0}}'
else
  # JSON 文字列を安全に
  esc() { printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'; }
  TJSON=$(esc "$TEXT")
  EJSON=$(esc "$EMOJI")
  PAYLOAD="{\"profile\": {\"status_text\": ${TJSON}, \"status_emoji\": ${EJSON}, \"status_expiration\": ${EXP}}}"
fi

curl -sS -X POST \
  -H "Authorization: Bearer ${OAUTH_TOKEN}" \
  -H "Content-type: application/json; charset=utf-8" \
  -d "${PAYLOAD}" \
  https://slack.com/api/users.profile.set
echo

