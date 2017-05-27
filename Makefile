INSTALL_DIR=~/.local/bin

all:
	@echo "Please run 'make install'"

install:
	@echo ""
	mkdir -vp $(INSTALL_DIR)
	cp -v bashmarks.sh $(INSTALL_DIR)
	@echo "bashmarks.sh installed ... "
	@echo "Please add 'source $(INSTALL_DIR)/bashmarks.sh' to your ~/.bashrc file"
	@echo "bashmarks.sh installed ... "
	
help:

	@echo
	@echo 'USAGE: '
	@echo 'bmsv bookmarkname - saves the curr dir as bookmarkname'
	@echo 'bmg bookmarkname - jumps to the that bookmark'
	@echo 'bmg b[TAB] - tab completion is available'
	@echo 'bmp bookmarkname - prints the bookmark'
	@echo 'bmp b[TAB] - tab completion is available'
	@echo 'bmpi - print bookmarks using a menu'
	@echo 'bmd bookmarkname - deletes the bookmark'
	@echo 'bmd [TAB] - tab completion is available'
	@echo 'bmra - Remove all bookmarks'
	@echo 'bml - list all bookmarks'
	@echo 'bmh - shows this help'
	@echo

.PHONY: all install
