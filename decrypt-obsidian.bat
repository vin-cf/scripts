@echo off

:'
Mount VeraCrypt Volume and Launch Obsidian Script

This script mounts a VeraCrypt volume and attempts to launch the Obsidian application.
It checks for the presence of the mounted drive (A:) and retries every second for a specified timeout period.
'

set TIMEOUT=20
set /a ELAPSED=0

"C:\Program Files\VeraCrypt\VeraCrypt.exe" /letter A /v "%USERPROFILE%\Documents\Veracrypt\Obsidian.hc" /q

:pollLoop
echo Checking for drive A:
if exist A:\ (
    echo Drive A: is mounted.
    start "" "%LOCALAPPDATA%\Obsidian\Obsidian.exe"
    goto :end
) else (
    echo Drive A: is not mounted. Retrying in 1 second.
    timeout /t 1 /nobreak >nul
	set /a ELAPSED+=1
	if %ELAPSED% GEQ %TIMEOUT% (
        echo Timed out after %TIMEOUT% seconds. Drive A: is not mounted.
        goto :end
    )
    goto :pollLoop
)
:end
echo Done.