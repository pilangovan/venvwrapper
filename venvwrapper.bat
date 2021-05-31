@Echo off

@REM -------------------------------------------------------------------------
@REM -- NAME            : venvwrapper.bat
@REM -- AUTHOR          : Praveen Ilangovan
@REM -- AUTHOR EMAIL    : praveen.ilangovan@gmail.com
@REM -- DESCRIPTION     : See README.txt
@REM -------------------------------------------------------------------------

@REM USER DEFINIED VARIABLE(S)
@REM Directory where the venv should be created.
set VENV_HOME_DIR=C:\Users\prave\Documents\Praveen\workspace\.venv

@REM SESSION VARIABLES
@REM Get the current working directory
set CWD=%CD%

@REM Source directory where this batch script lives
set SRC_DIR=%~dp0
set UTILS_FILE=%SRC_DIR%\venvwrapper_utils.py
set REQS_FILE=%SRC_DIR%\requirements.txt
set ACTIVE_FILE=%SRC_DIR%\active_venv.txt
set README_FILE=%SRC_DIR%\README.txt

@REM Scripts directory of the requested venv
set SCRIPTS_DIR=%VENV_HOME_DIR%/%1/Scripts

@REM This script can be run in differnet modes based on the input arguments.
@REM MODES 
@REM    0: Creates or activates the venv. %1 is the name of the venv (default)
@REM    1: Deactivates the current active venv. %1 is -d or --deactivate
@REM    2: Deletes the requested venv. %1 is the name of the venv and %2 is -D,--delete flag
@REM    3: Lists all the available venvs. %1 is -l or --listvenv
@REM    4: Print help. %1 is empty or -h or --help
set MODE=0
set FIRST_ARG=%1

@REM Find the right mode based on the input argument
if "%~1"=="" (
    set MODE=4
) else if "%1"=="-h" (
    set MODE=4
) else if "%1"=="--help" (
    set MODE=4
) else if "%1"=="--deactivate" (
    set MODE=1
) else if "%1"=="-d" (
    set MODE=1
) else if "%1"=="--listvenv" (
    set MODE=3
) else if "%1"=="-l" (
    set MODE=3
) else (
    @REM Check if the first arg starts with - and if so, skip it.
    @REM Invalid Flag.
    if "%FIRST_ARG:~0,1%"=="-" (
        set MODE=4
    )
)

@REM Check if there is a second argument passed and if it is -D, --delete
if %MODE%==0 ( 
    if "%~2"=="-D" (
        set MODE=2
    ) else if "%~2"=="--delete" (
        set MODE=2
    )
)

@REM -------------------------------------------------------------------------
@REM Main
@REM Perform the operations based on the mode.
@REM -------------------------------------------------------------------------
if %MODE%==0 (
    if exist %VENV_HOME_DIR%\%1/ (
        call :deactivate_active_venv %UTILS_FILE%, %ACTIVE_FILE%, %VENV_HOME_DIR%
        call :activate %1, %SCRIPTS_DIR%
    ) else (
        call :deactivate_active_venv %UTILS_FILE%, %ACTIVE_FILE%, %VENV_HOME_DIR%
        call :create %1, %VENV_HOME_DIR%, %SCRIPTS_DIR%, %REQS_FILE%, %CWD%
    )
) else if %MODE%==1 (
    call :deactivate_active_venv %UTILS_FILE%, %ACTIVE_FILE%, %VENV_HOME_DIR%
) else if %MODE%==2 (
    if exist %VENV_HOME_DIR%\%1/ (
        call :deactivate %VENV_HOME_DIR%/%1/Scripts
        echo Removing venv: %1
        rmdir %VENV_HOME_DIR%\%1 /s /q
    ) else (
        echo Venv "%1" not found.
    )
) else if %MODE%==3 (
    if exist %VENV_HOME_DIR%/ (
        dir /B /AD /OD %VENV_HOME_DIR%
    ) else (
        echo Directory not found: %VENV_HOME_DIR%
    )
) else (
    type %README_FILE%
)
exit /B 0

:deactivate_active_venv
@REM -------------------------------------------------------------------------
@REM Runs venvwrapper_utils.py to grab the active venv. This file saves
@REM the name of the venv in a text file. The name is then read by this batch
@REM script, deactives it and deletes the text file. This is done before activating
@REM or creating a new venv.
@REM
@REM Args:
@REM    %1 -> UTILS_FILE: Python file to write the venv name to disk
@REM    %2 -> ACTIVE_FILE: Text file that has the name of the venv
@REM    %3 -> VENV_HOME_DIR: venv dir where one could find the deactivate.bat script
@REM -------------------------------------------------------------------------
call py %1
if exist %2 (
    set /p ACTIVE_VENV=<%2
    call :deactivate %3/%ACTIVE_VENV%/Scripts
    del %2
)
exit /B 0

:create
@REM -------------------------------------------------------------------------
@REM Creates a new venv, activates it and installs the packages specified
@REM in the requirements.txt file.
@REM
@REM Args:
@REM    %1 -> Name of the venv to be created
@REM    %2 -> VENV_HOME_DIR: venv dir where venv should be created
@REM    %3 -> SCRIPTS_DIR: Scripts dir of the created venv.
@REM    %4 -> REQS_FILE: requirements.txt filepath
@REM    %5 -> CWD: While creating venv, the current working directory changes.
@REM               So, we query the cwd before creating venv and restore it at
@REM               the end
@REM -------------------------------------------------------------------------
if not exist %2/ (
    mkdir %2
)
pushd %2
echo Creating venv: %1 @ %2
call py -m venv %1 --upgrade-deps
call :activate %1, %3
call :pip_install %4
pushd %5
exit /B 0

:activate
@REM -------------------------------------------------------------------------
@REM Activates the requested venv if that exist
@REM
@REM Args:
@REM    %1 -> Name of the venv to be activated
@REM    %2 -> SCRIPTS_DIR: Scripts dir of the venv. This is where the
@REM                       activate.bat lives.
@REM -------------------------------------------------------------------------
set batfile=%2/activate.bat
if exist %batfile% (
    echo Activating venv: %1
    call %batfile%
) else (
    echo Activation failed: %batfile% not found.
)
exit /B 0

:pip_install
@REM -------------------------------------------------------------------------
@REM Run pip installer to install all the packages specified in the
@REM requirments.txt
@REM
@REM Args:
@REM    %1 -> REQS_FILE: requirements.txt filepat
@REM -------------------------------------------------------------------------
:: Pip Install requirements => reqs_file
if exist %1 (
    echo Installing requirements from: %1
    call pip install -r %1
) else (
    echo Skipping pip install: %1 not found.
)
exit /B 0

:deactivate
@REM -------------------------------------------------------------------------
@REM Deactivates the requested venv if that exist
@REM
@REM Args:
@REM    %1 -> SCRIPTS_DIR: Scripts dir of the venv. This is where the
@REM                       activate.bat lives.
@REM -------------------------------------------------------------------------
set batfile=%1/deactivate.bat
if exist %batfile% (
    echo Deactivating venv
    call %batfile%
) else (
    echo Deactivation failed: %batfile% not found.
)
exit /B 0
