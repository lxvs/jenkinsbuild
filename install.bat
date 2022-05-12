@echo off
setlocal

set job=
set withParam=

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

:is_with_param
if defined JENKINS_WITH_PARAMETER if "%JENKINS_WITH_PARAMETER%" NEQ "0" (
    set /p "withParam=Does your Jenkins job have parameters (Y/N, leave empty is Y): "
) else (
    set /p "withParam=Does your Jenkins job have parameters (Y/N, default is N): "
)
if not defined withParam (
    if defined JENKINS_WITH_PARAMETER (
        set "withParam=%JENKINS_WITH_PARAMETER%"
    ) else (
        goto is_with_param
    )
) else (
    if /i "%withParam%" == "y" (
        set "withParam=1"
    ) else if /i "%withParam%" == "n" (
        set "withParam=0"
    ) else (
        >&2 echo Please enter Y or N, or leave empty.
        goto is_with_param
    )
)

@echo Jenkins job name: %job%
setx JENKINS_JOB_NAME "%job%" 1>nul
setx JENKINS_WITH_PARAMETER "%withParam%" 1>nul

if not exist "%USERPROFILE%\bin\" md "%USERPROFILE%\bin\"
copy /Y "jenkinsbuild" "%USERPROFILE%\bin\" 1>nul
if %ERRORLEVEL% EQU 0 @echo Complete.
pause
exit /b
