import sys
from uvicorn import run

if __name__ == "__main__":
    sys.exit(run("app:app", host="0.0.0.0", port=5000, reload=False, access_log=True))
