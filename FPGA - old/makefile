# PROJECT = $(notdir $(CURDIR))
# SRC = $(wildcard *.c)
BDIR = build
VER = test
.PHONY: clean all

all:

	mkdir -p $(BDIR)
	ca65 -D $(VER) test.s -o $(BDIR)/$(VER).o
	ld65 -C $(VER).cfg $(BDIR)/$(VER).o -o $(BDIR)/$(VER).bin -Ln $(BDIR)/$(VER).lbl
	avr-objcopy -I binary $(BDIR)/$(VER).bin -O ihex $(BDIR)/$(VER).hex
clean:
	rm -f $(BDIR)/*.o $(BDIR)/*.hex $(BDIR)/*.bin $(BDIR)/*.lbl