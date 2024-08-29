# Import necessary modules and classes
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends, HTTPException
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


# Configuration for JWT
SECRET_KEY = "hFa8u29!)kT2r387l?"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Password context for hashing and verification
pwd_context = CryptContext(schemes=["bcrypt"])

# Fake users database
fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "$2a$12$nYxwJr3Ho3P5Rox87cZ3zeBAY4PQdXSdIzFSAV3MOHvnOg.H3Nw0a", # jeremias123
        "disabled": False,
    },
    "alice": {
        "username": "alice",
        "full_name": "Alice Wonderson",
        "email": "alice@example.com",
        "hashed_password": "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW",
        "disabled": True,
    },
    "newuser": {
        "username": "newuser",
        "full_name": "New User",
        "email": "newuser@example.com",
        "hashed_password": "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW",
        "disabled": False,
    },
}

# Create FastAPI app instance
app = FastAPI()

# Set up OAuth2 password bearer for token-based authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Define a Pydantic model for token data
class TokenData(BaseModel):
    username: str = None

def user_validate(user_db, data):
    data = json.loads(data)
    token = data['token']
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:                
        return { "status": False , "data": data}
    
    username: str = payload.get("sub")
    
    user = user_db.get(username, False)
    
    return { "status": user , "data": data}


@app.websocket("/app-clone")
async def app_clone(websocket: WebSocket, data: Dict[str, str] = None ):
    await websocket.accept()
    try:
        while True:
            if True:
                data_raw = await websocket.receive_text()                
                user = user_validate( fake_users_db, data_raw  )                
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
                data_raw = await websocket.receive_text()                
                user = user_validate( fake_users_db, data_raw  )                
                data = user['data']
                                
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
                data_raw = await websocket.receive_text()                
                user = user_validate( fake_users_db, data_raw  )                
                data = user['data']
                                
                domain = data.get("domain", "undefined") #Specify the source path
                src_vol = data.get("src_vol", "undefined")
                
                command = f"./mount.sh {domain} {src_vol}"
                #./wp-create.sh --domain lore.reevolutiva.com --app lorereev --email ti@reevolutiva.com --db-password NMlGQzwxF9GRFsOXD0xj --db-user 4DM1N --wp-user 4DM1N --wp-password NMlGQzwxF9GRFsOXD0xj --db-name lore_bd --is-bedrock false
     
                await websocket.send_json({ "msg": f"Montando {domain}" })
                subprocess.run( command , shell=True)
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
            data_raw = await websocket.receive_text()
            user = user_validate( fake_users_db, data_raw  )                
            data = user['data']
            
            domain = data.get("domain", "undefined") #Specify the source path
            src = data.get("src", "undefined") #Specify the source path
            src_vol = data.get("src_vol", "undefined")
            
            command = f"./diactivate-container.sh --src {src} --src-vol {src_vol} --delete false"
            
            await websocket.send_json({ "msg": f"Desmontando {domain}" })
            subprocess.run( command , shell=True)
            await websocket.send_json({ "msg": f"{domain} desmontado" })
    except WebSocketDisconnect:
        pass

# Define a WebSocket endpoint for the delete operation
@app.websocket("/delete")
async def delete(websocket: WebSocket, data: Dict[str, str] = None ):
    await websocket.accept()
    try:
        while True:
            data_raw = await websocket.receive_text()
            user = user_validate( fake_users_db, data_raw  )                
            data = user['data']
            
            domain = data.get("domain", "undefined") #Specify the source path
            src = data.get("src", "undefined") #Specify the source path
            src_vol = data.get("src_vol", "undefined")
            
            command = f"./diactivate-container.sh --src {src} --src-vol {src_vol} --delete true"
            
            await websocket.send_json({ "msg": f"Desmontando {domain}" })
            await websocket.send_json({ "msg": f"Eliminando {domain}" })
            subprocess.run( command , shell=True)
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
async def site_list(token: str = Depends(oauth2_scheme), data : Dict[str, str] = None):
    
    print( "data" )
    print( data )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        user = fake_users_db.get(username)
        if user is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return {"sites": list_directories("/home/hosting/") }
    except JWTError:
        raise HTTPException(
            status_code=401,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
# Define a GET endpoint for the hello operation
@app.post("/site-config")
async def site_list(token: str = Depends(oauth2_scheme), data : Dict[str, str] = None):
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        user = fake_users_db.get(username)
        if user is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )
            
        site = data.get("site", "undefined")
        site_path = data.get("site_path", "undefined")
    
        return {"site": site, "env_list": read_env_file( site_path ) }
    
    except JWTError:
        raise HTTPException(
            status_code=401,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
        
# Define a put endpoint for the hello operation
@app.put("/site-config")
async def site_list(token: str = Depends(oauth2_scheme), data : Dict = None):
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        user = fake_users_db.get(username)
        if user is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )
            
        site = data.get("site", "undefined")
        site_path = data.get("site_path", "undefined")
        vars_to_chage = data.get("vars_to_chage", "undefined")
        
        print("vars_to_chage")
        print(data)
        return data
    
        for var in vars_to_chage:        
            key = var['key']
            value = var['value']
            #buscar_archivo_env( site_path, var["key"] , var["value"] )    
     
        #return {"site": site, "env_list": vars_to_chage }
    
    except JWTError:
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
@app.get("/site-status/{domain}")
async def site_status(domain: str, token: str = Depends(oauth2_scheme) ):
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            username: str = payload.get("sub")
            if username is None:
                raise HTTPException(
                    status_code=401,
                    detail="Invalid token",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            user = fake_users_db.get(username)
            if user is None:
                raise HTTPException(
                    status_code=401,
                    detail="Invalid token",
                    headers={"WWW-Authenticate": "Bearer"},
                )
                
            client = docker.from_env()
            containers = client.containers.list()
    
            active_containers = []
            for container in containers:
                
                config_file = container.labels["com.docker.compose.project.config_files"]
                service = container.labels["com.docker.compose.service"]
                
                #print( container.labels )
                
                active_containers.append({ 
                    "name": container.name, 
                    "status": container.status, 
                    "id": container.id,
                    "docker-compose" : config_file,
                    "service": service,
                })
                    
            return {"active_containers": active_containers }
                
           
            
        except JWTError:
            raise HTTPException(
                status_code=401,
                detail="Invalid token",
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