# Import necessary modules and classes
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends, HTTPException, File, UploadFile
from typing import List, Dict
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
import subprocess
import json
import os
from file_mannager import list_directories, read_env_file
from stage import create_folder, copy_directory_contents, run_docker_compose_up, copy_file_contents, replace_character_in_file
from docker_config_mod import buscar_archivo_env
import docker
import psutil
from fastapi.middleware.cors import CORSMiddleware
import requests
import zipfile
import shutil

abs_path = os.path.abspath(os.path.dirname(__file__))

def get_directory_size(directory):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(directory):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            # Sumar el tamaño del archivo
            total_size += os.path.getsize(fp)
    return total_size

# Create FastAPI app instance
app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set up OAuth2 password bearer for token-based authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Define a Pydantic model for token data
class TokenData(BaseModel):
    username: str = None



def user_validate(username, password):   
     
    try:
        response = requests.post("https://gscdesigns.net/wp-json/reev-host/v1/login/", data={"username": username, "password": password})
        response_data = response.json()
        
        return response_data     

    
    except requests.exceptions.RequestException as e:
        return { "error": str(e), 'ok': False }

    



@app.websocket("/app-clone")
async def app_clone(websocket: WebSocket, data: Dict[str, str] = None ):
    await websocket.accept()
    try:
        while True:
            if True:
                
                data_raw = await websocket.receive_json()   
                
                username = data_raw.get("username", "undefined")
                password = data_raw.get("password", "undefined")               

                user = user_validate( username, password  )                
                data = user['data']
                
                origin_domain = data.get("origin_domain", "undefined")  #Specify the domain
                stage_domain = data.get("stage_domain", "undefined")  #Specify the domain
                
                compose_path = "/home/hosting/reevolutiva-net/"
                
                # STEP 1: Creo los directorios para el stage.
                create_folder( stage_domain, "/home/hosting/", compose_path )
                
                await websocket.send_json({ "msg": f"Preparandoce para clonar {origin_domain}" })

                #STEP 2: Copio el contenido de la carpeta original a la carpeta stage.domain.tld
                copy_directory_contents(f"{compose_path}{origin_domain}/", f"{compose_path}{stage_domain}/")
                copy_file_contents(f"{compose_path}{origin_domain}/docker-compose.yml", f"{compose_path}{stage_domain}/docker-compose.yml")
                copy_file_contents(f"{compose_path}{origin_domain}/.env", f"{compose_path}{stage_domain}/.env")
                copy_directory_contents(f"/home/hosting/{origin_domain}/", f"/home/hosting/{stage_domain}/" )
                replace_character_in_file( f"{compose_path}{stage_domain}/.env", origin_domain, stage_domain )
                replace_character_in_file( f"{compose_path}{stage_domain}/docker-compose.yml", origin_domain, stage_domain )
                replace_character_in_file( f"{compose_path}{stage_domain}/docker-compose.yml", '${DEMYX_APP_COMPOSE_PROJECT}' , stage_domain )
                
                await websocket.send_json({ "msg": f"Cargando configuraciones de {stage_domain}" })


                #STEP 3: Levanto el docker-compose
                run_docker_compose_up(f"{compose_path}{stage_domain}/")
                
                await websocket.send_json({ "msg": f"{stage_domain} Levantado" })
                
                await websocket.send_json({ "action": 'create-clone' , "data": data })
                
    except WebSocketDisconnect as e:
        print(f"WebSocket disconnected: {e}")

