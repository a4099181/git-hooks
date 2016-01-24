#!/bin/bash

function assert-utf-8-encoding()
{
    local output=`git --no-pager diff --name-only --cached --diff-filter=AMR -z | \
        xargs --null --no-run-if-empty file -i | \
        sed "s/^\([^:]*\):.*; charset=\(.*\)/\1: \2/" | \
        grep -v "us-ascii\|utf-8"`

    if [ `echo -n $output | wc -c` -ne 0 ]; then
        echo "Invalid encoding detected."
        echo $output
        exit 1
    fi
}

function assert-handel-tests
{
    make clean drop handel test
}

