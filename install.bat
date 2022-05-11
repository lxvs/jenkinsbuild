@echo off
setlocal

pushd "%~dp0"

:input
if defined JENKINS_JOB_NAME (
    set /p "job=Enter Jenkins job name (leave empty to use %JENKINS_JOB_NAME%): "
) else (
    set /p "job=Enter Jenkins job name: "
)
if not defined job (
    if defined JENKINS_JOB_NAME (
        set "job=%JENKINS_JOB_NAME%"
    ) else (
        goto input
    )
)

@echo Jenkins job name: %job%
setx JENKINS_JOB_NAME "%job%" 1>nul

if not exist "%USERPROFILE%\bin\" md "%USERPROFILE%\bin\"
copy /Y "jenkinsbuild" "%USERPROFILE%\bin\" 1>nul
if %ERRORLEVEL% EQU 0 @echo Complete.
pause
exit /b
