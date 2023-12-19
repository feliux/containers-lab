## GPU Nvidia

Instalar drivers nvidia y luego `nvidia-container-toolkit` (AUR). Reiniciar docker.

```sh
$ yay -S nvidia-container-toolkit # Arch
$ systemctl restart docker

docker run --help | grep -i gpus
docker run --gpus all nvidia/cuda:9.0-base nvidia-smi
docker run --gpus 2 nvidia/cuda:9.0-base nvidia-smi # Habilita 2 GPUs en el contenedor
docker run --gpus '"device=1,2"' nvidia/cuda:9.0-base nvidia-smi # GPU específica
docker run --gpus all,capabilities=utility nvidia/cuda:9.0-base nvidia-smi
```

## Docker + Tensorflow

[Tensorflow Docker](https://www.tensorflow.org/install/docker)

```sh
$ docker pull tensorflow/tensorflow:gpu-latest
$ docker pull tensorflow/tensorflow:latest-gpu-jupyter

$ docker run --gpus all -it -u $(id -u):$(id -g) tensorflow/tensorflow:latest-gpu bash

$ nvcc --version # Versión CUDA
$ pip list | grep sorten
$ python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```

Para que tensorflow no use toda la memoria (95% por defecto) le daremos solo el 75%

```python
import tensorflow as tf
gpu_options = tf.GPUOptions(per_process_gpu_memory_fraction=0.75)
s = tf.InteractiveSession(config=tf.ConfigProto(gpu_options=gpu_options))
s.as_default() # Por defecto usa la sesión para el resto de operaciones
tf.global_variables_initializer().run() # Inicia las variables
```

## Docker + DIGITS

[DIGITS](https://docs.nvidia.com/deeplearning/digits/index.html)
