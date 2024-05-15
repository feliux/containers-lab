FROM python:3.9-slim-bullseye as builder
WORKDIR /tmp
RUN pip install --upgrade pip && \
    pip install --no-warn-script-location virtualenv && \
    python -m venv .env
COPY requirements.txt .
RUN . .env/bin/activate && \
    pip install --no-cache-dir -r requirements.txt


FROM gcr.io/distroless/python3-debian11
# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
# python path
ENV PYTHONPATH=/app/.env/lib/python3.9/site-packages
WORKDIR /app
COPY main.py .
COPY --from=builder /tmp/.env ./.env
ENTRYPOINT ["python", "main.py"]
