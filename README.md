# One-click GPU JupyterHub and VS Code Server

This repository based on [this JupyterHub implementation](https://github.com/selenecodes/GPU-jupyterhub)
-----------------------------------------

This repository offers a simple and convenient way to access Nvidia GPUs using the nvidia-docker-2 container runtime, with added features like code-server and X-server support.

## Todo List

- [ ] Fix permission to access the user folder
- [ ] Enable the use of Docker Swarm mode
- [ ] Support to deploy with k8s

## 1. Requirements
To use this implementation, you must have the following installed on your system:
- A CUDA driver
- Docker 19.03 or higher
- Docker Compose 1.25.5 or higher

You can check if a CUDA driver is installed on your system by running `nvidia-smi` in the terminal. I recommend following the [DigitalOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04) to install Docker Compose, and make sure to change the version number to 1.25.5. Additionally, the nvidia-container-runtime needs to be installed:
```bash
sudo apt-get install nvidia-container-runtime
```

Nvidia-docker2 also needs to be installed; refer to their [Github](https://github.com/NVIDIA/nvidia-docker) repository for instructions.


## 2. Installation
### 2.1 Preparation
To enable `runtime: nvidia`, we need to modify the ```/etc/docker/daemon.json``` file as follows:
```json
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}

```

### 2.2 Building our notebook containers
We can now build our notebook containers with:
```bash
docker build -t "vscode-notebook:lastest" -f ./dockerfile/Dockerfile.notebook
```

### 2.3 Building the hub
Run the following command to start the JupyterHub server:

```bash
bash start_jupyterhub.sh
```

When running the script, you will be prompted to enter the following environment variables:

- **NGROK_AUTH**: This is necessary because the JupyterHub uses the ngrok service to obtain a public domain. To get an authenticated token, you must log in to the [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken).
- **HOST_PERSONAL_NETWORK_FOLDER**: This variable is used to mount your personal folder volume to your JupyterHub server.
- **HOST_SHARED_NETWORK_FOLDER**: This variable is used to mount your shared folder volume to your JupyterHub server.

After running the script successfully, you can get the JupyterHub server public domain at ```http://<your-ip>:4551``` (if you are running it locally, replace ```<your-ip>``` with `localhost`). Alternatively, you can access it through the native port ```https://<your-ip>:443``` and log in with the administrator username/password ```admin/admin```.

**Note:** Remember to change the userlist file to include your username and password. You can add users to the list using the following example:
```
admin admin
user1 user1
user2 user2
```

### 2.4 Common Issues
- Volume `jupyterhub-db-data` or `jupyterhub-data` not found.
```bash
docker volume create --name="jupyterhub-data"
```
- Network `jupyterhub-network` not found.
```bash
docker network create "jupyterhub-network"
```

By following these steps, you will have a fully-functional JupyterHub and VS Code server with GPU access. If you encounter any issues, please refer to the common issues section for more information.

