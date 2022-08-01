#
# MLFLOW - MULTISTAGE DOCKERFILE
#

# BASE IMAGE
FROM python:3.10-slim-bullseye AS base

# create the user
ENV USER=mlflow
RUN useradd --create-home $USER
WORKDIR /home/$USER

# create & activate the vitual environment
ENV VENV=/opt/venv
RUN python3 -m venv $VENV
ENV PATH="$VENV/bin:$PATH"


# BUILDER IMAGE
FROM base AS build
ARG mlflow_version

# install system build dependencies
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        build-essential libpq-dev

# install Python runtime dependencies
COPY ./requirements.txt .
RUN pip install \
    mlflow[extras]==$mlflow_version \
    -r requirements.txt


# RUNTIME IMAGE
FROM base AS runtime

# copy virtual env from the build image to the runtime image
COPY --from=build $VENV $VENV

# activate user
USER $USER

EXPOSE 80
CMD mlflow server --host 0.0.0.0 --port 80
