@echo off

set PATH=%~dp0tools;%PATH%

if not exist out mkdir out

del /f /s /q out\assets.cab

cabarc -r -p -m LZX:21 N out\assets.cab assets\*

cd math
call build.bat
cd ..

nasm stub.asm -o out\stub.bin
nasm -f win32 main.asm -o out\main.obj
nasm -f win32 loaddll.asm -o out\loaddll.obj
nasm -f win32 gl33.asm -o out\gl33.obj
nasm -f win32 scene.asm -o out\scene.obj
nasm -f win32 timer.asm -o out\timer.obj
nasm -f win32 buffer.asm -o out\buffer.obj
nasm -f win32 shader.asm -o out\shader.obj
nasm -f win32 assets.asm -o out\assets.obj
nasm -f win32 avlbst.asm -o out\avlbst.obj
nasm -f win32 pool.asm -o out\pool.obj
link /NOLOGO /ENTRY:start /INCREMENTAL:NO /WS:AGGRESSIVE /OPT:REF /LARGEADDRESSAWARE /NODEFAULTLIB /DEBUG /SUBSYSTEM:WINDOWS /STUB:out\stub.bin /OUT:ex2000.exe lib\kernel32.lib math\out\math.lib out\main.obj out\loaddll.obj out\gl33.obj out\scene.obj out\timer.obj out\buffer.obj out\shader.obj out\assets.obj out\avlbst.obj out\pool.obj

pause
