all:
	@echo "Pleas run 'make install'"

install:
	mkdir -p ~/.local/bin/
	cp bashmarks.sh ~/.local/bin/
	@echo "Add 'source ~/.local/bin/bashmarks.sh' to your .bashrc file"