# Define a WebSocket endpoint for the create operation
@app.websocket("/create")
async def mount(websocket: WebSocket, data: Dict[str, str] = None ):
    await websocket.accept()
    try:
        while True:
            if True:
                data_raw = await websocket.receive_json()      
                username = data_raw.get("username", "undefined")
                password = data_raw.get("password", "undefined")
                      
                user = user_validate( username, password  )      
                
                if user['ok'] == False:
                    return { "error": user.error }
                
                if user['ok'] == True:        
                                
                    app = data.get("app", "undefined") #Specify the app name
                    domain = data.get("domain", "undefined") #Specify the domain
                    email = data.get("email", "undefined") #Specify the email
                    db_password = data.get("db_password", "undefined") #Specify the database password
                    db_user = data.get("db_user", "undefined") #Specify the database user
                    wp_user = data.get("wp_user", "undefined") #Specify the WordPress user
                    wp_password = data.get("wp_password", "undefined") #Specify the WordPress password
                    new_db_name = data.get("new_db_name", "undefined") #Specify the new database name
                    is_bedrock = data.get("is_bedrock", "false") #Specify if it is a Bedrock app (true/false)
                    
                    command = f"./wp-create.sh --domain {domain} --app {app} --email {email} --db-password {db_password} --db-user {db_user} --wp-user {wp_user} --wp-password {wp_password} --db-name {new_db_name} --is-bedrock {is_bedrock}"
                    #./wp-create.sh --domain lore.reevolutiva.com --app lorereev --email ti@reevolutiva.com --db-password NMlGQzwxF9GRFsOXD0xj --db-user 4DM1N --wp-user 4DM1N --wp-password NMlGQzwxF9GRFsOXD0xj --db-name lore_bd --is-bedrock false
                    await websocket.send_json({ "msg": f"Creando {domain}" })
                    subprocess.run( command , shell=True)
                    await websocket.send_json({ "msg": f"{domain} ha sido creado" })
            else:
                await websocket.send_text("Invalid data format")
    except WebSocketDisconnect as e:
        print(f"WebSocket disconnected: {e}")


# Define a WebSocket endpoint for the create mount
@app.websocket("/mount")
async def mount(websocket: WebSocket, data: Dict[str, str] = None ):
    await websocket.accept()
    try:
        while True:
            if True:
                
                data_raw = await websocket.receive_json()
                username = data_raw.get("username", "undefined")
                password = data_raw.get("password", "undefined")
                domain = data_raw.get("domain", "undefined") #Specify the source path
                src_vol = data_raw.get("src_vol", "undefined")              
                 
                user = user_validate( username, password  )      
                
                if user['ok'] == False:
                    return { "error": user.error }
                if user['ok'] == True:       
                
                    command = f"./mount.sh {domain} {src_vol}"
                    #./wp-create.sh --domain lore.reevolutiva.com --app lorereev --email ti@reevolutiva.com --db-password NMlGQzwxF9GRFsOXD0xj --db-user 4DM1N --wp-user 4DM1N --wp-password NMlGQzwxF9GRFsOXD0xj --db-name lore_bd --is-bedrock false
        
                    await websocket.send_json({ "msg": f"Montando {domain}" })
                    #subprocess.run( command , shell=True)
                    await websocket.send_json({ "msg": f"{domain} Montado" })
            else:
                await websocket.send_text("Invalid data format")
    except WebSocketDisconnect as e:
        print(f"WebSocket disconnected: {e}")

# Define a WebSocket endpoint for the unmount operation
@app.websocket("/unmount")
async def unmount(websocket: WebSocket, data: Dict[str, str] = None):
    await websocket.accept()
    try:
        while True:
            data_raw = await websocket.receive_json()
            username = data_raw.get("username", "undefined")
            password = data_raw.get("password", "undefined")
            
           
            user = user_validate( username, password  )    
            
            if user['ok'] == False:
                return { "error": user.error }
            
            if user['ok'] == True:            
                domain = data_raw.get("domain", "undefined") #Specify the source path
                src = data_raw.get("src", "undefined") #Specify the source path
                src_vol = data_raw.get("src_vol", "undefined")
                
                command = f"./diactivate-container.sh --src {src} --src-vol {src_vol} --delete false"
                
                await websocket.send_json({ "msg": f"Desmontando {domain}" })
                #subprocess.run( command , shell=True)
                await websocket.send_json({ "msg": f"{domain} desmontado" })
    except WebSocketDisconnect:
        pass

