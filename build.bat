@echo off

if not exist out mkdir out

del /f /s /q out\assets.cab

tools\cabarc -m LZX:21 -p -r N out\assets.cab assets\*

tools\nasm stub.asm -o out\stub.bin
tools\nasm -f win32 main.asm -o out\main.obj
tools\nasm -f win32 loaddll.asm -o out\loaddll.obj
tools\nasm -f win32 gl33.asm -o out\gl33.obj
tools\nasm -f win32 scene.asm -o out\scene.obj
tools\nasm -f win32 timer.asm -o out\timer.obj
tools\nasm -f win32 buffer.asm -o out\buffer.obj
tools\nasm -f win32 shader.asm -o out\shader.obj
tools\nasm -f win32 matrix.asm -o out\matrix.obj
tools\nasm -f win32 assets.asm -o out\assets.obj
tools\nasm -f win32 avlbst.asm -o out\avlbst.obj
tools\link /NOLOGO /ENTRY:start /INCREMENTAL:NO /WS:AGGRESSIVE /OPT:REF /LARGEADDRESSAWARE /NODEFAULTLIB /DEBUG /SUBSYSTEM:WINDOWS /STUB:out\stub.bin /OUT:ex2000.exe out\main.obj out\loaddll.obj out\gl33.obj out\scene.obj out\timer.obj out\buffer.obj out\shader.obj out\matrix.obj out\assets.obj out\avlbst.obj

pause
