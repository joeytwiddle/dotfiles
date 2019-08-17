#!/bin/bash

# Load run_if_window_matches and other scripts for sxhkd
. "$HOME"/j/startj-simple
sxhkd > /tmp/sxhkd.$USER.out 2>&1 &

#gkrellm &
