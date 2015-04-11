@echo off

if not exist rsrc.rc goto over1
if exist rsrc.obj del rsrc.obj
if exist rsrc.RES del rsrc.RES
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.RES
:over1

if exist Sniper.obj del Sniper.obj
if exist Cursor.obj del Cursor.obj
if exist DrawPage.obj del DrawPage.obj
if exist DrawPerson.obj del DrawPerson.obj
if exist Sniper.exe del Sniper.exe

\MASM32\BIN\Ml.exe /c /coff Sniper.asm
if errorlevel 1 goto errasm

\MASM32\BIN\Ml.exe /c /coff Cursor.asm
if errorlevel 1 goto errasm

\MASM32\BIN\Ml.exe /c /coff DrawPage.asm
if errorlevel 1 goto errasm

\MASM32\BIN\Ml.exe /c /coff DrawPerson.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS Sniper.obj Cursor.obj rsrc.obj DrawPage.obj DrawPerson.obj
if errorlevel 1 goto errlink

dir Sniper.*
goto TheEnd

:nores
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS Sniper.obj Cursor.obj DrawPage.obj DrawPerson.obj
if errorlevel 1 goto errlink
dir %1
goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
goto TheEnd

:TheEnd

pause

