#!/usr/bin/env bash
# force exit on error
set -e

EDITOR=${EDITOR:-vim}
COMMAND=""
FORK=""
BRANCH=""
CATG=""
TITLE=""

function showHelp {
  echo "
   Help:
    $0 FORK [sync, create, edit, remove]
  "
}

function syncFork {
  echo -e "\n # Update local repo"
  git pull
  echo -e "\n # Update upstream remote"
  git fetch upstream
  echo -e "\n # Change to master branch"
  git checkout master
  echo -e "\n # Update master from upstream"
  git rebase upstream/master
  echo -e "\n # Push upstream update to master on github"
  git push origin master
}

function createNewArticle {
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
  BRANCH="$TITLE"
  
  echo "## Creating $BRANCH and setup workdir"
  git checkout -b "$BRANCH"
  mkdir "$WORKDIR"
  find "templates/$CATG" -type f -exec cp -Rp {} "$WORKDIR" \;
  echo -n "\n ## Workdir $WORKDIR ready on branch $BRANCH \n"
  
  echo "## Pushing $BRANCH to the fork"
  git add $WORKDIR/\*
  git commit -m "Init new branch $BRANCH"
  git push -u origin $BRANCH
}


function editArticle {
  # select branch
  COLUMNS=0
  echo "Which article do you want to edit ? "
  select branch in $(git branch | tr -d ' '| tr -d '*' | grep -v 'master'| sed -e 's#^#branch/#') Exit
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
        $(git branch -a | grep -q $BRANCH) && git pull origin $BRANCH
        break
        ;;
      *)
        echo "This is not a choice number"
        ;;
    esac
  done
  
  # Select file
  echo "Which file do you want to open ? "
  select file in $(git diff master..."$BRANCH" --name-status --diff-filter=A | awk -F' ' '{print $2}') Exit
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
}

function removeArticle {
  # select branch
  COLUMNS=0
  echo "Which article do you want to remove ? "
  select branch in $(git branch | tr -d ' '| tr -d '*' | grep -v 'master'| sed -e 's#^#branch/#') Exit
  do
    case $branch in
      Exit)
        echo "Exiting, I did nothing !"
        exit 11
        ;;
      branch*)
        BRANCH=$(basename $branch)
        echo "You choose: $BRANCH"
        git checkout master
        git branch -d $BRANCH
        git push origin --delete $BRANCH
        break
        ;;
      *)
        echo "This is not a choice number"
        ;;
    esac
  done
}



#### Main logic
# check script args number
if [[ "$#" -ne 2 ]]
then
    echo "Illegal number of parameters"
    showHelp
    exit 1
else
  FORK="$1"
  COMMAND="$2"
fi
# check if FORK arg is a git dir
if [[ -d "$FORK"/.git ]]
then
  cd $FORK
else
  echo "$FORK is not a git folder !"
  exit 10
fi

case $COMMAND in
  sync)
    syncFork
    ;;
  create)
    createNewArticle
    ;;
  edit)
    editArticle
    ;;
  remove)
    removeArticle
    ;;
  *)
    echo "*$2* is not a valid argument."
    showHelp
    ;;
esac
