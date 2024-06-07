import os

def list_directories(path):
    return [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]

def read_env_file(path):
    env_vars = {}
    if os.path.exists(path) and os.path.isfile(path):
        with open(path, 'r') as file:
            for line in file:
                if '=' in line:
                    key, value = line.strip().split('=', 1)
                    env_vars[key] = value
    return env_vars

