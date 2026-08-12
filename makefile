OBJ_DIR:=out
SRCS=$(filter-out stub.asm shellcode.asm, $(wildcard *.asm))
OBJS=$(patsubst %.asm, $(OBJ_DIR)/%.obj, $(SRCS))
OBJS_D=$(patsubst %.asm, $(OBJ_DIR)/%_d.obj, $(SRCS))
LIBS=out/math.lib lib/kernel32.lib
DEFS:=
ASMFLAGS=-i. -ishellcodes

all: ex2000.exe
.PHONY: clean again

%.inc:
	copy $@+

%.asm:
	copy $@+

expfuncs.tmp: assets/KFUNC assets/UFUNC assets/CFUNC assets/GFUNC assets/WFUNC
	break>$@
	addpre assets\\KFUNC import_dll_func $@
	addpre assets\\UFUNC import_dll_func $@
	addpre assets\\CFUNC import_dll_func $@
	addpre assets\\GFUNC import_dll_func $@
	addpre assets\\WFUNC import_dll_func $@
scfuncs.tmp: assets/KFUNC assets/UFUNC assets/CFUNC assets/GFUNC assets/WFUNC
	break>$@
	addpre assets\\KFUNC DefImp $@
	addpre assets\\UFUNC DefImp $@
	addpre assets\\CFUNC DefImp $@
	addpre assets\\GFUNC DefImp $@
	addpre assets\\WFUNC DefImp $@
kfuncs.tmp: assets/KFUNC
	break>$@
	addpre assets\\KFUNC def_dll_func_addr $@
ufuncs.tmp: assets/UFUNC
	break>$@
	addpre assets\\UFUNC def_dll_func_addr $@
cfuncs.tmp: assets/CFUNC
	break>$@
	addpre assets\\CFUNC def_dll_func_addr $@
gfuncs.tmp: assets/GFUNC
	break>$@
	addpre assets\\GFUNC def_dll_func_addr $@
wfuncs.tmp: assets/WFUNC
	break>$@
	addpre assets\\WFUNC def_dll_func_addr $@
loaddll.inc: frame.inc expfuncs.tmp
shader.inc: gl33.inc
fontgl.inc: buffer.inc
shellcode.inc: scfuncs.tmp
main.asm: loaddll.inc assets.inc math.inc tls.inc vblank.inc
assets.asm: loaddll.inc assets.inc avlbst.inc out/assets.cab
tls.asm: loaddll.inc tls.inc
timer.asm: loaddll.inc timer.inc hrsleep.inc
avlbst.asm: loaddll.inc avlbst.inc
lfu.asm: loaddll.inc avlbst.inc lfu.inc
fontgl.asm: loaddll.inc fontgl.inc avlbst.inc lfu.inc math.inc gl33.inc shader.inc utf.inc
loaddll.asm: loaddll.inc assets.inc kfuncs.tmp ufuncs.tmp cfuncs.tmp gfuncs.tmp wfuncs.tmp
buffer.asm: loaddll.inc buffer.inc gl33.inc
gl33.asm: loaddll.inc gl33.inc assets.inc
pool.asm: loaddll.inc pool.inc
scene.asm: loaddll.inc timer.inc vblank.inc gl33.inc buffer.inc assets.inc shader.inc math.inc fontgl.inc hrsleep.inc
vblank.asm: loaddll.inc vblank.inc timer.inc
shader.asm: loaddll.inc shader.inc gl33.inc assets.inc
utf.asm: loaddll.inc utf.inc
hrsleep.asm: loaddll.inc hrsleep.inc
scloader.asm: loaddll.inc shellcode.inc assets.inc
shellcode.asm: shellcode.inc scfuncs.tmp

shellcode.bin: shellcode.asm
	nasm $^ $(DEFS) $(ASMFLAGS) -o $@
out/stub.bin: stub.asm
	nasm $^ -o $@
out/%_d.obj: %.asm
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	nasm -f win32 -g -D_DEBUG $(DEFS) $(ASMFLAGS) $^ -o $@
out/%.obj: %.asm
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	nasm -f win32 -g $(DEFS) $(ASMFLAGS) $^ -o $@
out/assets.cab: $(wildcard assets/*) shellcode.bin
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	cabarc -r -p -m LZX:21 N $@ assets\\* shellcode.bin
out/math.lib: $(wildcard math/*) loaddll.inc pool.inc math.inc
	make -C math

ex2000.exe: $(OBJS) $(LIBS) out/stub.bin
	link /NOLOGO /NODEFAULTLIB /NOENTRY /ENTRY:entry /BASE:0x400000 /DYNAMICBASE:NO /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /MERGE:.rdata=.text /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$@ /DEBUG /STUB:out\\stub.bin /SUBSYSTEM:WINDOWS $(OBJS) $(LIBS)

ex2000d.exe: $(OBJS_D) $(LIBS) out/stub.bin
	link /NOLOGO /NODEFAULTLIB /NOENTRY /ENTRY:entry /BASE:0x400000 /DYNAMICBASE:NO /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /MERGE:.rdata=.text /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$@ /DEBUG /STUB:out\\stub.bin /SUBSYSTEM:CONSOLE $(OBJS_D) $(LIBS)

clean:
	del /f /s /q *.tmp out\\*.obj out\\*.cab out\\*.a out\\*.lib out\\*.bin *.gdb *.pdb shellcode.bin ex2000.exe ex2000d.exe

again:
	make clean
	make all -j

unrich: ex2000.exe
	python tools/unrich.py $^

run: ex2000.exe
	ex2000.exe

rund: ex2000d.exe
	ex2000d.exe
