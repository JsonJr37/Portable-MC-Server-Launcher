@echo off
rem This is the main file for starting up the launcher, the "backbone"
rem This is setup
title MC Server Launcher
chcp 65001 >nul
for /f %%A in ('"echo prompt $E| cmd"') do set "ESC=%%A"
setlocal EnableDelayedExpansion
set BASEDIR=%~dp0
set SERVER_DIR=%BASEDIR%\servers

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
timeout /t 2 >nul
cls

call :BANNER
timeout /t 2 >nul
cls
call :AUTHOR
timeout /t 2 >nul
:START
set "choice"="0"
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
echo ╔═════════════════════════════════════════════ ══ ═
echo ║ Select a Server to run, or "EXIT"
echo ╠═══════════════════════╦═════════════════════ ══ ═
echo ╠═{0.1} Make New Server ╚═{0.2} Delete Server
FOR /L %%i IN (1,1,%COUNT%) DO (
    echo ╠═{%%i} !serverName[%%i]!
)
set /p choice=╚══════════════───^>^> 
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
rem Checks for any .jar file and then starts that jar file
set "SERVER_PATH=%SERVER_DIR%\!SELECTED_SERVER!"
FOR %%J IN ("%SERVER_PATH%\*.jar") DO (
    SET "JAR_FILE=%%~nxJ"
    goto :run
)
echo %ESC%[31mCould not find Server Jar in server '!SELECTED_SERVER!'!%ESC%[0m
timeout /t 2 >nul
goto :START
:run
start "!SELECTED_SERVER!" cmd /k "cd /d "%SERVER_PATH%" && java -Xmx4G -jar "!JAR_FILE!" nogui && exit"
timeout /t 2 >nul
goto :START

:NewServer
cls
call :BANNER
echo Starting Server Creater...
start cmd /k "cd /d "%SERVER_DIR%" && java -jar ServerInstaller.jar && exit"
timeout /t 3 >nul
set /p "SERVER_NAME=What do you want your server to be called: "
echo Renaming Server...
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
