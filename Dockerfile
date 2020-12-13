FROM article714/debian-based-container:latest
LABEL maintainer="C. Guychard <Article714>"

ARG ETCD_VERSION

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Container tooling

COPY container /container

# container building

RUN /container/build.sh

