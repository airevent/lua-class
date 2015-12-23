#

NAME = class
INSTALL_DIR = /home/pd/lib/lua

build:
	luac -o $(NAME).luac $(NAME).lua

clean:
	rm -f $(NAME).luac

install:
	cp $(NAME).luac $(INSTALL_DIR)/$(NAME).lua
