
OBJS=out/main.obj out/timer.obj out/scene.obj out/assets.obj out/avlbst.obj out/pool.obj out/buffer.obj out/shader.obj out/gl33.obj out/loaddll.obj
LIBS=out/libmath.a
FILES=out/assets.cab
LDFLAGS=-Lout --relax --large-address-aware --build-id -T ex2000.ld
LDLIBS=--whole-archive -lmath

all: ex2000.exe ex2000d.exe
debug: ex2000d.exe
release: ex2000.exe
.PHONY: clean again againd

%.inc:
	copy $@+

%.asm:
	copy $@+

loaddll.inc: frame.inc
main.asm: loaddll.inc assets.inc math.inc
assets.asm: loaddll.inc assets.inc avlbst.inc out/assets.cab
timer.asm: loaddll.inc timer.inc
avlbst.asm: loaddll.inc avlbst.inc
loaddll.asm: loaddll.inc assets.inc
buffer.asm: loaddll.inc buffer.inc gl33.inc
gl33.asm: loaddll.inc gl33.inc
pool.asm: loaddll.inc pool.inc
scene.asm: loaddll.inc timer.inc gl33.inc buffer.inc assets.inc shader.inc math.inc
shader.asm: loaddll.inc shader.inc gl33.inc

out/%.obj: %.asm
	if not exist out mkdir out
	nasm -f elf32 -g $^ -o $@
out/assets.cab: $(wildcard assets/*)
	if not exist out mkdir out
	cabarc -r -p -m LZX:21 N $@ assets\\*
out/libmath.a: $(wildcard math/*)
	if not exist out mkdir out
	make -C math

ex2000.exe: $(OBJS) $(LIBS) $(FILES) ex2000.ld
	ld.exe -o $@ -nostdlib -mi386pe -subsystem windows $(OBJS) $(LDFLAGS) $(LDLIBS)
	objcopy --only-keep-debug $@ ex2000.gdb
	strip $@
ex2000d.exe: $(OBJS) $(LIBS) $(FILES) ex2000.ld
	ld.exe -o $@ -nostdlib -mi386pe $(OBJS) $(LDFLAGS) $(LDLIBS)

clean:
	del /f /s /q out\\*.obj out\\*.cab out\\*.a *.gdb *.pdb ex2000.exe ex2000d.exe

again:
	make clean
	make all -j

againd:
	make clean
	make debug -j

againr:
	make clean
	make release -j
