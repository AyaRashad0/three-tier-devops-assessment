from fastapi import FastAPI

app = FastAPI(title="Three-Tier Assessment API")


@app.get("/api/message")
def message():
    return {"message": "Hello World"}
