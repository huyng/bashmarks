INSTALL_DIR=~/.local/bin

all:
	@echo "Please run 'make install'"

install:
	@echo ""
	mkdir -vp $(INSTALL_DIR)
	cp -v bashmarks.sh $(INSTALL_DIR)
	@echo "bashmarks.sh installed ... "
	@echo "Please add 'source $(INSTALL_DIR)/bashmarks.sh' to your .bashrc file"
	@echo "bashmarks.sh installed ... "
	
help:

	@echo
	@echo 'USAGE: '
	@echo 'sv bookmarkname - saves the curr dir as bookmarkname'
	@echo 'gbm bookmarkname - jumps to the that bookmark'
	@echo 'gbm b[TAB] - tab completion is available'
	@echo 'pbm bookmarkname - prints the bookmark'
	@echo 'pbm b[TAB] - tab completion is available'
	@echo 'pbmi - print bookmarks using a menu'
	@echo 'dbm bookmarkname - deletes the bookmark'
	@echo 'dbm [TAB] - tab completion is available'
	@echo 'lbm - list all bookmarks'
	@echo

.PHONY: all install
