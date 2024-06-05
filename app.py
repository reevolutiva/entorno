# Import necessary modules and classes
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends, HTTPException
from typing import List, Dict
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
import subprocess

# Configuration for JWT
SECRET_KEY = "your-secret-key"
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

# Define a class for managing WebSocket connections
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket, token: str = Depends(oauth2_scheme)):
        try:
            # Accept the WebSocket connection and add it to the list of active connections
            await websocket.accept()
            self.active_connections.append(websocket)
        except Exception:
            raise HTTPException("Invalid token")

    def disconnect(self, websocket: WebSocket):
        # Remove the WebSocket connection from the list of active connections
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        # Send a personal message to the specified WebSocket connection
        await websocket.send_text(message)

# Create an instance of the ConnectionManager class
manager = ConnectionManager()

# Define a WebSocket endpoint for the mount operation
@app.websocket("/mount")
async def mount(websocket: WebSocket, token: str = Depends(oauth2_scheme), data: Dict[str, str] = None):
    await manager.connect(websocket, token)
    try:
        while True:
            if data is not None:
                app = data.get("app", "reev") #Specify the app name
                domain = data.get("domain", "jw.org") #Specify the domain
                email = data.get("email", "ti@reevolutiva.com") #Specify the email
                db_password = data.get("db_password", "your-db-password") #Specify the database password
                db_user = data.get("db_user", "your-db-user") #Specify the database user
                wp_user = data.get("wp_user", "your-wp-user") #Specify the WordPress user
                wp_password = data.get("wp_password", "your-wp-password") #Specify the WordPress password
                new_db_name = data.get("new_db_name", "your-new-db-name") #Specify the new database name
                is_bedrock = data.get("is_bedrock", "true") #Specify if it is a Bedrock app (true/false)
                
                subprocess.run(f"./reciber.sh -a {app} -d {domain} -e {email} -p {db_password} -u {db_user} -w {wp_user} -wp {wp_password} -n {new_db_name} -b {is_bedrock}")
                await manager.send_personal_message(f"Mount operation completed: {data}", websocket)
            else:
                await manager.send_personal_message("Invalid data format", websocket)
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# Define a WebSocket endpoint for the unmount operation
@app.websocket("/unmount")
async def unmount(websocket: WebSocket, token: str = Depends(oauth2_scheme)):
    await manager.connect(websocket, token)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"Unmount operation completed: {data}", websocket)
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# Define a WebSocket endpoint for the delete operation
@app.websocket("/delete")
async def delete(websocket: WebSocket, token: str = Depends(oauth2_scheme)):
    await manager.connect(websocket, token)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"Delete operation completed: {data}", websocket)
    except WebSocketDisconnect:
        manager.disconnect(websocket)

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
@app.get("/hello")
async def hello(token: str = Depends(oauth2_scheme), data : Dict[str, str] = None):
    
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
        return {"message": f"Hello, {user['full_name']}"}
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
