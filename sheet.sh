#!/bin/sh

SHEET_PATH=~/.sheets

list()
{
  for FILE in $SHEET_PATH/*
  do
    [ -r $FILE ] && basename $FILE
  done
}

case $1 in
  list) list ;;
  new|edit)
    if [ $# -ne 2 ]; then
      echo 'Please specify a name' 1>&2
      exit 1
    fi
    $EDITOR $SHEET_PATH/$2
    ;;
  copy)
    if [ $# -ne 2 ]; then
      echo 'Please specify a name' 1>&2
      exit 1
    fi

    sheet=$SHEET_PATH/$2
    if [ ! -r $sheet ]; then
      echo "A sheet named $2 could not be found"
      exit 1
    fi

    if type pbcopy >/dev/null 2>&1; then
      cat $sheet | pbcopy
    fi

    if type xclip >/dev/null 2>&1; then
      cat $sheet | xclip -i
    fi
    ;;
  *)
    if [ $# -eq 0 ]; then
      list
      exit
    fi

    sheet=$SHEET_PATH/$1
    if [ ! -r $sheet ]; then
      echo "A cheat named $1 doesn't exist." 1>&2
      echo "You can create one with sheet new $1" 1>&2
      exit 1
    fi
    cat $sheet
esac
