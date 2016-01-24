#!/bin/bash

pattern='.......................'
hooks=( `find ../.git/hooks -name '*.sample' -exec basename '{}' .sample \;` )
functions=( `grep function build\~/hooks.bash | sed 's/function \([^\S(]*\).*/\1/'` )

function save-storage()
{
    echo Saving hook files
    for hindex in ${!hooks[@]}
    do
        local stored=${storage[hindex]}
        if [ -n "$stored" ]; then
            echo "  ${hooks[hindex]//_/ }"
            if [ ! -d build\~ ]; then mkdir build\~; fi
            echo "#!/bin/bash" > build\~/${hooks[hindex]}
            echo "source .git/hooks/hooks.bash" >> build\~/${hooks[hindex]}
            for findex in ${!functions[@]}
            do
                local expected=$(( 2**$findex  ))
                local checked=$(( $stored & $expected ))

                if [ $checked -eq $expected ]; then
                    echo ${functions[findex]} >> build\~/${hooks[hindex]}
                fi
            done
        fi
    done
}

function preview-storage()
{
    echo Current selection
    for hindex in ${!hooks[@]}
    do
        local stored=${storage[hindex]}
        if [ -n "$stored" ]; then
            echo; echo -n "  ${hooks[hindex]//_/ }${pattern:0:-${#hooks[hindex]}}"
            for findex in ${!functions[@]}
            do
                local expected=$(( 2**$findex  ))
                local checked=$(( $stored & $expected ))

                if [ $checked -eq $expected ]; then
                    echo -n "${pattern:0:-${#functions[findex]}}${functions[findex]//_/ }"
                fi
            done
        fi
    done

    local options=( `echo "Back Save"` )
    echo; prompt ${options[@]}

    case $choice in
        0)
            echo Back to main view!
            main-prompt
            ;;
        1)
            save-storage
            ;;
        *)
            echo Ups!
            preview-storage
            ;;
    esac
}

function store()
{
    local hook=$1
    local function=$2

    storage[$hook]=$((2**$function))
}

function hook-prompt()
{
    echo Choose hook, please
    prompt ${hooks[@]}

    if [ -z $choice ]; then
        echo Back to main view!
        main-prompt
    elif [ -n "${choice##[0-9]}" ]; then
        echo Ups!
        hook-prompt
    elif [ -z $1 ] && [ $choice -ge 0 -a $choice -lt ${#hooks[@]} ]; then
        function-prompt $choice
    elif [ -n $1 ] && [ $choice -ge 0 -a $choice -lt ${#hooks[@]} ]; then
        store $choice $1
        main-prompt
    else
        echo Ups!
        hook-prompt
    fi
}

function function-prompt()
{
    echo Choose function, please
    prompt ${functions[@]}

    if [ -z $choice ]; then
        echo Back to main view!
        main-prompt
    elif [ -n "${choice##[0-9]}" ]; then
        echo Ups!
        function-prompt
    elif [ -z $1 ] && [ $choice -ge 0 -a $choice -lt ${#functions[@]} ]; then
        hook-prompt $choice
    elif [ -n $1 ] && [ $choice -ge 0 -a $choice -lt ${#functions[@]} ]; then
        store $1 $choice
        main-prompt
    else
        echo Ups!
        function-prompt
    fi
}

function main-prompt()
{
    local options=( `echo "Quit Choose_hook Choose_function Preview"` )
    prompt ${options[@]}

    case $choice in
        [Qq0])
            echo Bye!
            ;;
        1)
            hook-prompt
            ;;
        2)
            function-prompt
            ;;
        3)
            preview-storage
            ;;
        *)
            echo Ups!
            main-prompt
            ;;
    esac
}

function prompt()
{
    local options=( $@ )
    for index in ${!options[@]}
    do
        echo -n "  $index)${pattern:0:-${#options[index]}}${options[index]//_/ }"
        if [ $(( $index % 4 )) -eq 3 ]; then echo; fi
    done

    echo; read -p 'Your choice: ' choice
}

main-prompt

unset hooks
unset choice
unset pattern
unset storage
unset functions
