#!/usr/bin/env bash
# 同步 handoff 工作區 → push 到 GitHub → 等 Pages 重新 deploy。
# 用法：./update.sh "commit 訊息"  (沒給訊息時用預設 "Update deck")
set -euo pipefail

REPO_DIR="/Users/chenpowen/政大演講/options-mm-deck"
SRC_HTML="/Users/chenpowen/政大演講/handoff/options-market-making/project/Options MM Deck.html"
SRC_JS="/Users/chenpowen/政大演講/handoff/options-market-making/project/deck-stage.js"
URL="https://pwchentw.github.io/options-mm-deck/"
GH_API="repos/PWChenTW/options-mm-deck/pages/builds/latest"
MSG="${1:-Update deck}"

cp "$SRC_HTML" "$REPO_DIR/index.html"
cp "$SRC_JS"   "$REPO_DIR/deck-stage.js"

git -C "$REPO_DIR" add index.html deck-stage.js
if git -C "$REPO_DIR" diff --staged --quiet; then
  echo "✓ no changes — repo already up to date"
  exit 0
fi

git -C "$REPO_DIR" commit -m "$MSG"
git -C "$REPO_DIR" push

HEAD_SHA=$(git -C "$REPO_DIR" rev-parse HEAD)
echo "→ pushed $HEAD_SHA — waiting for Pages deploy"

printf "  "
until [ "$(gh api "$GH_API" --jq '"\(.commit) \(.status)"' 2>/dev/null)" = "$HEAD_SHA built" ]; do
  printf "."
  sleep 5
done
echo ""
echo "✓ live at $URL"

# 順手在瀏覽器打開。要關掉就把這行刪掉。
open "$URL" 2>/dev/null || true
