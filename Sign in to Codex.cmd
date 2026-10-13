@echo off
set "vinnslan_codex=codex"
where codex >nul 2>nul
if errorlevel 1 if exist "%USERPROFILE%\.local\bin\codex.exe" set "vinnslan_codex=%USERPROFILE%\.local\bin\codex.exe"
echo Keep this window open. Sign in through your browser and click Connect.
echo If no browser opens, use the authorization URL below.
call "%vinnslan_codex%" mcp login vitverk --oauth-client-registration dcr
set "vinnslan_status=%ERRORLEVEL%"
if "%vinnslan_status%"=="0" (echo Sign-in complete. Start a new Codex task.) else (echo Sign-in did not finish. Read the error above and retry.)
pause
exit /b %vinnslan_status%
