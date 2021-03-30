#!/bin/bash

set -x

IFS=,
read -ra REVIEWERS <<< "${REQUIRED_REVIEWERS}"
NEED_REVIEW_BY=()

for reviewer in "${REVIEWERS[@]}"; do
  # PR owner cannot approve their own PR, so skip them.
  if [ "${reviewer}" = "${PR_OWNER}" ]; then
    continue
  fi

  # Check if the required reviewer has approved the PR.
  REVIEWED=$(gh api -X GET "repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/reviews" --jq "[.[] | select(.state == \"APPROVED\" and .user.login == \"$reviewer\")] | length")
  if [ "$REVIEWED" -eq "0" ];
  then
    # Review has not been approved by this reviewer.
    NEED_REVIEW_BY+=("${reviewer}")
  fi
done

if [ ${#NEED_REVIEW_BY[@]} -eq "0" ]; then
  STATE="success"
  DESCRIPTION=''
else
  STATE="failure"
  DESCRIPTION="Reviews by ${NEED_REVIEW_BY[*]} are required."
fi

gh api -X POST "/repos/${OWNER}/${REPO}/statuses/${STATUS_SHA}" -f state="${STATE}" -f context="Have all reviewers approved?" -f description="${DESCRIPTION}"
