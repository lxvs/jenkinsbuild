@echo off
setlocal

pushd "%~dp0"

:input
set /p "job=Enter Jenkins job name: "
if "%job%" == "" goto input

@echo Jenkins job name: %job%
setx JENKINS_JOB_NAME "%job%" 1>nul

if not exist "%USERPROFILE%\bin\" md "%USERPROFILE%\bin\"
copy /Y "jenkinsbuild" "%USERPROFILE%\bin\" 1>nul
if %ERRORLEVEL% EQU 0 @echo Complete.
pause
exit /b
