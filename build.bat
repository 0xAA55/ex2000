@echo off

tools\nasm stub.asm -o out\stub.bin
tools\nasm -f win32 main.asm -o out\main.obj
tools\nasm -f win32 loaddll.asm -o out\loaddll.obj
tools\nasm -f win32 gl33.asm -o out\gl33.obj
tools\nasm -f win32 scene.asm -o out\scene.obj
tools\nasm -f win32 timer.asm -o out\timer.obj
tools\nasm -f win32 buffer.asm -o out\buffer.obj
tools\link /NOLOGO /ENTRY:start /INCREMENTAL:NO /WS:AGGRESSIVE /OPT:REF /LARGEADDRESSAWARE /NODEFAULTLIB /DEBUG /SUBSYSTEM:WINDOWS /STUB:out\stub.bin /OUT:ex2000.exe out\main.obj out\loaddll.obj out\gl33.obj out\scene.obj out\timer.obj out\buffer.obj

pause
