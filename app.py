# Import necessary modules and classes
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends, HTTPException
from typing import List
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel

fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "fakehashedsecret",
        "disabled": False,
    },
    "alice": {
        "username": "alice",
        "full_name": "Alice Wonderson",
        "email": "alice@example.com",
        "hashed_password": "fakehashedsecret2",
        "disabled": True,
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
async def mount(websocket: WebSocket, token: str = Depends(oauth2_scheme)):
    await manager.connect(websocket, token)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"Mount operation completed: {data}", websocket)
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
    if not user or not user.get("hashed_password") == form_data.password:
        raise HTTPException(
            status_code=401,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return {"access_token": user["username"], "token_type": "bearer"}
