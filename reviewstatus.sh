#!/bin/bash

set -x

IFS=,
STATE="success"
read -ra REVIEWERS <<< "${REQUIRED_REVIEWERS}"
NEED_REVIEW_BY=()
for reviewer in "${REVIEWERS[@]}"; do
  REVIEWED=$(gh api -X GET "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/reviews" --jq "[.[] | select(.state == \"APPROVED\" and .user.login == \"$reviewer\")] | length")
  if [ "$REVIEWED" -eq 0 ];
  then
    STATE="failure"
    NEED_REVIEW_BY+=("${reviewer}")
  fi
done

if [ ${#NEED_REVIEW_BY[@]} -eq "0" ]; then
  DESCRIPTION=''
else
  DESCRIPTION="Reviews by ${NEED_REVIEW_BY[*]} are required."
fi

gh api -X POST "/repos/${OWNER}/${REPO}/statuses/${STATUS_SHA}" -f state="${STATE}" -f context="Have all reviewers approved?" -f description="${DESCRIPTION}"
