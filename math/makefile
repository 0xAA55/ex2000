OUT_DIR:=out
SRCS=$(wildcard *.asm)
OBJS=$(patsubst %.asm, $(OUT_DIR)/%.obj, $(SRCS))
OBJS_D=$(patsubst %.asm, $(OUT_DIR)/%_d.obj, $(SRCS))
DEPS=$(OBJS:.obj=.d)
DEPS_D=$(OBJS_D:.obj=.d)
DEFS:=
ASMFLAGS=-i..

all: $(OUT_DIR)/math.lib
alld: $(OUT_DIR)/mathd.lib

$(OUT_DIR)/%.obj: %.asm
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@
$(OUT_DIR)/%_d.obj: %.asm
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g -D_DEBUG $(DEFS) $(ASMFLAGS) -MD $(@:.obj=.d) $< -o $@

-include $(DEPS)
-include $(DEPS_D)

$(OUT_DIR)/math.lib: $(OBJS)
	lib /NOLOGO /OUT:$@ /NODEFAULTLIB $^
$(OUT_DIR)/mathd.lib: $(OBJS_D)
	lib /NOLOGO /OUT:$@ /NODEFAULTLIB $^

clean:
	del /f /q $(OUT_DIR)\\*.obj $(OUT_DIR)\\*.lib $(OUT_DIR)\\*.d
