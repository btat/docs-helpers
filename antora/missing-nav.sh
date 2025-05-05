#!/bin/bash

DOCS_DIR="docs"

# Naming convention inconsistent. Check for other variation.
if [ -d versions ]; then
  DOCS_DIR="versions"
fi

MODULE_LANG_DIRS=$(find $DOCS_DIR -type d -iname "pages")

for dir in $MODULE_LANG_DIRS; do
    MODULE_LANG_FILES=$(find $dir -type f -iname "*.adoc" ! -iname "_*.adoc")
    for file in $MODULE_LANG_FILES; do
        MODULE_LANG_RELATIVE_PATH=${file#$dir}
        MODULE_LANG_RELATIVE_PATH=${MODULE_LANG_RELATIVE_PATH#/}
        NAV_FILE="${dir%pages}nav.adoc"
        
        if ! grep -q $MODULE_LANG_RELATIVE_PATH $NAV_FILE; then
            echo $file > tmp/missing-nav.log
        fi
    done
done

if test -f tmp/missing-nav.log; then
    cat tmp/missing-nav.log
    exit 1
else
    exit 0
fi
