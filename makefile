OUT_DIR:=out
SRCS=$(filter-out stub.asm, $(wildcard *.asm))
OBJS=$(patsubst %.asm, $(OUT_DIR)/%.obj, $(SRCS))
OBJS_D=$(patsubst %.asm, $(OUT_DIR)/%_d.obj, $(SRCS))
LIBS=out/math.lib lib/kernel32.lib
DEFS:=
ASMFLAGS=

all: ex2000.exe
.PHONY: clean again

%.inc:
	copy /b $@+ >nul 2>&1
%.asm:
	copy /b $@+ >nul 2>&1

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
wglfuncs.tmp: assets/WGLFUNC
	break>$@
	addpre assets\\WGLFUNC def_dll_func_addr $@
gl33funcs.tmp: assets/GL33FUNC
	break>$@
	addpre assets\\GL33FUNC def_dll_func_addr $@
glfuncs.tmp: assets/WGLFUNC assets/GL33FUNC
	break>$@
	addpre assets\\WGLFUNC DefImp $@
	addpre assets\\GL33FUNC DefImp $@
gl33.inc: glfuncs.tmp
loaddll.inc: frame.inc expfuncs.tmp
shader.inc: gl33.inc
fontgl.inc: buffer.inc
main.asm: loaddll.inc assets.inc math.inc tls.inc vblank.inc
assets.asm: loaddll.inc assets.inc avlbst.inc out/assets.cab
tls.asm: loaddll.inc tls.inc
timer.asm: loaddll.inc timer.inc hrsleep.inc
avlbst.asm: loaddll.inc avlbst.inc
fontgl.asm: loaddll.inc fontgl.inc avlbst.inc lfu.inc math.inc gl33.inc shader.inc utf.inc
loaddll.asm: loaddll.inc assets.inc kfuncs.tmp ufuncs.tmp cfuncs.tmp gfuncs.tmp wfuncs.tmp
buffer.asm: loaddll.inc buffer.inc gl33.inc
gl33.asm: loaddll.inc gl33.inc assets.inc wglfuncs.tmp gl33funcs.tmp
pool.asm: loaddll.inc pool.inc
scene.asm: loaddll.inc timer.inc vblank.inc gl33.inc buffer.inc assets.inc shader.inc math.inc fontgl.inc hrsleep.inc
vblank.asm: loaddll.inc vblank.inc timer.inc
shader.asm: loaddll.inc shader.inc gl33.inc assets.inc
utf.asm: loaddll.inc utf.inc
hrsleep.asm: loaddll.inc hrsleep.inc
scloader.asm: loaddll.inc shellcode.inc assets.inc
shellcode.inc: scfuncs.tmp glfuncs.tmp

shellcode.bin: loaddll.inc $(wildcard shellcodes/*) scfuncs.tmp shellcode.inc
	make -C shellcodes
	copy shellcodes\\shellcode.bin shellcode.bin
out/stub.bin: stub.asm
	nasm $^ -o $@
out/%_d.obj: %.asm
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g -D_DEBUG $(DEFS) $(ASMFLAGS) $^ -o $@
out/%.obj: %.asm
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g $(DEFS) $(ASMFLAGS) $^ -o $@
out/assets.cab: $(wildcard assets/*) shellcode.bin
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	cabarc -r -p -m LZX:21 N $@ assets\\* shellcode.bin
out/math.lib: $(wildcard math/*) loaddll.inc pool.inc math.inc
	make -C math

ex2000.exe: $(OBJS) $(LIBS) out/stub.bin
	link /NOLOGO /NODEFAULTLIB /ENTRY:entry /BASE:0x400000 /DYNAMICBASE:NO /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /MERGE:.rdata=.text /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$@ /DEBUG /PDBALTPATH:%_PDB% /STUB:out\\stub.bin /SUBSYSTEM:WINDOWS $(OBJS) $(LIBS)

ex2000d.exe: $(OBJS_D) $(LIBS) out/stub.bin
	link /NOLOGO /NODEFAULTLIB /ENTRY:entry /BASE:0x400000 /DYNAMICBASE:NO /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /MERGE:.rdata=.text /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$@ /DEBUG /PDBALTPATH:%_PDB% /STUB:out\\stub.bin /SUBSYSTEM:CONSOLE $(OBJS_D) $(LIBS)

clean:
	make -C shellcodes clean
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
