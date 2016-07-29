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
    if [ `git rev-list HEAD..a6b83db8ebc65b11e913e38188a02a4fc27a52a2 -n 1 --count` -eq 1 ]; then
        make clean drop handel test
    else
        make clean drop mini test TestAssembly=Soneta.Handel.Test
    fi
}

function comment-with-branch
{
    # from https://gist.github.com/bartoszmajsak/1396344
    # with minimal changes like:
    # + sed -e "s/[a-z]\{3\}\([0-9]\{5\}\)/\1/" -e "s/^[^\/]\+\/\(.*\)/\1/"

    # This way you can customize which branches should be skipped when
    # prepending commit message.
    if [ -z "$BRANCHES_TO_SKIP" ]; then
      BRANCHES_TO_SKIP=(master develop test)
    fi

    BRANCH_NAME=$(git symbolic-ref --short HEAD | sed -e "s/[a-z]\{3\}\([0-9]\{5\}\)/\1/" -e "s/^[^\/]\+\/\(.*\)/\1/")
    BRANCH_NAME="${BRANCH_NAME##*/}"

    BRANCH_EXCLUDED=$(printf "%s\n" "${BRANCHES_TO_SKIP[@]}" | grep -c "^$BRANCH_NAME$")
    BRANCH_IN_COMMIT=$(grep -c "\[$BRANCH_NAME\]" $1)

    if [ -n "$BRANCH_NAME" ] && ! [[ $BRANCH_EXCLUDED -eq 1 ]] && ! [[ $BRANCH_IN_COMMIT -ge 1 ]]; then
      sed -i.bak -e "1s/^/[$BRANCH_NAME] /" $1
    fi
}
