C64SYS?=c64
C64AS?=ca65
C64LD?=ld65
VICE?=x64sc

C64ASFLAGS?=-t $(C64SYS) -g

ifdef RAWBIN
BINEXT=bin
EXTRAOBJ=
else
BINEXT=prg
EXTRAOBJ=obj/ldaddr.o
endif

basicmusic_LDCFG:=src/basicmusic.cfg
basicmusic_OBJS:=$(addprefix obj/,define.o player.o pattern.o \
	pitches.o rtdata.o)
basicmusic_BIN:=basicmusic.$(BINEXT)
basicmusic_LABLES:=basicmusic.lbl
basicmusic_MAP:=basicmusic.map

all: $(basicmusic_BIN)

run: all
	$(VICE) -autostart $(basicmusic_BIN) -moncommands $(basicmusic_LABLES)

$(basicmusic_BIN) $(basicmusic_LABLES) $(basicmusic_MAP): \
	$(basicmusic_OBJS) $(EXTRAOBJ)
	$(C64LD) -o$@ -C$(basicmusic_LDCFG) -Ln $(basicmusic_LABLES) \
		-m $(basicmusic_MAP) $^

obj:
	mkdir obj

obj/%.o: src/%.s src/basicmusic.cfg Makefile | obj
	$(C64AS) $(C64ASFLAGS) -o$@ $<

clean:
	rm -fr obj *.lbl *.map

distclean: clean
	rm -f $(basicmusic_BIN)

.PHONY: all run clean distclean

