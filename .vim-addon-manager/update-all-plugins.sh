#!/bin/bash

# TODO What if there is a failure?  Abort and start again once resolved?  Or continue and report failures at the end?
set -e

for dir in */
do
  cd "$dir"
  if [ -d .git ]
  then
    echo "> $dir"
    git pull --ff-only
    echo
  fi
  cd ..
done
