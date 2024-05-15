# PinPonFel (deprecated)

***All the infrastructe is down.***

Personal project deployed on GKE.

### Cloud Build & Registry

**Airflow PinPonFel**

Build image

```sh
$ gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/airflow-pinponfel:0.1.0 .
```

**PinPonFel bot**

```sh
$ gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/pinponfel-bot:0.1.0 .
```
