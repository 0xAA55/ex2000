
OBJS=out/main.obj out/timer.obj out/scene.obj out/assets.obj out/avlbst.obj out/pool.obj out/buffer.obj out/shader.obj out/gl33.obj out/loaddll.obj
LIBS=out/libmath.a
FILES=out/assets.cab
LDFLAGS=-Lout --whole-archive --relax --large-address-aware --build-id
LDLIBS=-lmath

all: ex2000.exe ex2000.pdb
.PHONY: clean

loaddll.inc: frame.inc
main.asm: loaddll.inc assets.inc
assets.asm: loaddll.inc assets.inc avlbst.inc out/assets.cab
timer.asm: loaddll.inc timer.inc
avlbst.asm: loaddll.inc avlbst.inc
loaddll.asm: loaddll.inc
buffer.asm: loaddll.inc buffer.inc gl33.inc
gl33.asm: loaddll.inc gl33.inc
pool.asm: loaddll.inc pool.inc
scene.asm: loaddll.inc timer.inc gl33.inc buffer.inc assets.inc shader.inc math.inc
shader.asm: loaddll.inc shader.inc gl33.inc

out:
	mkdir out
out/%.obj: %.asm
	nasm -f elf32 -g $^ -o $@
out/assets.cab: $(wildcard assets/*)
	cabarc -r -p -m LZX:21 N $@ assets\\*
out/libmath.a: $(wildcard math/*)
	make -C math

ex2000.exe: $(OBJS) $(LIBS) $(FILES)
	ld.exe -o $@ -nostdlib -mi386pe -subsystem windows -e _start $(OBJS) $(LDFLAGS) $(LDLIBS)
ex2000.pdb: ex2000.exe
	cv2pdb $^
	strip --strip-debug --strip-unneeded $^

clean:
	del /f /s /q out\\*.obj out\\*.cab out\\*.a *.gdb *.pdb
