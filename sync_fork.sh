#!/usr/bin/env bash
# force exit on error
set -e

# check script args number
if [[ "$#" -ne 1 ]]
then
    echo "Illegal number of parameters"
    exit 1
else
  FORK="$1"
fi
# check if FORK arg is a git dir
if [[ -d "$FORK"/.git ]]
then
  cd $FORK
else
  echo "$FORK is not a git folder !"
  exit 10
fi

git checkout master
#git remote add upstream <repo-location>
git fetch upstream
git rebase upstream/master
git push origin master

