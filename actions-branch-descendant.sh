#!/usr/bin/env bash

NEAREST_PARENT="$(git log --format='%D' \
  | grep \
    -oEm1 \
    "(origin/$DEVELOP_BRANCH_NAME|origin/$TEST_BRANCH_NAME|origin/$PRODUCTION_BRANCH_NAME)[,) ]")"

NEAREST_PARENT="${NEAREST_PARENT%%,}"

if [[ "$NEAREST_PARENT" == "origin/$PRODUCTION_BRANCH_NAME" ]] ; then
  echo "$NEAREST_PARENT branch is closest MST parent. PR good to go 👍"
  echo "valid=true
PR-string=$PRODUCTION_BRANCH_NAME branch is closest MST parent. PR good to go 👍
closest-MST-parent=$NEAREST_PARENT" >> "$GITHUB_OUTPUT"
  exit 0
else
  echo "$NEAREST_PARENT branch is closest MST parent."
  echo "$PRODUCTION_BRANCH_NAME branch should be the closest MST parent. PR not good to go 👎"
  echo "valid=false
PR-string=$PRODUCTION_BRANCH_NAME branch should be the closest MST parent. PR not good to go 👎
closest-MST-parent=$NEAREST_PARENT" >> "$GITHUB_OUTPUT"
  exit 1
fi