# Define a WebSocket endpoint for the delete operation
@app.websocket("/delete")
async def delete(websocket: WebSocket, data: Dict[str, str] = None ):
    await websocket.accept()
    try:
        while True:
            data_raw = await websocket.receive_json()
            
            username = data_raw.get("username", "undefined")
            password = data_raw.get("password", "undefined")
            domain = data_raw.get("domain", "undefined") #Specify the source path
            src = data_raw.get("src", "undefined") #Specify the source path
            src_vol = data_raw.get("src_vol", "undefined")
            
            user = user_validate( username, password  )     
            
            if user['ok'] == False:
                return { "error": user.error }
            
            if user['ok'] == True:           
                
                command = f"./diactivate-container.sh --src {src} --src-vol {src_vol} --delete true"
                
                await websocket.send_json({ "msg": f"Desmontando {domain}" })
                await websocket.send_json({ "msg": f"Eliminando {domain}" })
                #subprocess.run( command , shell=True)
                await websocket.send_json({ "msg": f"Desmontado y elmiminado {domain}" })
                
    except WebSocketDisconnect:
        pass

# Define a POST endpoint for token authentication
@app.post("/token")
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = fake_users_db.get(form_data.username)
    if not user or not pwd_context.verify(form_data.password, user.get("hashed_password")):
        raise HTTPException(
            status_code=401,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["username"]}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

