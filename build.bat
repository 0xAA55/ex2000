@echo off

set PATH=%~dp0tools;%PATH%
call make -j %*

pause
