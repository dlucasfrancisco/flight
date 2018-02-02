FROM globaldevtools.bbva.com:5000/base/icuzr/docker-alpine-waveform-runner:latest

ARG PROJECT
ENV BINARY "/usr/local/bin/$PROJECT"

WORKDIR /usr/local/bin
COPY bin/$PROJECT $PROJECT
COPY database/ database
CMD $BINARY