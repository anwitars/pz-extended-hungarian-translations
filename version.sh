#!/usr/bin/env bash
set -euo pipefail

# Get the most recent reachable version tag.
if VERSION_TAG=$(git describe --tags --abbrev=0 2>/dev/null); then
    VERSION=${VERSION_TAG#v}
    COMMITS_AHEAD=$(git rev-list --count "${VERSION_TAG}..HEAD")
else
    # No tags exist: count all commits reachable from HEAD.
    VERSION="0.0.0"
    COMMITS_AHEAD=$(git rev-list --count HEAD)
fi

# Identify the current commit.
SHORT_HASH=$(git rev-parse --short HEAD)

# Keep exact release tags clean.
if [[ "$COMMITS_AHEAD" -eq 0 ]]; then
    MOD_VERSION="$VERSION"
else
    MOD_VERSION="${VERSION}.dev${COMMITS_AHEAD}+${SHORT_HASH}"
fi

printf '%s\n' "$MOD_VERSION"
