### Bashmarks is a shell script that allows you to save and jump to commonly used directories. Now supports tab completion.

## Install

1. git clone git://github.com/huyng/bashmarks.git
2. make install
3. source **~/.local/bin/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file

## Shell Commands

    bms <bookmark_name> - Saves the current directory as "bookmark_name"
    bmg <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"
    bmp <bookmark_name> - Prints the directory associated with "bookmark_name"
    bmd <bookmark_name> - Deletes the bookmark
    bml                 - Lists all available bookmarks
    
## Example Usage

    $ cd /var/www/
    $ bms webfolder
    $ cd /usr/local/lib/
    $ bms locallib
    $ bml
    $ bmg web<tab>
    $ bmg webfolder

## Where Bashmarks are stored
    
All of your directory bookmarks are saved in a file called ".sdirs" in your HOME directory.
