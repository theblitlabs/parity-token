#!/bin/sh

# Get the commit message from the first argument or from COMMIT_EDITMSG
commit_msg_file=${1:-".git/COMMIT_EDITMSG"}
commit_msg=$(cat "$commit_msg_file")

# Conventional Commit format regex
# Format: <type>(<scope>): <description>
# Types: feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert
conventional_commit_regex="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\([a-z0-9-]+\))?: .+"

if ! echo "$commit_msg" | grep -qE "$conventional_commit_regex"; then
    echo "Error: Commit message does not follow conventional commit format."
    echo "Format: <type>(<scope>): <description>"
    echo "Types: feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert"
    echo "Example: feat(auth): add login functionality"
    exit 1
fi

exit 0 