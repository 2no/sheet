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
  list|ls) list ;;
  new|edit)
    if [ $# -ne 2 ]; then
      echo 'Please specify a name' 1>&2
      exit 1
    fi

    if [ -p /dev/stdin ]; then
      content=`cat -`
    fi
    path=$SHEET_PATH/$2
    [ -z $content ] && $EDITOR $path || echo $content > $path
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
      exit 0
    fi

    sheet=$SHEET_PATH/$1
    if [ ! -r $sheet ]; then
      echo "A cheat named $1 doesn't exist." 1>&2
      echo "You can create one with sheet new $1" 1>&2
      exit 1
    fi

    if type open >/dev/null 2>&1; then
      open_cmd='open'
    elif type xdg-open >/dev/null 2>&1; then
      open_cmd='xdg-open'
    elif type cygstart >/dev/null 2>&1; then
      open_cmd='cygstart'
    fi

    has_url=0
    if [ ! -z "$open_cmd" ]; then
      while read -r line
      do
        #echo $line
        if expr "$line" : 'url: ' > /dev/null; then
          url=`echo $line | sed -e "s/^url: \(.*\)$/\1/"`
          if [ ! -z "$url" ]; then
            `$open_cmd $url`
            has_url=1
          fi
        fi
      done < $sheet
    fi

    [ $has_url -eq 0 ] && cat $sheet
esac