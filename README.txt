venvwrapper.bat

A handy windows batch script to create, activate, deactivate python
virtual environments. All virtual environments are created in a venv home
directory which could be set by the user in this script. A single command
to create/activate/switch venvs.

-- Usage
    -- venvwrapper.bat <venv_name>
            Creates a new venv with the provided name if it doesn't exist and
            activates it. Also it pip installs all the packages specified in
            the requirements.txt, that you can find in the same directory as this
            batch file. If venv exist, then this command simply activates it.

    -- venvwrapper.bat -d, --deactivate
            Deactivates the current active venv

    -- venvwrapper.bat -h, --help
            Prints out help
