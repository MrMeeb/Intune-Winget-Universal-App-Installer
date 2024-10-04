@echo off
set intunepreptoolpath="..\..\Microsoft-Win32-Content-Prep-Tool-1.8.5"
set setup_folder="%~dp0\Source"
set setup_file=%setup_folder%\install.cmd
set output_folder="%~dp0"

%intunepreptoolpath%\IntuneWinAppUtil.exe -c %setup_folder% -s %setup_file% -o %output_folder%