# Define a GET endpoint for the hello operation
@app.get("/site-list")
async def site_list( data : Dict[str, str] = None):
    
    try:
        
        username = data.get("username", "undefined")
        password = data.get("password", "undefined")
        
        user = user_validate( username, password  )
        
        if user['ok'] == False:
            return { "error": user.error }
        
        if user['ok'] == True:
            return {"sites": list_directories("/home/hosting/") }
        
    except :
        raise HTTPException(
            status_code=401,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
# Define a GET endpoint for the hello operation
@app.post("/site-config")
async def site_list( data : Dict[str, str] = None):
    
    try:
        
           
        username = data.get("username", "undefined")
        password = data.get("password", "undefined")
            
        site = data.get("site", "undefined")
        site_path = data.get("site_path", "undefined")
        
        user = user_validate( username, password  )
        
        if user['ok'] == False:
            return { "error": user.error }
        
        if user['ok'] == True:    
            return {"site": site, "env_list": read_env_file( site_path ) }
    
    except :
        raise HTTPException(
            status_code=401,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
        
# Define a put endpoint for the hello operation
@app.put("/site-config")
async def site_list(token: str = Depends(oauth2_scheme), data : Dict = None):
    
    try:
       
        username = data.get("username", "undefined")
        password = data.get("password", "undefined")
            
        site = data.get("site", "undefined")
        site_path = data.get("site_path", "undefined")
        vars_to_chage = data.get("vars_to_chage", "undefined")
        
        user = user_validate( username, password  )
        
        if user['ok'] == False:
            return { "error": user.error }
        
        if user['ok'] == True:        

            return data
        
            for var in vars_to_chage:        
                key = var['key']
                value = var['value']
                #buscar_archivo_env( site_path, var["key"] , var["value"] )    
     
        #return {"site": site, "env_list": vars_to_chage }
    
    except :
        raise HTTPException(
            status_code=401,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )

# Function to create access token
def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

    # Define a GET endpoint for the site status operation
@app.get("/site-status")
async def site_status(  username: str = None, password: str = None ):         
        
    user = user_validate( username, password  )
            
    if user['ok'] == False:
        return { "error": user }
            
    if user['ok'] == True:
            
        try: 
                
            client = docker.from_env()
            containers = client.containers.list()
                
            active_containers = []
                
            for container in containers:
                    
                config_file = container.labels["com.docker.compose.project.config_files"]
                service = container.labels["com.docker.compose.service"]
         
                    
                active_containers.append({ 
                    "name": container.name, 
                    "status": container.status, 
                    "id": container.id,
                    "docker-compose" : config_file,
                    "service": service,
                })
                        
            return {"active_containers": active_containers }
            
        except:

            raise HTTPException(
                status_code=401,
                detail="A ocurrido un error al intentar conectarse a Docker",
                headers={"WWW-Authenticate": "Bearer"},
            )
               
                
           
            
        


@app.get("/server-system")
async def server_system():
    
    
    # Uso del CPU
    cpu_usage = psutil.cpu_percent()
    # Uso de la memoria
    memory_usage = psutil.virtual_memory().percent
    # Uso del disco
    disk_usage = psutil.disk_usage("/").percent
                
    return {
        "cpu_usage": cpu_usage,
        "memory_usage": memory_usage,
        "disk_usage": disk_usage
    }
    
# Define a POST endpoint for receiving transfer data
@app.post("/transfer-receive")
async def transfer_receive(site: str, filename: str, file: UploadFile = File(...)):
    
    #TODO: Add user validation
    # Leer el contenido del archivo
    contents = await file.read()
    
    if not os.path.exists('recive/'):
        os.makedirs('recive/')
    
    path = f"recive/{site}/"
    
    # Crear el directorio si no existe
    if not os.path.exists(path):
        os.makedirs(path)

    
    # Procesar el archivo (por ejemplo, guardarlo en el sistema de archivos)
    with open( f"{path}/{filename}", "wb") as f:
        f.write(contents)
    
    # Proporcionar una respuesta para indicar que el archivo ha sido creado
    return {"msg": f"New {filename} created in {path}"}

# Define a WebSocket endpoint for the transfer operation
@app.post("/transfer")
async def transfer(data: Dict[str, str] = None):
    #TODO: Add user validation
    domain = data.get("domain", "undefined")  # Specify the domain
    destiny_ip = data.get("destiny_ip" , "undefined")  # Specify the destiny IP
    destiny_port = data.get("destiny_port", "undefined")  # Specify the destiny port,
    docker_vols = data.get("docker_vols", "undefined")  # Specify the docker volumes
    docker_route = data.get("docker_route", "undefined")  # Specify the docker route
    
    env_list = read_env_file(f"{docker_route}/.env")

    print(data)

    # command = f"./transfer.sh {domain}" 
    # subprocess.run(command, shell=True)
    
    conf_filename = f"{domain}-conf.zip"
    requests.post(
        f"http://{destiny_ip}:{destiny_port}/transfer-receive?filename={conf_filename}&site={domain}",
        files={"file": open(f"/home/hosting/trasnfer/{domain}/{conf_filename}", "rb")}
    )
    
    db_filename = f"{domain}-db.zip"
    requests.post(
        f"http://{destiny_ip}:{destiny_port}/transfer-receive?filename={db_filename}&site={domain}",
        files={"file": open(f"/home/hosting/trasnfer/{domain}/{db_filename}", "rb")}
    )
    
    wp_filename = f"{domain}-wp.zip"
    requests.post(
        f"http://{destiny_ip}:{destiny_port}/transfer-receive?filename={wp_filename}&site={domain}",
        files={"file": open(f"/home/hosting/trasnfer/{domain}/{wp_filename}", "rb")}
    )
    
    return {"msg": f"Transfer completed from {domain} to {destiny_ip}"}
            



# Define a POST endpoint for site installation
@app.post("/site-install")
async def site_install( domain: str, vol_path: str, vol_type: str = False):

    # Extract necessary data from the request
    path_unzip = f"{abs_path}/recive/{domain}/"

    # Unzip the files
    def unzip_file(zip_path, extract_path):
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_path)

    unzip_file(f"{path_unzip}{vol_path}", f"recive/{domain}/")

    source_dir = f"{abs_path}/recive/{domain}/{vol_path}"
    destination_dir = f"/home/hosting/{domain}"

    # Validate that destination_dir exists
    if not os.path.exists(destination_dir):
        os.makedirs(destination_dir)

    if vol_type == "docker-compose":

        # Valida que exista /home/hosting/reevolutiva-net/{domain}/
        if not os.path.exists(f"/home/hosting/reevolutiva-net/{domain}/"):
            os.makedirs(f"/home/hosting/reevolutiva-net/{domain}/")

        # Docker compose
        shutil.move( f"/home/entorno/recive/{domain}/home/hosting/reevolutiva-net/{domain}/.env", f'/home/hosting/reevolutiva-net/{domain}/.env' )
        shutil.move( f"/home/entorno/recive/{domain}/home/hosting/reevolutiva-net/{domain}/docker-compose.yml", f'/home/hosting/reevolutiva-net/{domain}/docker-compose.yml' )

    if vol_type == "wp":
        # WordPress
        shutil.move( f"/home/entorno/recive/{domain}/home/hosting/{domain}/wp", f"{destination_dir}/" )

    if vol_type == "db":
        # Database
        shutil.move( f"/home/entorno/recive/{domain}/home/hosting/{domain}/db", f"{destination_dir}/" )

    
    # Elimina la carpeta en el directorio /home/entorno/recive/{domain}/home
    shutil.rmtree(f"/home/entorno/recive/{domain}/home")

    return {"msg": f"Site {domain} installed"}
    
@app.get("/transfer-status/{domain}")
async def transfer_status(domain: str, username: str = None, password: str = None):

    user = user_validate( username, password  )

    if user['ok'] == False:
        return { "error": True }

    
    file_info = []
    for file in os.listdir(f"/home/hosting/{domain}"):

        file_path = os.path.join(f"/home/hosting/{domain}", file)
        size = get_directory_size(file_path)
        modified_time = os.path.getmtime(file_path)
        formatted_time = datetime.fromtimestamp(modified_time).strftime('%H:%M %d-%m-%Y')
        size_gb = size / (1024 * 1024 * 1024)
        size_mb = size / (1024 * 1024)
        size_kb = size / 1024

        file_info.append({"file": file, "src": file_path,  "size": [f"{size_gb:.2f} GB", f"{size_mb:.2f} MB", f"{size_kb:.2f} KB"], "modified_time": formatted_time})

    # Valida que exista f"/home/hosting/reevolutiva-net/{domain}
    if not os.path.exists(f"/home/hosting/reevolutiva-net/{domain}"):
        os.makedirs(f"/home/hosting/reevolutiva-net/{domain}")

    file_path = os.path.join(f"/home/hosting/reevolutiva-net/{domain}")
    size = get_directory_size(file_path)
    modified_time = os.path.getmtime(file_path)
    formatted_time = datetime.fromtimestamp(modified_time).strftime('%H:%M %d-%m-%Y')
    size_gb = size / (1024 * 1024 * 1024)
    size_mb = size / (1024 * 1024)
    size_kb = size / 1024
    
    file_info.append({"file": "conf" , "src": file_path,  "size": [f"{size_gb:.2f} GB", f"{size_mb:.2f} MB", f"{size_kb:.2f} KB"], "modified_time": formatted_time})


    if ( len( file_info ) == 0 ):
        # Use shutil to list the contents of the directory
        directory = f"/home/entorno/recive/{domain}"
        contents = os.listdir(directory)
        file_info = []
        for file in contents:
            file_path = os.path.join(directory, file)
            size = os.path.getsize(file_path)
            modified_time = os.path.getmtime(file_path)
            formatted_time = datetime.fromtimestamp(modified_time).strftime('%H:%M %d-%m-%Y')
            size_gb = size / (1024 * 1024 * 1024)
            size_mb = size / (1024 * 1024)
            size_kb = size / 1024
            file_info.append({"file": file, "size":  [f"{size_gb:.2f} GB" , f"{size_mb:.2f} MB", f"{size_kb:.2f} KB" ], "modified_time": formatted_time})

    return {"data": file_info}
