FROM python:3.7-slim-buster
LABEL maintainer="mikkra@xaked.com"
RUN apt-get update\
  && apt-get install -y curl\
  && apt-get clean autoclean\
  && apt-get autoremove --yes\
  && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade\
  flask-jwt-extended==3.24.1\
  Flask-SQLAlchemy==2.4.1\
  psycopg2-binary==2.8.4\
  flask-restful==0.3.7\
  certifi==2019.11.28\
  psycogreen==1.0.2\
  flask-cors==3.0.8\
  pyopenssl==19.1.0\
  werkzeug==0.16.0\
  gunicorn==20.0.4\
  flask==1.1.1\
  PyJWT==1.7.1

# add the rdkit user
RUN useradd -u 1000 -g 0 -m executor
USER 1000
