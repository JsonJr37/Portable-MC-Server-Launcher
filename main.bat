@echo off
rem This is the main file for starting up the launcher, the "backbone"
rem This is setup
title MC Server Launcher
chcp 65001 >nul
for /f %%A in ('"echo prompt $E| cmd"') do set "ESC=%%A"
setlocal EnableDelayedExpansion
set BASEDIR=%~dp0
set SERVER_DIR=%BASEDIR%servers
set choice=0

rem This sets java correctly
set "JAVA_FOLDER="
set "JAVA_DIR=%BASEDIR%java"

for /d %%D in ("%JAVA_DIR%\*") do (
    if exist "%%D\bin\java.exe" (
        set "JAVA_FOLDER=%%D"
        goto :FOUND
    )
)
echo This needs Java to run
echo.
echo ^<Press any key to continue^>
pause >nul
exit

:FOUND
set JAVA_HOME=!JAVA_FOLDER!
set PATH=%JAVA_HOME%\bin;%PATH%
cls

echo.
echo Current Java Path: %JAVA_HOME%
echo.
echo Current Java Version:
java -version
echo.
echo Current bat_inject.txt contents: ^(may change^)
type tmp\bat_inject.txt
timeout /t 2 >nul
cls

call :BANNER
timeout /t 2 >nul
cls
call :AUTHOR
timeout /t 2 >nul
:START
set "%choice%"="0"
cls
call :BANNER
rem This gets and prints the server options
set /A COUNT=0
for /F "tokens=1 delims==" %%I in ('set serverName[ 2^>nul') do set "%%I="
for /D %%D in ("%SERVER_DIR%\*") do (
    set /A COUNT=!COUNT!+1
    set "serverName[!COUNT!]=%%~nxD"
)
if %COUNT%==0 (
    echo No servers were found :^(
    timeout /t 1 >nul
    cls
)
cls
call :BANNER
echo ╔════════════════════════════════════════════════════════════════ ══ ═
echo ║ Select a Server to run/edit, or type "EXIT" to close this window.
echo ║ Also, you MAY NOT have these characters in server names: ^& ^( ^) ^| ^< ^>
echo ║ NOTE: DO NOT RUN MULTIPLE SERVERS AT A TIME, MAY BREAK ONE OF THEM!
echo ╠═══════════════════════╦═════════════════════╦══════════════════ ══ ═
echo ╠═{0.1} Make New Server ╚═{0.2} Rename Server ╚═{0.3} Delete Server
FOR /L %%i IN (1,1,%COUNT%) DO (
    echo ╠═{%%i} !serverName[%%i]!
)
set /p choice=╚══════════════════───^>^> 
IF /I "%choice%"=="EXIT" exit
IF "%choice%"=="" (
    echo %ESC%[31mInvalid Input%ESC%[0m
    timeout /t 2 >nul
    goto :START
)
IF "%choice%"=="0.1" (
    goto :NewServer
)
IF "%choice%"=="0.2" (
    goto :RenameServer
)
IF "%choice%"=="0.3" (
    goto :DeleteServer
)
IF %choice% LSS 1 (
    echo %ESC%[31mInvalid Input%ESC%[0m
    timeout /t 2 >nul
    goto :START
)
IF %choice% GTR %COUNT% (
    echo %ESC%[31mInvalid Input%ESC%[0m
    timeout /t 2 >nul
    goto :START
)

set "SELECTED_SERVER=!serverName[%choice%]!"
echo.
cls
call :BANNER
echo You Selected: %SELECTED_SERVER%
echo Starting....
timeout /t 2 >nul
rem Checks for any start.bat file and then starts it with our java
set "SERVER_PATH=%SERVER_DIR%\!SELECTED_SERVER!"
echo Searching for start.bat...
if exist "%SERVER_PATH%\start.bat" (
    timeout /t 3 >nul
    echo start.bat found, starting...
    goto :start_bat
)
timeout /t 3 >nul
echo Could not find start.bat, searching for run.bat...
if exist "%SERVER_PATH%\run.bat" (
    timeout /t 3 >nul
    echo run.bat found, starting...
    goto :run_bat
)
timeout /t 3 >nul
echo %ESC%[31mstart.bat and run.bat not found, needs either to run!%ESC%[0m
echo ^<Press any key to continue^>
pause >nul
goto :START

rem Functions for start.bat and run.bat, prefers start.bat
:start_bat
set "BAT=%SERVER_PATH%\start.bat"
set "count=0"
set "i=0"
cd tmp
rem the bat_inject file does not need changing, if you change it, the file is not read with batch functions
> start.bat (
    for /f "usebackq delims=" %%a in ("bat_inject.txt") do (
        set "line=%%a"
        echo !line!
        )
    for /f "usebackq delims=" %%a in ("%BAT%") do (
        set "line=%%a"
        echo !line!
        )
    echo exit
)
start "!SELECTED_SERVER!" start.bat
cd ..
timeout /t 3 >nul
goto :START

:run_bat
set "BAT=%SERVER_PATH%\run.bat"
set "count=0"
set "i=0"
cd tmp
> run.bat (
    for /f "usebackq delims=" %%a in ("bat_inject.txt") do (
        set "line=%%a"
        echo !line!
        )
    for /f "usebackq delims=" %%a in ("%BAT%") do (
        set "line=%%a"
        echo !line!
        )
    echo exit
)
start "!SELECTED_SERVER!" run.bat
cd ..
timeout /t 3 >nul
goto :START

rem Other functions for server managment
:NewServer
cls
call :BANNER
echo Starting Server Creater...
start cmd /k "cd /d "%SERVER_DIR%" && java -jar ServerInstaller.jar && exit"
timeout /t 3 >nul
set /p "SERVER_NAME=What do you want your server to be called: "
echo Naming Server...
timeout /t 3 >nul
ren "%SERVER_DIR%\server" "%SERVER_NAME%"
goto :START

:DeleteServer
cls
call :BANNER
echo What Server do you want to delete?
FOR /L %%i IN (1,1,%COUNT%) DO (
    echo %%i. !serverName[%%i]!
)
echo.
set /p "choice=Enter your choice here: "
set "SERVER_TO_DELETE=!serverName[%choice%]!"
echo Deleting server '!SERVER_TO_DELETE!'
timeout /t 3 >nul
rmdir /S /Q "%SERVER_DIR%\!SERVER_TO_DELETE!"
if errorlevel 1 (
    echo Failed to delete folder. Make sure it exists and is not in use.
) else (
    echo Folder deleted successfully.
)
timeout /t 2 >nul
goto :START

:RenameServer
cls
call :BANNER
echo What server do you want to rename?
FOR /L %%i IN (1,1,%COUNT%) DO (
    echo %%i. !serverName[%%i]!
)
echo.
set /p "choice=Enter your choice here: "
set "SERVER_TO_RENAME_OLD=!serverName[%choice%]!"
set /p "SERVER_TO_RENAME_NEW=What do you want your server to be called: "
echo Renaming server '!SERVER_TO_RENAME_OLD!' to '!SERVER_TO_RENAME_NEW!'
timeout /t 3 >nul
ren "%SERVER_DIR%\!SERVER_TO_RENAME_OLD!" "!SERVER_TO_RENAME_NEW!"
goto :START

rem This is the "Functions"
:BANNER
echo.
echo.
echo %ESC%[32m███╗   ███╗ ██████╗    %ESC%[33m███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ %ESC%[0m
echo %ESC%[32m████╗ ████║██╔════╝    %ESC%[33m██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗%ESC%[0m
echo %ESC%[32m██╔████╔██║██║         %ESC%[33m███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝%ESC%[0m
echo %ESC%[32m██║╚██╔╝██║██║         %ESC%[33m╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗%ESC%[0m
echo %ESC%[32m██║ ╚═╝ ██║╚██████╗    %ESC%[33m███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║%ESC%[0m
echo %ESC%[32m╚═╝     ╚═╝ ╚═════╝    %ESC%[33m╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝%ESC%[0m
echo.
echo %ESC%[36m██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗ %ESC%[0m
echo %ESC%[36m██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗%ESC%[0m
echo %ESC%[36m██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝%ESC%[0m
echo %ESC%[36m██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗%ESC%[0m
echo %ESC%[36m███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║%ESC%[0m
echo %ESC%[36m╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝%ESC%[0m
echo.
echo.
exit /B

:AUTHOR
echo.
echo.
echo %ESC%[38;5;220m███╗   ███╗ █████╗ ██████╗ ███████╗    ██████╗ ██╗   ██╗   %ESC%[0m
echo %ESC%[38;5;220m████╗ ████║██╔══██╗██╔══██╗██╔════╝    ██╔══██╗╚██╗ ██╔╝██╗%ESC%[0m
echo %ESC%[38;5;220m██╔████╔██║███████║██║  ██║█████╗      ██████╔╝ ╚████╔╝ ╚═╝%ESC%[0m
echo %ESC%[38;5;220m██║╚██╔╝██║██╔══██║██║  ██║██╔══╝      ██╔══██╗  ╚██╔╝  ██╗%ESC%[0m
echo %ESC%[38;5;220m██║ ╚═╝ ██║██║  ██║██████╔╝███████╗    ██████╔╝   ██║   ╚═╝%ESC%[0m
echo %ESC%[38;5;220m╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚═════╝    ╚═╝      %ESC%[0m
echo.                                                           
echo %ESC%[38;5;51m        ██╗███████╗ ██████╗ ███╗   ██╗     ██╗██████╗         %ESC%[0m
echo %ESC%[38;5;51m        ██║██╔════╝██╔═══██╗████╗  ██║     ██║██╔══██╗        %ESC%[0m
echo %ESC%[38;5;51m        ██║███████╗██║   ██║██╔██╗ ██║     ██║██████╔╝        %ESC%[0m
echo %ESC%[38;5;51m   ██   ██║╚════██║██║   ██║██║╚██╗██║██   ██║██╔══██╗        %ESC%[0m
echo %ESC%[38;5;51m   ╚█████╔╝███████║╚██████╔╝██║ ╚████║╚█████╔╝██║  ██║        %ESC%[0m
echo %ESC%[38;5;51m    ╚════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═╝        %ESC%[0m
echo.
echo %ESC%[38;5;220mhttps://github.com/JsonJr37/Portable-MC-Server-Launcher%ESC%[0m
exit /B
