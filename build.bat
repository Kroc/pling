@ECHO OFF
CLS & TITLE Building Pling!...
CD %~dp0
ECHO:

REM # compile BSOD64 for C64 debugging
ECHO BSOD64
ECHO ========================================
SET "BSOD64=src\bsod64"
CALL "%BSOD64%\build.bat"
ECHO:

SET WLA_6510="bin\wla-dx\wla-6510.exe"   -i -x -I "src"
SET WLA_LINK="bin\wla-dx\wlalink.exe"    -i -A -S

REM # combine the CPU assembler and system symbols for a C64
SET WLA_C64=%WLA_6510% -D SYSTEM_CBM=1 -D SYSTEM_C64=1
REM # utility to pack C64 binaries onto a C64 disk-image
SET C1541="bin\vice\c1541.exe"
REM # C64 emulator
SET VICE="bin\vice\x64.exe"

ECHO Pling! C64:
ECHO ========================================
%WLA_C64% -v ^
    -o "build\pling.o" ^
       "pling.wla"

IF ERRORLEVEL 1 EXIT /B 1

%WLA_LINK% -v -t CBMPRG ^
    -b "link.ini" ^
       "build\pling_c64.prg"

IF ERRORLEVEL 1 EXIT /B 1

REM # build a 1541 floppy disk image
%C1541% ^
    -format "pling!,00" d64 "build/pling-c64.d64" ^
    -write  "build/pling_c64.prg"   "pling!" ^
    -write  "src/bsod64/bsod64.prg" "bsod64" ^
    -write  "autoexec.!"            "!autoexec"

IF ERRORLEVEL 1 EXIT /B 1

%VICE% --autostart "%~dp0build\pling-c64.d64"