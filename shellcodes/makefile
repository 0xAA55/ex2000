OUT_DIR:=out
SRCS=$(filter-out shellcode.asm, $(wildcard *.asm))
OBJS=$(OUT_DIR)/shellcode.obj $(patsubst %.asm, $(OUT_DIR)/%.obj, $(SRCS))
OBJS_D=$(OUT_DIR)/shellcode_d.obj $(patsubst %.asm, $(OUT_DIR)/%_d.obj, $(SRCS))
DEPS=$(OBJS:.obj=.d)
DEPS_D=$(OBJS_D:.obj=.d)
DEFS:=
ASMFLAGS=-i..

all: shellcode.bin
alld: shellcode_d.bin

$(OUT_DIR)/%.obj: %.asm
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@
$(OUT_DIR)/%_d.obj: %.asm
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g -D_DEBUG $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@

-include $(DEPS)
-include $(DEPS_D)

$(OUT_DIR)/shellcode.dll: $(OBJS) exports.def
	link /NOLOGO /NODEFAULTLIB /NOENTRY /BASE:0x70000000 /DYNAMICBASE:NO /DLL /DEF:exports.def /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /IGNORE:4254 /MERGE:.edata=.zzz /MERGE:.rdata=.data /MERGE:.data=.code /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$(OUT_DIR)\\shellcode.dll /DEBUG /PDBALTPATH:%_PDB% $(OBJS)

$(OUT_DIR)/shellcode_d.dll: $(OBJS_D) exports.def
	link /NOLOGO /NODEFAULTLIB /NOENTRY /BASE:0x70000000 /DYNAMICBASE:NO /DLL /DEF:exports.def /INCREMENTAL:NO /NXCOMPAT:NO /SAFESEH:NO /IGNORE:4254 /MERGE:.edata=.zzz /MERGE:.rdata=.data /MERGE:.data=.code /FILEALIGN:512 /LARGEADDRESSAWARE /MACHINE:X86 /OPT:REF /OPT:ICF /OUT:$(OUT_DIR)\\shellcode_d.dll /DEBUG /PDBALTPATH:%_PDB% $(OBJS_D)

shellcode.bin: $(OUT_DIR)/shellcode.dll
	objcopy -j .code -O binary $^ $@

shellcode_d.bin: $(OUT_DIR)/shellcode_d.dll
	objcopy -j .code -O binary $^ $@

clean:
	del /f /q $(OUT_DIR)\\*.obj $(OUT_DIR)\\*.d $(OUT_DIR)\\*.dll $(OUT_DIR)\\*.lib $(OUT_DIR)\\*.exp *.bin
