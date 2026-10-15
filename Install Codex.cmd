@echo off
powershell.exe -NoProfile -File "%~dp0install-codex.ps1"
set "plugin_status=%ERRORLEVEL%"
if not "%plugin_status%"=="0" echo Installation did not finish. See the error above or use the manual steps in README.md.
pause
exit /b %plugin_status%
