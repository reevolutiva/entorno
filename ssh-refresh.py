acme_path = "/home/hosting/reevolutiva-net/traefik/vol/acme.json"
import subprocess
import docker
import json
from file_mannager import list_directories, read_env_file

def run_docker_compose( domain, src_vol, action ):

    if action == "up":
        command = f"./mount.sh {domain} {src_vol}"
    
    elif action == "down":
        command = f"./diactivate-container.sh --src {src_vol} --src-vol '' --delete false"

    subprocess.run( command , shell=True)

# Ejemplo de uso
def load_acme_json( ):
    
    with open( acme_path , 'r') as f:
        acme = json.load(f)
        return acme

def write_acme_json(acme):
    with open( acme_path , 'w') as f:
        json.dump(acme, f)

def delete_ssl_cert( domain ):
   
    acme = load_acme_json()
    ssl_list = acme['reevolutivaresolver']['Certificates']

    certs_list = []

    for i in range(len(ssl_list)):
        if not ssl_list[i]["domain"]["main"] == domain:
            certs_list.append(ssl_list[i])

    acme['reevolutivaresolver']['Certificates'] = certs_list

    write_acme_json(acme)

client = docker.from_env()

def stop_container(container_name):
    container = client.containers.get(container_name)
    container.stop()

def start_container(container_name):
    container = client.containers.get(container_name)
    container.start()

# Regeneracion de un certificado SSL cuando se cloudflare apunta a otro dominio
def ssl_refresh( domain ):

    traefik_container = "traefik-reverse-proxy-reevolutiva-1"
    site_conf_path = f"/home/hosting/reevolutiva-net/{domain}"

    site_config = read_env_file( f"{site_conf_path}/.env" )

    wp_container = site_config["DEMYX_APP_WP_CONTAINER"]
    db_container = site_config["DEMYX_APP_DB_CONTAINER"]

    # Elimina el certificado SSL del ACME.json
    delete_ssl_cert( domain )  # Replace "example.com" with the actual domain

    # Apaga contenedor traefik
    stop_container( traefik_container )

    # Apaga contenedor sitio transferido
    run_docker_compose( domain, site_conf_path, "down" )
    
    #Enciende Traefik
    start_container( traefik_container )

    # Enciende contentendor trasferido
    run_docker_compose( domain, site_conf_path, "up" )

ssl_refresh("coursefactory.lat")
