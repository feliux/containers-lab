# Docker Swarm

[Swarm](https://enmilocalfunciona.io/cluster-de-docker-con-swarm-mode/)

[Compose, Machine, Swarm](https://www.adictosaltrabajo.com/2015/12/03/docker-compose-machine-y-swarm/)

[Docker Swarm con scripts](https://mmorejon.io/blog/docker-swarm-con-docker-machine-scripts/)

```sh
$ docker swarm join --token <token> <IP>:2377 # Añadir nodos al clúster

$ eval $(docker-machine env <host>) # Entrar en el clúster

$ docker node ls
$ docker node promote <host> # Añadir nodo como manager

$ docker service ls
$ docker service ls | awk '{print $5}' | uniq

$ docker service scale <service>=0
```
