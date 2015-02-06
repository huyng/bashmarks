#!/bin/bash
# Copyright (c) 2015, Leonardo Gutiérrez R
# leogutierrezramirez@gmail.com

BM_FILE=${HOME}/.bm.txt
COLOR_ENABLED=1
COLOR_OFF='\e[0m'       # Text Reset
BGREEN='\e[1;32m'       # Green
BRED='\e[1;31m'         # Red

bookmarks_help() {
cat <<BOOKMARKS_HELP
 
USAGE: 
sv bookmarkname - saves the curr dir as bookmarkname
gbm bookmarkname - jumps to the that bookmark
gbm b[TAB] - tab completion is available
pbm bookmarkname - prints the bookmark
pbm b[TAB] - tab completion is available
pbmi - print bookmarks using a menu
dbm bookmarkname - deletes the bookmark
dbm [TAB] - tab completion is available
d_c - Remove all bookmarks
lbm - list all bookmarks

BOOKMARKS_HELP
}

is_valid() {
    [[ "$1" =~ ^[a-zA-Z0-9_]+$ ]] && return 0 || return 1
}

ask () { 
    read -p "$@ [y/n] " ans
    case "$ans" in 
        y*|Y*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}

d_c() {
    if ask "Remove all bookmarks"; then
        sed -n -i '1,$d' "${BM_FILE}"
    fi
}

# Add bookmark
add_bookmark() {
    if [ -z "$1" ]; then
        bookmarks_help
    else
        printf "%s=%s\n" "$1" "$PWD" >> "${BM_FILE}"
    fi
}

# List bookmark
ls_bookmarks() {
    [ -f "${BM_FILE}" ] && {
        awk -F '=' '{print $1}' "${BM_FILE}"
    } || {
        echo -e "Bookmarks file does not exist."
        [ $COLOR_ENABLED -eq 1 ] && {
            echo -e "${BRED}Bookmarks file does not exist.${COLOR_OFF}"
        } || {
            echo -e "Bookmarks file does not exist."
        }
    }
}

# Go to bookmark
gbm() {
    if [ ! -z "$1" ]; then
        local TARGET=`grep -E "^$1" "${BM_FILE}" | awk -F '=' '{print $2}'`
        cd "${TARGET}"
    else
        [ $COLOR_ENABLED -eq 1 ] && {
            echo -e "${BRED}Bookmark NOT found.${COLOR_OFF}"
        } || {
            echo -e "Bookmark NOT found."
        }
    fi
}

# Print bookmark
pbm() {

    [ -z "$1" ] && {
        bookmarks_help
        return 1
    }

    local BOOKMARK="$1"
    grep -Eq "^${BOOKMARK}.*" "${BM_FILE}" && {
        local BM_PATH=`grep -E "^${BOOKMARK}.*" "${BM_FILE}" | awk -F '=' '{print $2}'`
        if [ $COLOR_ENABLED -eq 1 ]; then
            printf "${BGREEN}%s ${COLOR_OFF} -> %s\n" "${BOOKMARK}" "${BM_PATH}"
        else
            printf "%s -> %s\n" "${BOOKMARK}" "${BM_PATH}"
        fi
    } || {
        [ $COLOR_ENABLED -eq 1 ] && {
            echo -e "${BRED}Bookmark NOT found.${COLOR_OFF}"
        } || {
            echo -e "Bookmark NOT found."
        }
    }
}

# Delete bookmark
dbm() {
    local BOOKMARK="$1"
    grep -Eq "^${BOOKMARK}.*" "${BM_FILE}" && {
        sed -i "/^${BOOKMARK}/d" "${BM_FILE}"
    } || {
        [ $COLOR_ENABLED -eq 1 ] && {
            echo -e "${BRED}Bookmark NOT found.${COLOR_OFF}"
        } || {
            echo -e "Bookmark NOT found."
        }   
    }
}

# Save bookmark 
sv() {
    if [ ! -z "$1" ]; then
        if is_valid "$1"; then
            add_bookmark "$1"
        else
            [ $COLOR_ENABLED -eq 1 ] && {
            echo -e "${BRED}Bookmark NOT valid.${COLOR_OFF}"
        } || {
            echo -e "Bookmark NOT valid."
        }
        fi
    else
        bookmarks_help
    fi
}

# Print bookmarks using select
pbmi() {
    local BOOKMARK_OPT_TXT=$PS3
    PS3="Bookmark number: "
    select _OPTION in `ls_bookmarks`; do
        pbm "${_OPTION}"
        break
    done
    PS3="$BOOKMARK_OPT_TXT"
}

# List bookmarks
lbm() {
    [ -f "${BM_FILE}" ] && {
        awk -F '=' '{print $1}' "${BM_FILE}"
    } || {
        echo -e "Bookmarks file does not exist."
    }   
}

# completion command
function _comp {
    COMPREPLY=()
    local curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`ls_bookmarks`' -- $curw))
    return 0
}

shopt -s progcomp
complete -F _comp gbm
complete -F _comp pbm
complete -F _comp dbm
