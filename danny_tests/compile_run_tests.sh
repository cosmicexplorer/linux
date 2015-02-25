#!/bin/bash

find . -name "test*.c" |\
  while read -r file; do
    outfile="$(echo "$file" | sed -e 's/\.c$//g')"
    cc "$file" -o "$outfile"
    "./$outfile"
    if [ $? -ne 0 ]; then
      echo "ERROR OCCURRED WITHIN $file" 1>&2
    fi
    rm "$outfile"
  done
