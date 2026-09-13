OUT_DIR:=out
SRCS=$(filter-out stub.asm, $(wildcard *.asm))
OBJS=$(patsubst %.asm, $(OUT_DIR)/%.obj, $(SRCS))
OBJS_D=$(patsubst %.asm, $(OUT_DIR)/%_d.obj, $(SRCS))
DEPS=$(OBJS:.obj=.d)
DEPS_D=$(OBJS_D:.obj=.d)
FUNCLIST=expfuncs.tmp scfuncs.tmp kfuncs.tmp ufuncs.tmp cfuncs.tmp gfuncs.tmp wfuncs.tmp wglfuncs.tmp gl33funcs.tmp glfuncs.tmp
LIBPATH_FLAGS=/LIBPATH:lib /LIBPATH:math\\out /LIBPATH:shellcodes\\out
LIBS=math/out/math.lib lib/kernel32.lib
DEFS:=
ASMFLAGS=

all: ex2000.exe
.PHONY: clean again

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
shellcode.bin: loaddll.inc $(wildcard shellcodes/*) scfuncs.tmp shellcode.inc
	make -C shellcodes
	copy shellcodes\\shellcode.bin shellcode.bin
shellcode_d.bin: loaddll.inc $(wildcard shellcodes/*) scfuncs.tmp shellcode.inc
	make -C shellcodes alld
	copy shellcodes\\shellcode_d.bin shellcode_d.bin
$(OUT_DIR)/stub.bin: stub.asm
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm $^ -o $@
$(OUT_DIR)/assets.cab: $(wildcard assets/*) shellcode.bin
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	cabarc -r -p -m LZX:21 N $@ assets\\* shellcode.bin
$(OUT_DIR)/assets_d.cab: $(wildcard assets/*) shellcode_d.bin
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	cabarc -r -p -m LZX:21 N $@ assets\\* shellcode_d.bin
math/out/math.lib: $(wildcard math/*) loaddll.inc math.inc
	make -C math
math/out/mathd.lib: $(wildcard math/*) loaddll.inc math.inc
	make -C math alld
$(OUT_DIR)/%.obj: %.asm $(FUNCLIST)
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@
$(OUT_DIR)/%_d.obj: %.asm $(FUNCLIST)
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g -D_DEBUG $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@
$(OUT_DIR)/assets.obj: assets.asm $(OUT_DIR)/assets.cab
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@
$(OUT_DIR)/assets_d.obj: assets.asm $(OUT_DIR)/assets_d.cab
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g -D_DEBUG $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@

-include $(DEPS)
-include $(DEPS_D)

ex2000.exe: $(OBJS) $(LIBS) $(OUT_DIR)/stub.bin
	link /NOLOGO /NODEFAULTLIB /ENTRY:entry /BASE:0x400000 /DYNAMICBASE:NO /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /MERGE:.rdata=.text /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$@ /DEBUG $(LIBPATH_FLAGS) /PDBALTPATH:%_PDB% /STUB:out\\stub.bin /SUBSYSTEM:WINDOWS $(OBJS) $(notdir $(LIBS))

ex2000d.exe: $(OBJS_D) $(LIBS) $(OUT_DIR)/stub.bin
	link /NOLOGO /NODEFAULTLIB /ENTRY:entry /BASE:0x400000 /DYNAMICBASE:NO /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /MERGE:.rdata=.text /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$@ /DEBUG $(LIBPATH_FLAGS) /PDBALTPATH:%_PDB% /STUB:out\\stub.bin /SUBSYSTEM:CONSOLE $(OBJS_D) $(notdir $(LIBS))

clean:
	make -C shellcodes clean
	del /f /s /q *.tmp $(OUT_DIR)\\*.obj $(OUT_DIR)\\*.d $(OUT_DIR)\\*.cab $(OUT_DIR)\\*.a $(OUT_DIR)\\*.lib $(OUT_DIR)\\*.bin *.gdb *.pdb shellcode.bin shellcode_d.bin ex2000.exe ex2000d.exe

again:
	make clean
	make all -j

unrich: ex2000.exe
	python tools/unrich.py $^

run: ex2000.exe
	ex2000.exe

rund: ex2000d.exe
	ex2000d.exe
