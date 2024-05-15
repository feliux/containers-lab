# Rlab

This repository contains some **R** services for data science.

### Components

- **RStudio**

- **Shiny**

### Deployment

Deploy services running the following command

`docker-compose up -d`

### Usage

Access to *RStudio* on `localhost:8787` with credentials `rstudio / changeme`.

You can get your *Shiny* app available on `localhost:3838` but first be sure that you add all neccesary files on the mounted path `/shinyapps`. Follow this [link](https://shiny.rstudio.com/) for further information about *Shiny*.

### Extra

I provide a simple script for running a **R-script** directly when the container starts. In the following example you can see a simple test *hello world*

~~~
$ bash generate-rscript.sh 
Step 1/4 : FROM rocker/tidyverse:latest
 ---> 0d0d7e3baa35
Step 2/4 : ADD r-files /working-dir
 ---> Using cache
 ---> d6d8c13ea0d5
Step 3/4 : WORKDIR /working-dir
 ---> Using cache
 ---> b8a459c968ce
Step 4/4 : RUN Rscript test.R
 ---> Running in 1d86a32b5026
[1] "Hello World!"
[1] TRUE
Removing intermediate container 1d86a32b5026
 ---> f9b26d1c54bc
Successfully built f9b26d1c54bc
Successfully tagged rlab:0.1.0

$ docker exec -it rlab bash
root@rlab:/working-dir# ls -l
total 4
-rw-r--r-- 1 root root  0 Aug 12 14:34 hello_world.txt
-rw-r--r-- 1 root root 53 Aug 12 14:23 test.R
~~~

To run your own R-scripts you have to add it on `r-files` path and set up the `Dockerfile`.

### References

[Rocker-Org Github](https://github.com/rocker-org)

[Rocker-Org Docker-Hub](https://hub.docker.com/u/rocker/)

[Principal respository (rocker/verse)](https://github.com/rocker-org/rocker-versioned)

[Principal docker images (rocker/verse)](https://hub.docker.com/r/rocker/verse)

[R Simple Guide](https://www.datanalytics.com/libro_r/arboles-de-decision.html)
