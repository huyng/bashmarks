# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch $SDIRS

RED="0;31m"
GREEN="0;33m"

function mark {
    # save current directory to bookmarks
    function bm_s {
        _bookmark_name_valid "$@"
        if [ -z "$exit_message" ]; then
            _purge_line "$SDIRS" "export DIR_$1="
            CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
            echo "export DIR_$1=\"$CURDIR\"" >> $SDIRS
        fi
    }

    # jump to bookmark
    function bm_g {
        source $SDIRS
        target="$(eval $(echo echo $(echo \$DIR_$1)))"
        if [ -d "$target" ]; then
            cd "$target"
        elif [ ! -n "$target" ]; then
            echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
        else
            echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
        fi
    }

    # print bookmark
    function bm_p {
        source $SDIRS
        echo "$(eval $(echo echo $(echo \$DIR_$1)))"
    }

    # delete bookmark
    function bm_d {
        _bookmark_name_valid "$@"
        if [ -z "$exit_message" ]; then
            _purge_line "$SDIRS" "export DIR_$1="
            unset "DIR_$1"
        fi
    }

    # list bookmarks with dirnam
    function bm_l {
        source $SDIRS
            
        # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
        env | sort | awk '/^DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
        
        # uncomment this line if color output is not working with the line above
        # env | grep "^DIR_" | cut -c5- | sort |grep "^.*=" 
    }

    if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
        echo ''
        echo 'mark <bookmark_name>    - Goes (cd) to the directory associated with "bookmark_name"'
        echo 'mark -s <bookmark_name> - Saves the current directory as "bookmark_name"'
        echo 'mark -p <bookmark_name> - Prints the directory associated with "bookmark_name"'
        echo 'mark -d <bookmark_name> - Deletes the bookmark'
        echo 'mark -l                 - Lists all available bookmarks'
    elif [ "$1" = "-s" ] || [ "$1" = "--save" ]; then
        bm_s ${@:2}
    elif [ "$1" = "-p" ] || [ "$1" = "--print" ]; then
        bm_p ${@:2}
    elif [ "$1" = "-d" ] || [ "$1" = "--delete" ]; then
        bm_d ${@:2}
    elif [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
        bm_l
    else
        bm_g $1
    fi
}

# list bookmarks without dirname, for autocompletion
function _l {
    source $SDIRS
    env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "=" 
}

# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="bookmark name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        echo $exit_message
    fi
}

# completion command
function _comp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_l`' -- $curw))
    return 0
}

# ZSH completion command
function _compzsh {
    reply=($(_l))
}

# safe delete line from sdirs
function _purge_line {
    if [ -s "$1" ]; then
        # safely create a temp file
        t=$(mktemp -t bashmarks.XXXXXX) || exit 1
        trap "/bin/rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        /bin/mv "$t" "$1"

        # cleanup temp file
        /bin/rm -f -- "$t"
        trap - EXIT
    fi
}

# bind completion command for g,p,d to _comp
if [ $ZSH_VERSION ]; then
    compctl -K _compzsh g
    compctl -K _compzsh p
    compctl -K _compzsh d
else
    shopt -s progcomp
    complete -F _comp g
    complete -F _comp p
    complete -F _comp d
fi
