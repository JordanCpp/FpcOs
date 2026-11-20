@echo off
setlocal enabledelayedexpansion
set FPC_BIN=C:\FPC\3.2.2\bin\i386-win32

if not exist build mkdir build
del /q build\*.* 2>nul

echo [1/4] Assembling boot.s...
%FPC_BIN%\as.exe --32 HAL\x86\boot.s       -o build\boot.o
%FPC_BIN%\as.exe --32 HAL\x86\interrupts.s -o build\interrupts.o
if errorlevel 1 goto err

echo [2/4] Compiling kernel.pas...
%FPC_BIN%\fpc.exe -n -O2 -Twin32 -Cn -Fusrc -FuHAL\x86 -FEbuild src\Main.pas
if errorlevel 1 goto err

echo [3/4] Linking...
set OBJS=build\boot.o
for %%f in (build\*.o) do (
    if /i not "%%~nxf"=="boot.o" set OBJS=!OBJS! %%f
)
%FPC_BIN%\ld.exe -T linker.ld -o build\kernel.pe !OBJS!
if errorlevel 1 goto err

echo [4/4] Converting to ELF...
%FPC_BIN%\objcopy.exe -O elf32-i386 build\kernel.pe build\kernel.elf
if errorlevel 1 goto err

echo.
echo Build succeeded: build\kernel.elf
goto end

:err
echo.
echo Build FAILED!

:end
pause
