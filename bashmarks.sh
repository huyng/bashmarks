#!/bin/bash
# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 

BM_FILE=${HOME}/.bm.txt
COLOR_ENABLED=1
COLOR_OFF='\e[0m'       # Text Reset
BGREEN='\e[1;32m'       # Green
BRED='\e[1;31m'         # Red

bookmarks_help() {
cat <<BOOKMARKS_HELP
 
USAGE: 
bmsv bookmarkname - saves the curr dir as bookmarkname
bmsv bookmarkname tag1:tag2:tag3
bmg bookmarkname - jumps to the that bookmark
bmg b[TAB] - tab completion is available
bmp bookmarkname - prints the bookmark
bmp b[TAB] - tab completion is available
bmpi - print bookmarks using a menu
bmd bookmarkname - deletes the bookmark
bmd [TAB] - tab completion is available
bmra - Remove all bookmarks
bml - list all bookmarks

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

# Remove all bookmarks.
bmra() {
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
bmg() {
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
bmp() {

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
bmd() {
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
bmsv() {
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
bmpi() {
    local BOOKMARK_OPT_TXT=$PS3
    PS3="Bookmark number: "
    select _OPTION in `ls_bookmarks`; do
        bmp "${_OPTION}"
        break
    done
    PS3="$BOOKMARK_OPT_TXT"
}

# List bookmarks
bml() {
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
complete -F _comp bmg
complete -F _comp bmp
complete -F _comp bmd

