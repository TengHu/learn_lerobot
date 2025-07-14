
Modified on top of https://github.com/runpod/containers/tree/main/official-templates/kasm-desktop


# Workspaces Core Images
This repository contains the base or **"Core"** images from which all other Workspaces images are derived.
These images are based off popular linux distributions and contain the wiring necessary to work within the Kasm platform.

While these images are primarily built to run inside the Kasm platform, they can also be executed manually.  Please note that certain functionality, such as audio, uploads, downloads, and microphone passthrough are only available within the Kasm platform.

The container is now accessible via a browser : `https://<IP>:6901`

 - **User** : `kasm_user`
 - **Password**: `password`


### How to build and push to Docker Hub (nielhu/lerobot)

1. Build the Docker image:
   ```bash
   docker buildx build -f dockerfile-kasm-core-11 -t nielhu/lerobot:cuda11 --build-arg START_XFCE4=1 --build-arg START_PULSEAUDIO=1 .
   ```
2. Log in to Docker Hub:
   ```bash
   docker login
   ```
3. Push the image:
   ```bash
   docker push nielhu/lerobot:cuda11
   ```

## 🚀 Docker Build & Push Optimization Tips

To speed up your builds and pushes:

1. **Use a .dockerignore file** to avoid sending unnecessary files to the Docker daemon. Example:
   ```
   .git
   *.md
   *.log
   __pycache__/
   *.pyc
   node_modules/
   build/
   dist/
   .DS_Store
   .env
   ```
2. **Enable BuildKit** for faster, more efficient builds:
   ```sh
   export DOCKER_BUILDKIT=1
   ```
3. **Use buildx with caching** for even faster builds:
   ```sh
   docker buildx build \
     --build-arg START_XFCE4=1 \
     --build-arg START_PULSEAUDIO=1 \
     --file dockerfile-kasm-core-11 \
     --tag nielhu/lerobot:cuda11 \
     --cache-from=type=registry,ref=nielhu/lerobot:buildcache \
     --cache-to=type=registry,ref=nielhu/lerobot:buildcache,mode=max \
     --push \
     .
   ```
4. **Combine RUN commands and clean up after installs** in your Dockerfile to reduce image size and speed up builds.
5. **Use --no-install-recommends** with apt-get to avoid unnecessary packages.
6. **Push to a geographically close registry** for faster uploads.

# Kasmweb VNC - Ubuntu Remote Desktop CUDA 11.8

## KasmVNC - Linux Web Remote Desktop

This template allows you to access a temporary Ubuntu desktop thanks to usage of KasmVNC

**Default username: kasm_user**

**Default password: password (Unless you change VNC_PW)**

As we run it on runpod.io you get GPU acceleration access that allows you to run programs like you can do on normal linux PC. This image is customized to allow user to access to sudo command for full root access.

## Setup process

1. Edit Environment Variable VNC_PW the default value is password (Make sure to edit it to secure your container)
2. After pod starts go to connect page
3. You will see window asking for username and password (Input username kasm_user and password you set in VNC_PW)
4. If you followed guide you should be able to see your linux desktop!
5. The volume storage is mounted at /workspace

### Know issues:

- Dark Reader extension might cause web ui to not load
- There is no audio support

  RUN apt-get clean && rm -rf /var/lib/apt/lists/*
