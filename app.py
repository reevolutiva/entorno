from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends
from typing import List
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from pydantic import BaseModel

app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

class TokenData(BaseModel):
    username: str = None

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket, token: str = Depends(oauth2_scheme)):
        try:
            payload = jwt.decode(token, "secret", algorithms=["HS256"])
            username = payload.get("sub")
            if username is None:
                raise JWTError("Invalid token")
            await websocket.accept()
            self.active_connections.append(websocket)
        except JWTError:
            raise JWTError("Invalid token")

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

manager = ConnectionManager()

@app.websocket("/mount")
async def mount(websocket: WebSocket, token: str = Depends(oauth2_scheme)):
    await manager.connect(websocket, token)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"Mount operation completed: {data}", websocket)
    except WebSocketDisconnect:
        manager.disconnect(websocket)

@app.websocket("/unmount")
async def unmount(websocket: WebSocket, token: str = Depends(oauth2_scheme)):
    await manager.connect(websocket, token)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"Unmount operation completed: {data}", websocket)
    except WebSocketDisconnect:
        manager.disconnect(websocket)

@app.websocket("/delete")
async def delete(websocket: WebSocket, token: str = Depends(oauth2_scheme)):
    await manager.connect(websocket, token)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"Delete operation completed: {data}", websocket)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
