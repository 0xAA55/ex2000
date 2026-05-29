
OBJS=out/main.obj out/timer.obj out/scene.obj out/assets.obj out/avlbst.obj out/tls.obj out/pool.obj out/buffer.obj out/shader.obj out/gl33.obj out/loaddll.obj
LIBS=out/math.lib
FILES=out/assets.cab

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
	if not exist out mkdir out
	nasm -f win32 -g $^ -o $@
out/assets.cab: $(wildcard assets/*)
	if not exist out mkdir out
	cabarc -r -p -m LZX:21 N $@ assets\\*
out/math.lib: $(wildcard math/*)
	if not exist out mkdir out
	make -C math

ex2000.exe: $(OBJS) $(LIBS) $(FILES) out/stub.bin
	link /NOLOGO /NODEFAULTLIB /ENTRY:entry /INCREMENTAL:no /LARGEADDRESSAWARE /LIBPATH:out /LIBPATH:lib /MACHINE:X86 /OPT:REF /OUT:$@ /DEBUG /STUB:out\\stub.bin /SUBSYSTEM:WINDOWS $(OBJS) $(LIBS)

clean:
	del /f /s /q out\\*.obj out\\*.cab out\\*.a out\\*.lib out\\*.bin *.gdb *.pdb ex2000.exe

again:
	make clean
	make all -j
