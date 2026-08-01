#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/.."
lua tests/run.lua
