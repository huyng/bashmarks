### Bashmarks is a shell script that allows you to save and jump to commonly used directories. Now supports tab completion.

## Install

1. git clone git://github.com/chunkily/bashmarks.git
2. cd bashmarks
3. make install
4. source **~/.local/bin/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file

## Shell Commands

    mark <bookmark_name>    - Goes (cd) to the directory associated with "bookmark_name"
    mark -s <bookmark_name> - Saves the current directory as "bookmark_name"
    mark -p <bookmark_name> - Prints the directory associated with "bookmark_name"
    mark -d <bookmark_name> - Deletes the bookmark
    mark -l                 - Lists all available bookmarks
    mark -h                 - Shows this help

## Example Usage

    $ cd /var/www/
    $ mark -s webfolder
    $ cd /usr/local/lib/
    $ mark -s locallib
    $ mark -l
    $ mark web<tab>
    $ mark webfolder

## Recommended alias shortcut

Use aliases to allow invocation with a single letter command for maximum efficiency.

    $ alias g='mark'
    $ g locallib

## Where Bashmarks are stored
    
All of your directory bookmarks are saved in a file called ".sdirs" in your HOME directory.

## Migrating from original bashmarks

Use aliases to get the original behavior. Put the following in your **~.bash\_profile** or **~/.bashrc** file.

    alias g='mark'
    alias s='mark -s'
    alias p='mark -p'
    alias d='mark -d'
    alias l='mark -l'
