FROM debian:buster
LABEL maintainer="mikkra@xaked.com"
ARG DOCKER_TAG=latest
ARG GOOGLE_CHROME_VERSION=89.0.4389.90

RUN apt-get update\
 && apt-get upgrade -y\
 && apt-get install -y --no-install-recommends\
    python3\
    python3-dev\
    python3-pip\
    python3-setuptools\
    python3-wheel\
    python3-six\
    build-essential\
    libpq5\
    libboost-system1.67.0\
    libboost-thread1.67.0\
    libboost-serialization1.67.0\
    libboost-python1.67.0\
    libboost-regex1.67.0\
    libboost-chrono1.67.0\
    libboost-date-time1.67.0\
    libboost-atomic1.67.0\
    libboost-iostreams1.67.0\
    libfreetype6\
    libpcre3-dev\
    libz-dev\
    cron\
    curl\
    zip\
 && apt-get -o Dpkg::Options::='--force-confmiss' install --reinstall -y netbase\
 && apt-get clean -y\
 && curl -L -o /root/uniprot_sprot_human.dat.gz ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/taxonomic_divisions/uniprot_sprot_human.dat.gz\
 && curl -L -o /tmp/google-chrome-stable_${GOOGLE_CHROME_VERSION}.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${GOOGLE_CHROME_VERSION}-1_amd64.deb

COPY artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Runtime.deb artifacts/debian/$DOCKER_TAG/debs/RDKit-*-Linux-Python.deb /tmp/
COPY --chown=1000:1000 artifacts/debian/${DOCKER_TAG}/mmseqs2/sse/mmseqs /opt/mmseqs/sse/
COPY --chown=1000:1000 artifacts/debian/${DOCKER_TAG}/mmseqs2/avx/mmseqs /opt/mmseqs/avx/
COPY --chown=1000:1000 artifacts/debian/${DOCKER_TAG}/tmalign/tmalign /usr/bin/tmalign

RUN apt install -y --no-install-recommends /tmp/*.deb && rm -f /tmp/*.deb &&\
  cd /usr/bin &&\
  ln -s python3 python &&\
  ln -s pip3 pip &&\
  pip install --upgrade pip &&\
  pip install --upgrade\
  pandas==1.2.4\
  psycopg2-binary==2.8.4\
  flask==1.1.2\
  flask-cors==3.0.8\
  flask-restful==0.3.7\
  flask-jwt-extended==3.24.1\
  Flask-SQLAlchemy==2.4.1\
  flask-mail==0.9.1\
  simplejson==3.17.0\
  scipy==1.4.1\
  passlib==1.7.2\
  requests==2.22.0\
  python-dotenv==0.10.3\
  numpy==1.18.0\
  certifi==2019.11.28\
  werkzeug==0.16.0\
  ipython==7.10.2\
  pytest==5.3.2\
  scikit-learn==0.22.2.post1\
  matplotlib==3.2.0\
  svgutils==0.3.1\
  mmpdb==2.1\
  gunicorn==20.0.4\
  greenlet==0.4.15\
  eventlet==0.25.2\
  psycogreen==1.0.2 \
  pyopenssl==19.1.0 \
  ujson==2.0.3 \
  pycrypto==2.6.1 \
  mdtraj==1.9.4 \
  selenium==3.141.0 \
  cookiestxt==0.4 \
  beautifulsoup4==4.9.0 \
  slackclient==2.9.1 \
  biopython==1.78 \
  flasgger==0.9.5 \
  chromedriver-binary-auto \
  openpyxl==3.0.7 &&\
  chmod +x /opt/mmseqs/sse/mmseqs &&\
  chmod +x /opt/mmseqs/avx/mmseqs &&\
  apt-get purge -y build-essential libpcre3-dev libz-dev &&\
  rm -rf /var/lib/apt/lists/* &&\
  useradd -u 1000 -g 0 -m rdkit

USER 1000
