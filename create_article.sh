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


CATG=""
TITLE=""

function rebaseFork {
  git checkout master
  git fetch upstream
  git rebase upstream/master
}

# select template category
echo "Choose a template category for the new KB: "
select catg in $(find templates/* -type d) Exit
do
  case $catg in
    Exit)
      echo "Exiting, I did nothing !"
      exit 11
      ;;
    template*)
      CATG=$(basename $catg)
      echo "You choose: $CATG"
      break
      ;;
    *)
      echo "This is not a choice number"
      ;;
  esac
done

while true
do
  echo "[ ${CATG^^} ] Set a slugified title for the folder name: "
  echo -n ">> "
  read title
  echo "Are you sure ? Y/n"
  echo -n ">> "
  read yesno
  [[ $yesno == "Y" ]] && TITLE=$title; break
done

WORKDIR="kbase/knowledge-base/$CATG/$TITLE"
rebaseFork
git checkout -b "$TITLE"
mkdir "$WORKDIR"
find templates/issue -type f -exec cp -Rp {} "$WORKDIR" \;

echo "## Workdir $WORKDIR ready on branch $TITLE"
