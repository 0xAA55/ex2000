@echo off

tools\nasm -f win32 main.asm -o out\main.obj
tools\nasm -f win32 strcmp.asm -o out\strcmp.obj
tools\nasm -f win32 stricmp.asm -o out\stricmp.obj
tools\nasm -f win32 loaddll.asm -o out\loaddll.obj
tools\link /ENTRY:start /LARGEADDRESSAWARE /NODEFAULTLIB /RELEASE /SUBSYSTEM:WINDOWS /OUT:ex2000.exe out\main.obj out\strcmp.obj out\stricmp.obj out\loaddll.obj

pause
