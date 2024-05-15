# Scipy - Pytorch

Build image based on nvidia/cuda:10.2-base-ubuntu18.04 & Jupyter Docker Stacks for running pytorch-notebooks on GPU.

- Pull from DockerHub or build the image

`docker pull feliux/gpu-scipy-pytorch-notebook`

`docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t feliux/gpu-scipy-pytorch-notebook:1.0.0 .`

- Run your container

`docker run -d --gpus all --name gpu-pytorch -v $PWD:/home/jovyan/work -p 8888:8888 feliux/gpu-scipy-pytorch-notebook:1.0.0`

- Test installed packages

~~~
docker exec -it gpu-pytorch python
>>> import torch; torch.cuda.is_available()
True
~~~

- Connect to your notebook

`docker exec -t <container_name> jupyter-notebook list`

- Paste url/token in your favourite browser

### References

[Scipy Pytorch DockerHub](https://hub.docker.com/r/feliux/gpu-scipy-pytorch-notebook)

[Nvidia CUDA DockerHub](https://hub.docker.com/r/nvidia/cuda)

[Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/)

[NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker#nvidia-container-toolkit)
