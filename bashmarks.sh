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
# POSSIBILITY OF SUCH DAMAGE.


# USAGE: 
# s bookmarkname - saves the curr dir as bookmarkname
# g bookmarkname - jumps to the that bookmark
# g b[TAB] - tab completion is available
# p bookmarkname - prints the bookmark
# p b[TAB] - tab completion is available
# d bookmarkname - deletes the bookmark
# d [TAB] - tab completion is available
# l - list all bookmarks

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch $SDIRS

# save current directory to bookmarks
function s {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
        echo "export DIR_$1=\"$CURDIR\"" >> $SDIRS
    fi
}

# jump to bookmark
function g {
    check_help $1
    source $SDIRS
    cd "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# print bookmark
function p {
    check_help $1
    source $SDIRS
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# delete bookmark
function d {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        unset "DIR_$1"
    fi
}

# print out help for the forgetful
function check_help {
    if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
        echo ''
        echo 's <bookmark_name> - Saves the current directory as "bookmark_name"'
        echo 'g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
        echo 'p <bookmark_name> - Prints the directory associated with "bookmark_name"'
        echo 'd <bookmark_name> - Deletes the bookmark'
        echo 'l                 - Lists all available bookmarks'
        kill -SIGINT $$
    fi
}

# list bookmarks with dirnam
function l {
    check_help $1
    source $SDIRS
        
    # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
    env | sort | awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[1;31m%-20s\033[0m %s\n", parts[1], parts[2]);}'
    
    # uncomment this line if color output is not working with the line above
    # env | grep "^DIR_" | cut -c5- | sort |grep "^.*=" 
}
# list bookmarks without dirname
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
        trap "rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        mv "$t" "$1"

        # cleanup temp file
        rm -f -- "$t"
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
