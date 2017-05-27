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

BM_FILE="${HOME}/.bm.txt"
COLOR_ENABLED=1
COLOR_OFF='\e[0m'       # Text Reset
BGREEN='\e[1;32m'       # Green
BRED='\e[1;31m'         # Red

bookmarks_help() {
cat <<BOOKMARKS_HELP
 
USAGE: 
bmsv bookmarkname - saves the curr dir as bookmarkname
bmg bookmarkname - jumps to the that bookmark
bmg b[TAB] - tab completion is available
bmp bookmarkname - prints the bookmark
bmp b[TAB] - tab completion is available
bmpi - print bookmarks using a menu
bmd bookmarkname - deletes the bookmark
bmd [TAB] - tab completion is available
bmra - Remove all bookmarks
bml - list all bookmarks
bmh - shows this help

BOOKMARKS_HELP
}

# Checks if a bookmark identifier is valid.
is_valid() {
    [[ "${1}" =~ ^[a-zA-Z0-9_]+$ ]]
}

ask () { 
    read -p "${@} [y/n] " ans
    echo "${ans}" | grep --quiet --ignore-case "^y$"
}

_show_error_message() {
    if [[ ! -z "${1}" ]]; then
        if ((COLOR_ENABLED == 1)); then
            echo -e "${BRED}${1}${COLOR_OFF}"   
        else
            echo "${1}"
        fi
    fi
}

# Remove all bookmarks.
bmra() {
    if ask "Remove all bookmarks"; then
        sed --quiet --in-place '1,$d' "${BM_FILE}"
    fi
}

    # Add bookmark
add_bookmark() {
    if [[ -z "${1}" ]]; then
        bookmarks_help
        return 1
    else
        printf "%s=%s\n" "$1" "$PWD" >> "${BM_FILE}"
    fi
}

# List bookmark
ls_bookmarks() {
    if [[ -f "${BM_FILE}" ]]; then
        awk -F '=' '{print $1}' "${BM_FILE}"
    else
        _show_error_message "Bookmarks file does not exist ... "
        return 1
    fi
}

# Go to bookmark
bmg() {
    if [[ ! -z "${1}" ]]; then
        local -r TARGET=$(grep --extended-regexp "^$1" "${BM_FILE}" | awk -F '=' '{print $2}')
        if [[ -z "${TARGET}" ]]; then
            _show_error_message "Bookmark '${1}' not found ... "
            return 1
        fi
        cd "${TARGET}"
    else
        _show_error_message "Bookmark empty ... "
        return 1
    fi
}

# Print bookmark
bmp() {

    if [[ -z "$1" ]]; then
        bookmarks_help
        return 1
    fi

    local -r BOOKMARK="${1}"
    if grep --extended-regexp --quiet "^${BOOKMARK}.*" "${BM_FILE}"; then
        local -r BM_PATH=$(grep -E "^${BOOKMARK}.*" "${BM_FILE}" | awk -F '=' '{print $2}')
        if ((COLOR_ENABLED == 1)); then
            printf "${BGREEN}%s ${COLOR_OFF} -> %s\n" "${BOOKMARK}" "${BM_PATH}"
        else
            printf "%s -> %s\n" "${BOOKMARK}" "${BM_PATH}"
        fi
    else
        _show_error_message "Bookmark '${BOOKMARK}' does not exist."
        return 1
    fi
}

# Delete bookmark
bmd() {
    local -r BOOKMARK="$1"
    if grep --extended-regexp --quiet "^${BOOKMARK}.*" "${BM_FILE}"; then
        sed --in-place "/^${BOOKMARK}/d" "${BM_FILE}"
    else
        _show_error_message "Bookmark '${BOOKMARK}' does not exist."
        return 1
    fi
}

# Save bookmark 
bmsv() {
    if [[ ! -z "${1}" ]]; then
        if is_valid "${1}"; then
            add_bookmark "${1}"
        else
            _show_error_message "'${1}' is not valid."
            return 1
        fi
    else
        bookmarks_help
        return 1
    fi
}

# Print bookmarks using select
bmpi() {
    local -r BOOKMARK_OPT_TXT="${PS3}"
    local _OPTION
    PS3="Bookmark number: "
    select _OPTION in $(ls_bookmarks); do
        bmp "${_OPTION}"
        break
    done
    PS3="${BOOKMARK_OPT_TXT}"
}

# List bookmarks
bml() {
    if [[ -f "${BM_FILE}" ]]; then
        awk -F '=' '{print $1}' "${BM_FILE}"
    else
        _show_error_message "Bookmarks file does not exist, please check your installation ... "
        return 1
    fi
}

# Shows help ... 
bmh() {
    bookmarks_help
}

# completion command
_comp() {
    COMPREPLY=()
    local -r curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '$(ls_bookmarks)' -- ${curw}))
    return 0
}

shopt -s progcomp
complete -F _comp bmg
complete -F _comp bmp
complete -F _comp bmd

