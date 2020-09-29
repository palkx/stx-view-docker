#!/bin/bash
set -xe;
IMAGES_DIR=.;
source params.sh;
env;
docker login --username="${DOCKER_USER}" --password="${DOCKER_PASSWORD}";

if [ "$(git diff --name-only HEAD..HEAD^1 | grep -E "^(core\.Dockerfile|build\.sh|params\.sh)$")" != "" ]; then
  # build RDKit
  echo 'Rebuilding core image...';
  docker pull "$BASE"/oss-stx-rdkit-core:latest;
  docker build -f $IMAGES_DIR/core.Dockerfile\
   -t "$BASE"/oss-stx-rdkit-core:"$DOCKER_TAG"\
   -t "$BASE"/oss-stx-rdkit-core:latest\
   --build-arg GIT_REPO="$GIT_REPO"\
   --build-arg GIT_BRANCH="$GIT_BRANCH"\
   --build-arg GIT_TAG="$GIT_TAG" .;
  echo "Built image $BASE/core:$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-core:"$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-core:latest;
fi

docker pull "$BASE"/oss-stx-rdkit-core:latest;
rm -rf artifacts/debian/"$DOCKER_TAG";
mkdir -p artifacts/debian/"$DOCKER_TAG";
mkdir -p artifacts/debian/"$DOCKER_TAG"/debs;
mkdir -p artifacts/debian/"$DOCKER_TAG"/mmseqs2;
mkdir -p artifacts/debian/"$DOCKER_TAG"/tmalign;
docker run -it --rm -u "$(id -u)"\
 -v "$PWD"/artifacts/debian/"$DOCKER_TAG":/tohere:Z\
 "$BASE"/oss-stx-rdkit-core:"$DOCKER_TAG" bash -c 'cp build/*.deb /tohere/debs && cp tmalign /tohere/tmalign/ && mkdir -p /tohere/mmseqs2/sse && mkdir /tohere/mmseqs2/avx && cp /mmseqs2/build_sse/bin/mmseqs /tohere/mmseqs2/sse/mmseqs && cp /mmseqs2/build_avx/bin/mmseqs /tohere/mmseqs2/avx/mmseqs';

if [ "$(git diff --name-only HEAD..HEAD^1 | grep -E "^(python3\.Dockerfile|build\.sh|params\.sh)$")" != "" ]; then
  # build image for python3 on debian
  docker pull "$BASE"/oss-stx-rdkit-python3:latest;
  docker build -f $IMAGES_DIR/python3.Dockerfile\
   -t "$BASE"/oss-stx-rdkit-python3:"$DOCKER_TAG"\
   -t "$BASE"/oss-stx-rdkit-python3:latest\
   --build-arg DOCKER_TAG="$DOCKER_TAG" .;
  echo "Built image $BASE/oss-stx-rdkit-python3:$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-python3:"$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-python3:latest;
fi

if [ "$(git diff --name-only HEAD..HEAD^1 | grep -E "^(python3-with-torch\.Dockerfile|build\.sh|params\.sh)$")" != "" ]; then
  # build image for python3 with torch on debian
  docker pull "$BASE"/oss-stx-rdkit-python3-torch:latest;
  docker build -f $IMAGES_DIR/python3-with-torch.Dockerfile\
   -t "$BASE"/oss-stx-rdkit-python3-torch:"$DOCKER_TAG"\
   -t "$BASE"/oss-stx-rdkit-python3-torch:latest\
   --build-arg DOCKER_TAG="$DOCKER_TAG" .;
  echo "Built image $BASE/oss-stx-rdkit-python3-torch:$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-python3-torch:"$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-python3-torch:latest;
fi

if [ "$(git diff --name-only HEAD..HEAD^1 | grep -E "^(cartridge\.Dockerfile|build\.sh|params\.sh)$")" != "" ]; then
  # build image for postgresql cartridge on debian
  docker pull "$BASE"/oss-stx-rdkit-cartridge:latest;
  docker build -f $IMAGES_DIR/cartridge.Dockerfile\
   -t "$BASE"/oss-stx-rdkit-cartridge:"$DOCKER_TAG"\
   -t "$BASE"/oss-stx-rdkit-cartridge:latest\
   --build-arg DOCKER_TAG="$DOCKER_TAG" .;
  echo "Built image $BASE/oss-stx-rdkit-cartridge:$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-cartridge:"$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-cartridge:latest;
fi

if [ "$(git diff --name-only HEAD..HEAD^1 | grep -E "^(tt\.Dockerfile|build\.sh|params\.sh|targettrackparser)$")" != "" ]; then
  # Create storage container with Target Track database
  docker pull "$BASE"/oss-stx-tt-storage:latest;
  docker build -f $IMAGES_DIR/tt.Dockerfile\
   -t "$BASE"/oss-stx-tt-storage:"$DOCKER_TAG"\
   -t "$BASE"/oss-stx-tt-storage:latest\
   --build-arg GOOGLE_API_KEY="$GOOGLE_API_KEY"\
   --build-arg DOCKER_TAG="$DOCKER_TAG" "$(pwd)"/targettrackparser/;
  echo "Built image $BASE/oss-stx-tt-storage:$DOCKER_TAG";
  docker push "$BASE"/oss-stx-tt-storage:"$DOCKER_TAG";
  docker push "$BASE"/oss-stx-tt-storage:latest;
fi

if [ "$(git diff --name-only HEAD..HEAD^1 | grep -E "^(null\.Dockerfile|build\.sh|params\.sh)$")" != "" ]; then
  # empty image
  docker pull "$BASE"/oss-stx-rdkit-python3:latest;
  docker build -f $IMAGES_DIR/python3.Dockerfile\
   -t "$BASE"/oss-stx-rdkit-python3:"$DOCKER_TAG"\
   -t "$BASE"/oss-stx-rdkit-python3:latest\
   --build-arg DOCKER_TAG="$DOCKER_TAG" .;
  echo "Built image $BASE/oss-stx-rdkit-python3:$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-python3:"$DOCKER_TAG";
  docker push "$BASE"/oss-stx-rdkit-python3:latest;
fi
