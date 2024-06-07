import os
import configparser

def list_directories(path):
    return [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]

def read_env_file(path):
    env_vars = {}
    if os.path.exists(path) and os.path.isfile(path):
        config = configparser.ConfigParser()
        config.read(path)
        for section in config.sections():
            for key, value in config.items(section):
                env_vars[key] = value
    return env_vars

if __name__ == '__main__':
    res = list_directories("/home/jerexxypunto/entorno/")
    print(res)
