OBJ_DIR:=out
SRCS=$(filter-out stub.asm, $(wildcard *.asm))
OBJS=$(patsubst %.asm, $(OBJ_DIR)/%.obj, $(SRCS))
LIBS=out/math.lib lib/kernel32.lib
DEFS:=

all: ex2000.exe
.PHONY: clean again

%.inc:
	copy $@+

%.asm:
	copy $@+

loaddll.inc: frame.inc
main.asm: loaddll.inc assets.inc math.inc tls.inc
assets.asm: loaddll.inc assets.inc avlbst.inc out/assets.cab
tls.asm: loaddll.inc tls.inc
timer.asm: loaddll.inc timer.inc
avlbst.asm: loaddll.inc avlbst.inc
loaddll.asm: loaddll.inc assets.inc
buffer.asm: loaddll.inc buffer.inc gl33.inc
gl33.asm: loaddll.inc gl33.inc assets.inc
pool.asm: loaddll.inc pool.inc
scene.asm: loaddll.inc timer.inc gl33.inc buffer.inc assets.inc shader.inc math.inc
shader.asm: loaddll.inc shader.inc gl33.inc

out/stub.bin: stub.asm
	nasm $^ -o $@
out/%.obj: %.asm
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	nasm -f win32 -g $(DEFS) $^ -o $@
out/assets.cab: $(wildcard assets/*)
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	cabarc -r -p -m LZX:21 N $@ assets\\*
out/math.lib: $(wildcard math/*)
	make -C math

ex2000.exe: $(OBJS) $(LIBS) out/stub.bin
	link /NOLOGO /NODEFAULTLIB /ENTRY:entry /INCREMENTAL:no /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OUT:$@ /DEBUG /STUB:out\\stub.bin /SUBSYSTEM:WINDOWS $(OBJS) $(LIBS)

clean:
	del /f /s /q out\\*.obj out\\*.cab out\\*.a out\\*.lib out\\*.bin *.gdb *.pdb ex2000.exe

again:
	make clean
	make all -j

run: ex2000.exe
	ex2000.exe
