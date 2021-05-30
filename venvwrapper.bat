@Echo off

@REM -------------------------------------------------------------------------
@REM -- NAME            : venvwrapper.bat
@REM -- AUTHOR          : Praveen Ilangovan
@REM -- AUTHOR EMAIL    : praveen.ilangovan@gmail.com
@REM 
@REM A handy windows batch script to create, activate, deactivate python
@REM virtual environments. All virtual environments are created in a venv home
@REM directory which could be set by the user in this script. A single command
@REM to create/activate/switch venvs.
@REM 
@REM -- Usage
@REM     -- venvwrapper.bat <venv_name>
@REM             Creates a new venv with the provided name if it doesn't exist and
@REM             activates it. Also it pip installs all the packages specified in
@REM             the requirements.txt, that you can find in the same directory as this
@REM             batch file. If venv exist, then this command simply activates it.
@REM 
@REM -------------------------------------------------------------------------

@REM USER DEFINIED VARIABLE(S)
@REM Directory where the venv should be created.
set VENV_HOME_DIR=C:\Users\prave\Documents\Praveen\workspace\.venv

@REM SESSION VARIABLES
@REM Get the current working directory
set CWD=%CD%

@REM Source directory where this batch script lives
set SRC_DIR=%~dp0
set REQS_FILE=%SRC_DIR%\requirements.txt
set ACTIVE_FILE=%SRC_DIR%\active_venv.txt

@REM Scripts directory of the requested venv
set SCRIPTS_DIR=%VENV_HOME_DIR%/%1/Scripts

:: Check if the venv exists, if so, activate it, else create it
if exist %VENV_HOME_DIR%\%1/ (
    call :deactivate_active_venv %ACTIVE_FILE%, %VENV_HOME_DIR%
    call :activate %1, %SCRIPTS_DIR%, %ACTIVE_FILE%
) else (
    call :deactivate_active_venv %ACTIVE_FILE%, %VENV_HOME_DIR%
    call :create %1, %VENV_HOME_DIR%, %SCRIPTS_DIR%, %REQS_FILE%, %CWD%, %ACTIVE_FILE%
    call :delete_active_file  %ACTIVE_FILE%
)
exit /B 0

:deactivate_active_venv
:: Deactivate the currently active venv, before proceeding
:: args => active_file, venv_home_dir
if exist %1 (
    set /p ACTIVE_VENV=<%1
    call :deactivate %2/%ACTIVE_VENV%/Scripts
    call :delete_active_file %1
)
exit /B 0

:delete_active_file
:: Delete active file
if exist %1 (
    del %1
)
exit /B 0

:create
:: args => venv_name, venv_home_dir, scripts_dir, reqs_file, cwd
:: Change the CWD to VENV_HOME_DIRECTORY
pushd %2
:: Create a new venv
echo Creating venv: %1 @ %2
call py -m venv %1 --upgrade-deps
call :activate %1, %3, %6
call :pip_install %4
call :reset %3, %5
exit /B 0

:activate
:: Activate the venv => venv_name, scripts_dir, active_file
set batfile=%2/activate.bat
if exist %batfile% (
    echo Activating venv: %1
    call %2/activate.bat
    :: write it out to a file
    echo %1>%3
)
exit /B 0

:pip_install
:: Pip Install requirements => reqs_file
echo Installing requirements from: %1
call pip install -r %1
exit /B 0

:deactivate
:: Deactivate the venv => scripts_dir
set batfile=%1/deactivate.bat
if exist %batfile% (
    echo Deactivating venv
    call %1/deactivate.bat
)
exit /B 0

:reset
:: Reset the directory => scripts_dir, cwd
call :deactivate %1
pushd %2
exit /B 0
