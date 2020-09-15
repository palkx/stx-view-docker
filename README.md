# RDKIT in docker

Dockerized rdkit with some additional deps
---
**core.Dockerfile** - Base image to build rdkit from source

**python3.Dockerfile** - Python with gunicorn to work with rdkit

**python3-with-torch.Dockerfile** - Python with gunicorn and torch to work with rdkit

**cartridge.Dockerfile** - Postgresql DB with rdkit extension

**tt.Dockerfile** - TargetTrack DB ready to import in postgresql [source](https://zenodo.org/record/821654#.Xim95C3Mx25)
