### Bashmarks is a shell script that allows you to save and jump to commonly used directories. Now supports tab completion.

## Install

1. git clone https://github.com/leogtzr/bashmarks.git
2. cd bashmarks
3. make install
4. source **~/.local/bin/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file

## Shell Commands

    USAGE: 
	sv bookmarkname  - Saves the current directory as "bookmark_name"
	gbm bookmarkname - Goes (cd) to the directory associated with "bookmark_name"
	gbm b[TAB] 		 - tab completion is available
	pbm bookmarkname - Prints the directory associated with "bookmark_name"
	pbm b[TAB]       - tab completion is available
	pbmi         	 - print bookmarks using a menu
	dbm bookmarkname - Deletes the bookmark
	dbm b[TAB] 		 - tab completion is available
	lbm 			 - Lists all available bookmarks
	d_c 			 - Remove all bookmarks
    
## Example Usage

	$ cd /var/www/
	$ sv webfolder
	$ cd /usr/local/lib/
	$ sv locallib
	$ lbm
	$ gbm web<tab>
	$ gbm webfolder

	[leo@~]$ cd /var/www/
	[leo@www]$ sv webfolder
	[leo@www]$ cd /usr/local/lib/
	[leo@lib]$ sv libdir
	[leo@lib]$ lbm
	webfolder
	libdir
	[leo@lib]$ gbm webfolder 
	[leo@www]$ pbmi 
	1) webfolder
	2) libdir
	Bookmark number: 2
	[leo@lib]$ pwd
	/usr/local/lib
	[leo@lib]$ 

## Where Bashmarks are stored
    
All of your directory bookmarks are saved in a file called ".bm.txt" ($HOME/.bm.txt) in your $HOME directory.
