import os
import shutil
import subprocess

def create_folder(domain, src, src_vol):
    src_path = os.path.join(src, domain)
    src_vol_path = os.path.join(src_vol, domain)

    os.makedirs(src_path, exist_ok=True)
    os.makedirs(src_vol_path, exist_ok=True)


def copy_directory_contents(origin, destiny):
    command = f"cp -r {origin}* {destiny}"
    subprocess.run(command, shell=True)
    
def copy_file_contents(origin, destiny):
    command = f"cp {origin} {destiny}"
    subprocess.run(command, shell=True)


def run_docker_compose_up(path):
    subprocess.run(["docker", "compose", "up", "-d"], cwd=path)
    

#create_folder( "stage.kban.cl", "/home/hosting/", "/home/hosting/reevolutiva-net/");    
# STEP 1: Creo los directorios para el stage.
# create_folder("stage.domain.tld", "/home/hosting/<domain>", "/home/hosting/reevolutiva-net/<domain>/")

#STEP 2: Copio el contenido de la carpeta original a la carpeta stage.domain.tld
# copy_directory_contents("/home/hosting/reevolutiva-net/<domain>/", "/home/hosting/reevolutiva-net/stage.<domain>/")
# copy_directory_contents("/home/hosting/<domain>/", "/home/hosting/stage.<domain>/")


#STEP 3: Levanto el docker-compose
# run_docker_compose_up("/home/hosting/reevolutiva-net/stage.<domain>/")

def replace_character_in_file(file_path, old_char, new_char):
    with open(file_path, 'r') as file:
        content = file.read()

    content = content.replace(old_char, new_char)

    with open(file_path, 'w') as file:
        file.write(content)
