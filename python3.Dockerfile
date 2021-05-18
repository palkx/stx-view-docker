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
  psycopg2-binary==2.8.6\
  flask==1.1.2\
  flask-cors==3.0.10\
  flask-restful==0.3.8\
  flask-jwt-extended==4.2.1\
  Flask-SQLAlchemy==2.5.1\
  flask-mail==0.9.1\
  simplejson==3.17.2\
  scipy==1.6.3\
  passlib==1.7.4\
  requests==2.25.1\
  python-dotenv==0.17.1\
  numpy==1.20.3\
  certifi==2020.12.5\
  werkzeug==0.16.0\
  ipython==7.23.1\
  pytest==6.2.4\
  scikit-learn==0.24.2\
  matplotlib==3.4.2\
  svgutils==0.3.4\
  mmpdb==2.1\
  gunicorn==20.1.0\
  pyopenssl==20.0.1\
  ujson==4.0.2\
  pycrypto==2.6.1\
  mdtraj==1.9.5\
  selenium==3.141.0\
  cookiestxt==0.4\
  beautifulsoup4==4.9.3\
  slackclient==2.9.3\
  biopython==1.78\
  flasgger==0.9.5\
  chromedriver-binary-auto \
  openpyxl==3.0.7 &&\
  chmod +x /opt/mmseqs/sse/mmseqs &&\
  chmod +x /opt/mmseqs/avx/mmseqs &&\
  apt-get purge -y build-essential libpcre3-dev libz-dev &&\
  rm -rf /var/lib/apt/lists/* &&\
  useradd -u 1000 -g 0 -m rdkit

USER 1000
