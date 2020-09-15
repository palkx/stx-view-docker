FROM debian:buster
LABEL maintainer="mikkra@xaked.com"
RUN apt-get update\
 && apt-get upgrade -y\
 && apt-get install -y --no-install-recommends\
    python3\
    python3-dev\
    python3-pip\
    python3-setuptools\
    python3-wheel\
    python3-six\
    libboost-system1.67.0\
    libboost-thread1.67.0\
    libboost-serialization1.67.0\
    libboost-python1.67.0\
    libboost-regex1.67.0\
    libboost-chrono1.67.0\
    libboost-date-time1.67.0\
    libboost-atomic1.67.0\
    libboost-iostreams1.67.0\
 && apt-get -o Dpkg::Options::='--force-confmiss' install --reinstall -y netbase\
 && apt-get clean -y
ARG DOCKER_TAG=latest
COPY artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Runtime.deb artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Python.deb /tmp/
RUN apt install -y --no-install-recommends /tmp/*.deb && rm -f /tmp/*.deb
# symlink python3 to python
RUN cd /usr/bin &&\
  ln -s python3 python &&\
  ln -s pip3 pip &&\
  pip install --upgrade\
  numpy==1.18.0\
  pandas==0.25.3\
  flask==1.1.1\
  flask-cors==3.0.8\
  flask-restful==0.3.7\
  flask-jwt-extended==3.24.1\
  python-dotenv==0.10.3\
  certifi==2019.11.28\
  pytest==5.3.2\
  gunicorn==20.0.4\
  pyopenssl==19.1.0\
  future==0.18.2\
  torch==1.6.0
# add the rdkit user
RUN useradd -u 1000 -g 0 -m rdkit
USER 1000
CMD ["tail", "-f", "/dev/null"]
