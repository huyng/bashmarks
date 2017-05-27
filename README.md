### Bashmarks is a shell script that allows you to save and jump to commonly used directories. Now supports tab completion.

## Install

1. git clone https://github.com/leogtzr/bashmarks.git
2. cd bashmarks
3. make install
4. source **~/.local/bin/bashmarks.sh** from within your **~/.bash\_profile** or **~/.bashrc** file

## Shell Commands

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
    
## Example Usage

	$ cd /var/www/
	$ bmsv webfolder
	$ cd /usr/local/lib/
	$ bmsv locallib
	$ bml
	$ bmg web<tab>
	$ bmg webfolder

	[leo@~]$ cd /var/www/
	[leo@www]$ bmsv webfolder
	[leo@www]$ cd /usr/local/lib/
	[leo@lib]$ bmsv libdir
	[leo@lib]$ bml
	webfolder
	libdir
	[leo@lib]$ bmg webfolder 
	[leo@www]$ bmpi 
	1) webfolder
	2) libdir
	Bookmark number: 2
	[leo@lib]$ pwd
	/usr/local/lib
	[leo@lib]$ 

## Where Bashmarks are stored
    
All of your directory bookmarks are saved in a file called ".bm.txt" ($HOME/.bm.txt) in your $HOME directory.
