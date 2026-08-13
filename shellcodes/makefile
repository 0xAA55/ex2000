OUT_DIR:=../out
SRCS=$(filter-out shellcode.asm, $(wildcard *.asm))
BINS=$(patsubst %.asm, %.bin, $(SRCS))
DEFS:=
ASMFLAGS=-i..

%.inc:
	copy $@+

%.asm: common.inc
	copy $@+

all: shellcode.bin
shellcode.asm: $(BINS) ../shellcode.inc ../scfuncs.tmp
../loaddll.inc: ../frame.inc ../expfuncs.tmp
common.inc: ../loaddll.inc

%.bin: %.asm
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm $(DEFS) $(ASMFLAGS) $^ -o $@

clean:
	del /f /q *.bin
