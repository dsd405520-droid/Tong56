from fastapi import FastAPI
import importlib
import os
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI()

origins = [o.strip() for o in os.getenv("CORS_ORIGIN", "").split(",") if o.strip()]
if not origins:
    origins = ["http://localhost:8000"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins, 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

print("CORS ORIGINS LOADED:", origins)

ROUTER_DIR = "router"
if os.path.exists(ROUTER_DIR):
    for root, dirs, files in os.walk(ROUTER_DIR):
        for filename in files:
            if filename.endswith(".py") and filename != "__init__.py":
                filepath = os.path.join(root, filename)
                module_name = filepath.replace(os.sep, ".")[:-3]
                route_module = importlib.import_module(module_name)
                if hasattr(route_module, "router"):
                    app.include_router(route_module.router)
else:
    print(f"Warning: Directory {ROUTER_DIR} not found")