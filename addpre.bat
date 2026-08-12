@echo off

for /f "delims=" %%i in (%1) do echo %2 %%i>>%3
