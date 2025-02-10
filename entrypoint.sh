#!/bin/bash
set -e

# adjust permissions with fixuid if needed
if [[ "$GOTTY" == "true" ]]; then
	# run app in background
	fixuid -q tmux new -d -s gotty "$@"

	# WebTTY connects to tmux
	gotty tmux new -A -s gotty &
	# if no tmux channel then cleanup
	tmux wait gotty && kill $!
else
	exec fixuid -q "$@"
fi
