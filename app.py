from fastapi import FastAPI

app = FastAPI()

@app.post("/mount")
async def mount():
    # Implement mount functionality here
    return {"message": "Mount operation completed"}

@app.post("/unmount")
async def unmount():
    # Implement unmount functionality here
    return {"message": "Unmount operation completed"}

@app.delete("/delete")
async def delete():
    # Implement delete functionality here
    return {"message": "Delete operation completed"}
