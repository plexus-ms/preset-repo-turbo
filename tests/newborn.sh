#!/bin/sh
# A newborn repo passes its own lint: the template is rendered as copier would
# render it for a new repo, birth tasks included, and the generated repo's own
# `mise run lint` is run in it. Nothing else reads the template's files the way
# a consumer's tools do, so a file the formatter rejects would otherwise ship
# and fail the lint of every repo that takes the version (0.120.0's turbo.json).
#
# Both shapes of the template are rendered: an app repo, and a package repo
# (`publishes_packages`). The working tree is what is rendered, uncommitted
# changes included.
#
#   tests/newborn.sh           # render both shapes and lint them
#   KEEP=1 tests/newborn.sh    # leave the rendered repos in place and say where
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
[ -n "${KEEP:-}" ] || trap 'rm -rf "$tmp"' EXIT

newborn() {
  name=$1
  shift
  echo "→ $name: render"
  copier copy --quiet --defaults --trust --vcs-ref HEAD -d tenant=acme "$@" "$here" "$tmp/$name"
  echo "→ $name: lint"
  (cd "$tmp/$name" && mise run lint)
  echo "✓ $name"
}

newborn app
newborn packages -d publishes_packages=true

[ -z "${KEEP:-}" ] || echo "kept: $tmp"
