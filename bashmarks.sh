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


# enable custom tab completion
# USAGE: 
# s bookmarkname - saves the curr dir as bookmarkname
# g bookmarkname - jumps to the that bookmark
# g b[TAB] - tab completion is available
# p bookmarkname - prints the bookmark
# p b[TAB] - tab completion is available
# d bookmarkname - deletes the bookmark
# d[TAB] - tab completion is available
# l - list all bookmarks

# save current directory to bookmarks
touch ~/.sdirs

function s {
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
	cat ~/.sdirs | grep -v "export DIR_$1=" > ~/.sdirs1
	mv ~/.sdirs1 ~/.sdirs
	echo "export DIR_$1='$PWD'" >> ~/.sdirs
    fi
}

# jump to bookmark
function g {
    source ~/.sdirs
    cd "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# print bookmark
function p {
    source ~/.sdirs
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# delete bookmark
function d {
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
	cat ~/.sdirs | grep -v "export DIR_$1=" > ~/.sdirs1
	mv ~/.sdirs1 ~/.sdirs
	unset "DIR_$1"
    fi
}

# list bookmarks with dirnam
function l {
    source ~/.sdirs
    env | grep "^DIR_" | cut -c5- | grep "^.*="
}
# list bookmarks without dirname
function _l {
    source ~/.sdirs
    env | grep "^DIR_" | cut -c5- | grep "^.*=" | cut -f1 -d "="
}

# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
	exit_message="bookmark name required"
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

# ZSH _gcomp function
function _compzsh {
    reply=($(_l))
}

# bind completion command for g,p,d to _comp
if [ $ZSH_VERSION ]; then
    compctl -K _gcompzsh g
    compctl -K _gcompzsh p
    compctl -K _gcompzsh d
else
    shopt -s progcomp       
    complete -F _comp g
    complete -F _comp p
    complete -F _comp d
fi
