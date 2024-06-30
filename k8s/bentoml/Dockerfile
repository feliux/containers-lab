FROM alpine/git:v2.30.2 AS gitter
WORKDIR /app
# RUN git clone https://github.com/bentoml/bentoml
# # The BentoML version 1.0 is around the corner. For stable release version 0.13, see the 0.13-LTS branch
# RUN cd bentoml && git checkout 0.13-LTS
RUN git clone https://github.com/bentoml/quickstart.git
RUN cd quickstart

FROM python:3.8
WORKDIR /app
COPY --from=gitter /app/ /app
# RUN pip install -r ./bentoml/guides/quick-start/requirements.txt
RUN pip install -r ./quickstart/requirements.txt
# RUN python ./bentoml/guides/quick-start/main.py
# RUN bentoml get IrisClassifier:latest
# EXPOSE 5000
EXPOSE 3000
# CMD ["bentoml", "serve", "IrisClassifier:latest"]
CMD ["bentoml", ".", "service:Summarization"]
