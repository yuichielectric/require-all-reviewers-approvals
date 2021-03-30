#!/bin/bash

set -x

IFS=,
STATE="success"
read -ra REVIEWERS <<< "${REQUIRED_REVIEWERS}"
for reviewer in "${REVIEWERS[@]}"; do
  REVIEWED=$(gh api -X GET "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/reviews" --jq "[.[] | select(.state == \"APPROVED\" and .user.login == \"$reviewer\")] | length")
  if [ "$REVIEWED" -ne 0 ];
  then
    STATE="failure"
  fi
done

gh api -X POST "/repos/${OWNER}/${REPO}/statuses/${STATUS_SHA}" -f state=${STATE} -f context="Have all reviewers approved?"
