INSTALL_DIR=~/.local/bin

all:
	@echo "Pleas run 'make install'"

install:
	@echo ""
	mkdir -p $(INSTALL_DIR)
	cp bashmarks.sh $(INSTALL_DIR)
	@echo ""
	@echo "Please add 'source $(INSTALL_DIR)/bashmarks.sh' to your .bashrc file"
	@echo ''
	@echo 'USAGE:'
	@echo '------'
	@echo 's <bookmark_name> - Saves the current directory as "bookmark_name"'
	@echo 'g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
	@echo 'p <bookmark_name> - Prints the directory associated with "bookmark_name"'
	@echo 'd <bookmark_name> - Deletes the bookmark'
	@echo 'l                 - Lists all available bookmarks'
