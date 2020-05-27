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

BRANCH=""
EDITOR=${EDITOR:-vim}

# select branch
echo "Which article do you want to edit ? "
select branch in $(git branch|tr -d ' '|tr -d '*'|sed -e 's#^#branch/#') Exit
do
  case $branch in
    Exit)
      echo "Exiting, I did nothing !"
      exit 11
      ;;
    branch*)
      BRANCH=$(basename $branch)
      echo "You choose: $BRANCH"
      git checkout $BRANCH
      break
      ;;
    *)
      echo "This is not a choice number"
      ;;
  esac
done

# Select file
echo "Which file do you want to open ? "
select file in $(find kbase/knowledge-base/*/$BRANCH/* -type f) Exit
do
  case $file in
    Exit)
      echo "Exiting, I did nothing !"
      exit 11
      ;;
    kbase*)
      FILE=$file
      break
      ;;
    *)
      echo "This is not a choice number"
      ;;
  esac
done

$EDITOR $FILE


