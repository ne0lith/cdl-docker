#!/bin/sh
set -e

# adjust permissions if needed
exec fixuid -q "$@"
