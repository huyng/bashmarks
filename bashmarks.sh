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
# POSSIBILITY OF SUCH DAMAGE.


# setup file to store bookmarks
if [ -z "$BASHMARKS_LIST_FILE" ]; then
	BASHMARKS_LIST_FILE=~/.bashmarkslist
fi
touch "$BASHMARKS_LIST_FILE"

RED="0;31m"
GREEN="0;33m"

# save current directory to bookmarks
bashmarks_save() {
	_bashmarks_check_help "$1"
	_bashmarks_bookmark_name_valid "$@"
	if [ -z "$exit_message" ]; then
		_bashmarks_purge_line "$BASHMARKS_LIST_FILE" "export DIR_$1="
		local CURDIR
		CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
		if [ -z "$2" ]; then
			echo "export DIR_$1=\"$CURDIR\"" >> "$BASHMARKS_LIST_FILE"
		else
			if [ -f "$2" ]; then
				CURDIR="${CURDIR}/$2"
				echo "export DIR_$1=\"$CURDIR\"" >> "$BASHMARKS_LIST_FILE"
			else
				echo "File doesn't exist"
			fi
		fi
	fi
}

# jump to bookmark
bashmarks_jump() {
	_bashmarks_check_help "$1"
	. "$BASHMARKS_LIST_FILE"
	local target
	target="$(eval "$(echo echo "$(echo \$DIR_$1)")")"
	if [ -z "$1" ] && [ -n "$BASHMARKS_DEFAULT_DIR" ]; then
		cd "$BASHMARKS_DEFAULT_DIR"
	elif [ -d "$target" ]; then
		cd "$target"
	elif [ -f "$target" ]; then
		"$EDITOR" "$target"
	elif [ -z "$target" ]; then
		echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
	else
		echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
	fi
}

# print bookmark
bashmarks_print() {
	_bashmarks_check_help "$1"
	. "$BASHMARKS_LIST_FILE"
	if [ -z "$1" ]; then
		# if color output is not working for you, comment out the line below '\033[1;32m' == "red"
		env | sort | awk '/^DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'

		# uncomment this line if color output is not working with the line above
		# env | grep "^DIR_" | cut -c5- | sort |grep "^.*="
	else
		echo "$(eval "$(echo echo "$(echo \$DIR_$1)")")"
	fi
}

# delete bookmark
bashmarks_delete() {
	_bashmarks_check_help "$1"
	_bashmarks_bookmark_name_valid "$@"
	if [ -z "$exit_message" ]; then
		_bashmarks_purge_line "$BASHMARKS_LIST_FILE" "export DIR_$1="
		unset "DIR_$1"
	fi
}

# print out help for the forgetful
_bashmarks_check_help() {
	if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
		echo 'bashmarks_save   <bookmark_name> - Saves the current directory or file as "bookmark_name"'
		echo 'bashmarks_jump   <bookmark_name> - Goes (cd) to the directory or open the file associated with "bookmark_name"'
		echo 'bashmarks_print  <bookmark_name> - Prints the directory or file associated with "bookmark_name"'
		echo 'bashmarks_print                  - Lists all available bookmarks (view dirs)'
		echo 'bashmarks_delete <bookmark_name> - Deletes the bookmark'
		kill -SIGINT $$
	fi
}

# list bookmarks without dirname
_bashmarks_list_without_dirname() {
	. "$BASHMARKS_LIST_FILE"
	env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "="
}

# validate bookmark name
_bashmarks_bookmark_name_valid() {
	exit_message=""
	if [ -z "$1" ]; then
		exit_message="Bookmark name required"
		echo "$exit_message"
	elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
		exit_message="Bookmark name is not valid"
		echo "$exit_message"
	fi
}

# completion command
_bashmarks_comp() {
	local curw
	COMPREPLY=()
	curw=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=($(compgen -W '`_bashmarks_list_without_dirname`' -- $curw))
	return 0
}

# ZSH completion command
_bashmarks_compzsh() {
	reply=($(_bashmarks_list_without_dirname))
}

# safe delete line from BASHMARKS_LIST_FILE
_bashmarks_purge_line() {
	if [ -s "$1" ]; then
		# safely create a temp file
		local t
		t=$(mktemp -t bashmarks.XXXXXX) || exit 1
		trap "/bin/rm -f -- '$t'" EXIT

		# purge line
		sed "/$2/d" "$1" >"$t"
		/bin/mv "$t" "$1"

		# cleanup temp file
		/bin/rm -f -- "$t"
		trap - EXIT
	fi
}

# bind completion command
if [ "$ZSH_VERSION" ]; then
	compctl -K _bashmarks_compzsh bashmarks_jump
	compctl -K _bashmarks_compzsh bashmarks_print
	compctl -K _bashmarks_compzsh bashmarks_delete
elif [ "$BASH_VERSION" ]; then
	shopt -s progcomp
	complete -F _bashmarks_comp bashmarks_jump
	complete -F _bashmarks_comp bashmarks_print
	complete -F _bashmarks_comp bashmarks_delete
fi
