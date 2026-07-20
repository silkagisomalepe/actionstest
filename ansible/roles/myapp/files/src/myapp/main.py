from fastapi import FastAPI

from myapp.config import settings

app = FastAPI(debug=settings.DEBUG)


@app.get("/health")
def health_check():
    return {"status": "ok"}
