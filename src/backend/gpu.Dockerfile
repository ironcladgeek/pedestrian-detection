# This Dockerfile is intented to be run using github action workflow
# for pushing to docker hub registery
FROM nvidia/cuda:11.6.0-base-ubuntu20.04 AS build1
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    libsm6 \
    libxext6 \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libprotobuf-dev \
    ffmpeg \
    protobuf-compiler \
    gcc \
    g++ \
    cmake \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

FROM build1 AS build2
COPY ./src/backend/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --upgrade pip
RUN pip install \
    --no-cache-dir \
    --user \
    --no-warn-script-location \
    -r /tmp/requirements.txt

FROM build1 AS prod
COPY --from=build2 /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
ENV APP_ENV docker
ENV PYTHONUNBUFFERED 1
WORKDIR /code
COPY ./src/backend/app /code/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
