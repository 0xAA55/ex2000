OUT_DIR:=../out
SRCS=$(filter-out shellcode.asm, $(wildcard *.asm))
INCS=$(wildcard *.inc)
OBJS=shellcode.obj $(patsubst %.asm, %.obj, $(SRCS))
DEFS:=
ASMFLAGS=-i..

all: shellcode.bin

../%.inc:
	copy /b ..\\$(notdir $@)+ >nul 2>&1
%.inc:
	copy /b $@+ >nul 2>&1
%.asm: common.inc
	copy /b $@+ >nul 2>&1
%.obj: %.asm
	nasm -f win32 $(DEFS) $(ASMFLAGS) $^ -o $@

../loaddll.inc: ../frame.inc ../expfuncs.tmp
../shellcode.inc: ../scfuncs.tmp ../glfuncs.tmp
common.inc: ../loaddll.inc ../math.inc ../shellcode.inc
tls.asm: common.inc ../tls.inc
lfu.asm: common.inc ../lfu.inc ../avlbst.inc
buffer.asm: common.inc ../gl33.inc ../buffer.inc
fontgl.asm: common.inc ../avlbst.inc ../shader.inc ../buffer.inc ../fontgl.inc
hrsleep.asm: common.inc ../hrsleep.inc
shader.asm: common.inc ../shader.inc ../gl33.inc ../assets.inc
timer.asm: common.inc ../timer.inc ../hrsleep.inc

shellcode.dll: $(OBJS) exports.def
	link /NOLOGO /NODEFAULTLIB /NOENTRY /BASE:0x70000000 /DYNAMICBASE:NO /DLL /DEF:exports.def /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /IGNORE:4254 /MERGE:.edata=.zzz /MERGE:.rdata=.data /MERGE:.data=.code /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$@ /DEBUG /PDBALTPATH:%_PDB% $(OBJS)

shellcode.bin: shellcode.dll
	objcopy -j .code -O binary shellcode.dll shellcode.bin

clean:
	del /f /q *.obj shellcode.dll
