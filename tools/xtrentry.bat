@echo off

dumpbin /HEADERS %1 | findstr "entry" > entry.tmp
dumpbin /SECTION:.data %1 | findstr address > datasize.tmp
for /f "tokens=2 delims=()" %%a in (entry.tmp) do echo ientry equ 0x%%a> %2
for /f "tokens=6 delims=() " %%a in (datasize.tmp) do echo isize equ 0x%%a - ibase>> %2
del /f /q entry.tmp datasize.tmp
