# ARGS at this level referenced only by FROMs
ARG BASE_IMAGE=python:3.8.5-alpine3.12

# --------------------------------------
# Build dependencies in build stage
# --------------------------------------
FROM ${BASE_IMAGE} as builder
    
WORKDIR /app

# Cache installed dependencies between builds
COPY ./requirements.txt ./requirements.txt
RUN pip install -r ./requirements.txt --user

# --------------------------------------
# Create final container loaded with app
# --------------------------------------
FROM ${BASE_IMAGE}

LABEL scenario=pure-chaos

ENV USER=docker GROUP=docker \
    UID=12345 GID=23456 \
    HOME=/app PYTHONUNBUFFERED=1

# Create user/group
RUN addgroup --gid "${GID}" "${GROUP}" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "${GROUP}" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR ${HOME}

# TODO, will switching user work?
# USER ${USER}

COPY --from=builder /root/.local /usr/local
COPY --chown=${USER}:${GROUP} . .

CMD ["python", "chaos.py"]
