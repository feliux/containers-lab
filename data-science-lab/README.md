# Data Science Lab

Launch an awesome **Data Science** toolstack in Docker.

## Components

- **Jupyter Docker Stack** to make computation with an image based on `jupyter/all-spark-notebook`.

- **PostgreSQL** as database where to save your data.

- **Airflow** to schedule jobs and automate machine learning model generation.

- **Minio** for saving your machine learning models.

- **APIstar** as endpoint to retrieve results.

- **Portainer** for monitoring your docker sockets.

## Deployment

Deploy services running the following command

~~~
$ docker-compose up -d
~~~

## Usage

Services availables on the following port

- Jupyter -> `localhost:8888`

- Airflow -> `localhost:8080`

- Minio -> `localhost:9000`

- Apistar

    - APP documentation -> `localhost:8000/docs/`

    - Endpoint sample -> `localhost:8000/api/?name=man`

- Portainer -> `localhost:9090`

## Troubleshooting

- Airflow

    - Execute webserver and scheduler with different partition logs: follow [link](https://github.com/puckel/docker-airflow/issues/214#issuecomment-492164257) and [link](https://github.com/helm/charts/issues/23589#issuecomment-688708233)

## References

[Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/)

[Apache Airflow](https://airflow.apache.org/docs/stable/)

[Apache Airflow Docker-Hub](https://hub.docker.com/r/apache/airflow)

[Apache Airflow Deployment](https://airflow.readthedocs.io/en/latest/production-deployment.html#)

[Minio](https://docs.min.io/)

[APIstar](https://docs.apistar.com/)

[APIstar Github](https://github.com/encode/apistar)

[APIstar examples](http://pythonic.zoomquiet.top/data/20170422182721/index.html)

[PostgreSQL Docker-Hub](https://hub.docker.com/_/postgres)

[Portainer](https://documentation.portainer.io/)

[Portainer Docker-Hub](https://hub.docker.com/r/portainer/portainer-ce)
