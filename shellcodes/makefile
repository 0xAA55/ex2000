OUT_DIR:=../out
SRCS=$(filter-out shellcode.asm, $(wildcard *.asm))
BINS=$(patsubst %.asm, %.bin, $(SRCS))
DEFS:=
ASMFLAGS=-i..

%.inc:
	copy $@+ >nul 2>&1

%.asm: common.inc
	copy $@+ >nul 2>&1

all: shellcode.bin
shellcode.asm: $(BINS) ../shellcode.inc
../shellcode.inc: ../scfuncs.tmp ../glfuncs.tmp
../loaddll.inc: ../frame.inc ../expfuncs.tmp
common.inc: ../frame.inc ../math.inc ../shellcode.inc

%.bin: %.asm
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm $(DEFS) $(ASMFLAGS) $^ -o $@

clean:
	del /f /q *.bin
