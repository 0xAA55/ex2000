@echo off

tools\nasm stub.asm -o out\stub.bin
tools\nasm -f win32 main.asm -o out\main.obj
tools\nasm -f win32 strcmp.asm -o out\strcmp.obj
tools\nasm -f win32 stricmp.asm -o out\stricmp.obj
tools\nasm -f win32 loaddll.asm -o out\loaddll.obj
tools\nasm -f win32 gl33.asm -o out\gl33.obj
tools\link /ENTRY:start /LARGEADDRESSAWARE /NODEFAULTLIB /RELEASE /SUBSYSTEM:WINDOWS /STUB:out\stub.bin /OUT:ex2000.exe out\main.obj out\strcmp.obj out\stricmp.obj out\loaddll.obj out\gl33.obj

pause
