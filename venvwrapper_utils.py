import os
import sys

DIRPATH = os.path.dirname(__file__)
ACTIVE_VENV_FILE = "active_venv.txt"

def is_venv_active():
    """ Returns True if a venv is active in the current session. """
    return (hasattr(sys, 'real_prefix') or
            (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix))

def get_venv_name():
    """ Return the name of the venv that's currently active. """
    return os.path.basename(sys.prefix) if is_venv_active() else None

def save_venv_to_file():
    """ Write out the name of the currently active venv to disk. """
    name = get_venv_name()
    if not name:
        return
    
    with open(os.path.join(DIRPATH, ACTIVE_VENV_FILE), 'w') as f:
        f.write(name)    

if __name__ == '__main__':
    save_venv_to_file()