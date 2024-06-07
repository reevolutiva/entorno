import os
import shutil

def copy_directory_contents(origin, destiny):
    shutil.copytree(origin, destiny)
