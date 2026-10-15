@echo off
set "plugin_codex=codex"
where codex >nul 2>nul
if errorlevel 1 if exist "%USERPROFILE%\.local\bin\codex.exe" set "plugin_codex=%USERPROFILE%\.local\bin\codex.exe"
echo Keep this window open. Sign in through your browser and click Connect.
echo If no browser opens, use the authorization URL below.
call "%plugin_codex%" mcp login vitverk --oauth-client-registration dcr
set "plugin_status=%ERRORLEVEL%"
if "%plugin_status%"=="0" (echo Sign-in complete. Start a new Codex task.) else (echo Sign-in did not finish. Read the error above and retry.)
pause
exit /b %plugin_status%
