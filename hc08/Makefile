TARGET := wall
ASM := /projects/hc08/freeasm8/Linux/asm8
STDINC := /projects/hc08/inc

.PHONY: clean

all: $(TARGET).s19

$(TARGET).s19: $(TARGET).asm
	$(ASM) -I$(STDINC) $^

clean: 
	rm $(TARGET).lst $(TARGET).map $(TARGET).s19

