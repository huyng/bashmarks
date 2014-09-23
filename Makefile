INSTALL_DIR=~/.local/bin

all:
	@echo "Please run 'make install'"

install:
	@echo ""
	mkdir -p $(INSTALL_DIR)
	cp bashmarks.sh $(INSTALL_DIR)
	@echo ""
	@echo "Please add 'source $(INSTALL_DIR)/bashmarks.sh' to your .bashrc file"
	@echo ''
	@echo 'USAGE:'
	@echo '------'
	@echo 'bms <bookmark_name> - Saves the current directory as "bookmark_name"'
	@echo 'bmg <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
	@echo 'bmp <bookmark_name> - Prints the directory associated with "bookmark_name"'
	@echo 'bmd <bookmark_name> - Deletes the bookmark'
	@echo 'bml                 - Lists all available bookmarks'
