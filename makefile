# PROJECT = $(notdir $(CURDIR))
# SRC = $(wildcard *.c)
BDIR = build
VER = eater
.PHONY: clean all

all:
	@echo "still not yet"
	make basic



basic:
	mkdir -p $(BDIR)
	ca65 -D $(VER) msbasic.s -o $(BDIR)/$(VER).o
	ld65 -C $(VER).cfg $(BDIR)/$(VER).o -o $(BDIR)/$(VER).bin -Ln $(BDIR)/$(VER).lbl
	
clean:
	rm -f $(BDIR)/*.o $(BDIR)/*.hex $(BDIR)/*.bin $(BDIR)/*.lbl