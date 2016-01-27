echo Copyright (c) 2016 LANDESK Software Inc. All rights reserved.

echo off
setlocal
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" NEQ "10.0" echo Be careful you aren't running Windows 10, but you may still work!
echo %version%
endlocal

echo on
powershell -Command "Invoke-WebRequest https://src.chromium.org/svn/trunk/tools/depot_tools.zip -OutFile %cd%\depot_tools.zip"
powershell -Command "Expand-Archive" %cd%\depot_tools.zip %cd% -Force

expand %cd%\depot_tools.zip %cd%\depot_tools

SET PATH=%PATH%;%cd%\depot_tools\python276_bin;%cd%\depot_tools

echo Update depot_tools
call gclient

echo Get v8 files
call fetch v8

SET DEPOT_TOOLS_WIN_TOOLCHAIN=0
SET GYP_MSVS_VERSION=2015

REM favor size instead of speed
powershell -Command "(Get-Content '%cd%\v8\build\toolchain.gypi') | Foreach-Object {$_ -ireplace '''Optimization''\s*:\s*''\d''', '''Optimization'': ''1'''} | Set-Content  '%cd%\v8\build\toolchain.gypi'"
powershell -Command "(Get-Content '%cd%\v8\build\toolchain.gypi') | Foreach-Object {$_ -ireplace '''FavorSizeOrSpeed''\s*:\s*''\d''', '''FavorSizeOrSpeed'': ''2'''} | Set-Content  '%cd%\v8\build\toolchain.gypi'"

REM v8_enable_i18n_support=0, remove internationalization support
REM v8_use_snapshot=0, saves a little space but is slower to load
REM component=shared_library, build as a DLL, remove this to build as a static library
"%cd%\depot_tools\python276_bin\python" %cd%\v8\build\gyp_v8 -Dv8_enable_i18n_support=0 -Dcomponent=shared_library

REM Do not treat linker warnings as errors
%cd%\depot_tools\python276_bin\python .\ld-turnoffwarnings.py

msbuild.exe "%cd%\v8\tools\gyp\v8.sln" /p:configuration=release




