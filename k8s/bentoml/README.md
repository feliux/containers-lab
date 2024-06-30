# BentoML

BentoML takes a step outward and looks at all the frameworks for modeling, sees the need for presenting a public API for these models, and sees a need for a way to package the models for production. BentoML will take your model, expose a public API, package it in a container suitable for delivery to a variety of targets, and is ideal for Kubernetes.

BentoML supports many of the commonly found ML frameworks: Scikit-learn, PyTorch, Tensorflow, TF Keras, XGBoost, LightGBM, FastText, FastAI, H2O, ONNX, Spacy, Statsmodels, CoreML, Transformers, and Gluon, and is always looking for more.

```sh
# Install Registry
$ helm repo add twuni https://helm.twun.io && helm repo list
$ helm install registry twuni/docker-registry \
    --version 2.1.0 \
    --namespace kube-system \
    --set service.type=NodePort \
    --set service.nodePort=31500
$ export REGISTRY=<RegistryClusterUrl>
```

```sh
# Build bento image
$ docker image build -t summarize:0.1.0 .
$ docker container run --rm summarize:0.1.0 which bentoml
$ docker container run --rm summarize:0.1.0 bentoml --version
$ docker container run --rm summarize:0.1.0 bentoml --help
$ docker container run --rm summarize:0.1.0 bentoml list
$ docker container run --rm --network host -p 3000:3000 summarize:0.1.0

$ curl -X 'POST' \
    'http://localhost:3000/summarize' \
    -H 'accept: text/plain' \
    -H 'Content-Type: application/json' \
    -d '{
    "text": "Breaking News: In an astonishing turn of events, the small town of Willow Creek has been taken by storm as local resident Jerry Thompson'\''s cat, Whiskers, performed what witnesses are calling a '\''miraculous and gravity-defying leap.'\'' Eyewitnesses report that Whiskers, an otherwise unremarkable tabby cat, jumped a record-breaking 20 feet into the air to catch a fly. The event, which took place in Thompson'\''s backyard, is now being investigated by scientists for potential breaches in the laws of physics. Local authorities are considering a town festival to celebrate what is being hailed as '\''The Leap of the Century."
    }'

# Expected output:
# Whiskers, an otherwise unremarkable tabby cat, jumped a record-breaking 20 feet into the air to catch a fly . The event is now being investigated by scientists for potential breaches in the laws of physics . Local authorities considering a town festival to celebrate what is being hailed as 'The Leap of the Century'
```

Deploy to Kubernetes

```sh
$ export SUMMARIZE_MODEL_IMAGE=$REGISTRY/summarize:0.1.0 && echo $SUMMARIZE_MODEL_IMAGE
$ envsubst < deployment.yaml | kubectl apply -f -
$ kubectl apply -f service.yaml
```

## References

[BentoML quickstart](https://github.com/bentoml/quickstart)

[BentoML](https://docs.bentoml.com/en/latest/index.html)

[BentoML github](https://github.com/bentoml/BentoML)

[Containerization](https://docs.bentoml.com/en/latest/guides/containerization.html)
