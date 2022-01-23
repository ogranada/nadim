# NADIM
NADIM (Node App Docker Image) is an image to run node apps, you can use PM2, nodemon or simply node.

## How to build the image
```bash
docker build . --tag nadim:1.0.0
```

# How to use the image

```bash
export INTERNAL_PORT=5000
export LOCAL_PORT=5050
export REPO=https://github.com/ogranada-mentoring/dummy-be
export MAINFILE=src/server.js

# Using the `start` script
docker run -d --name sample -p $LOCAL_PORT:$INTERNAL_PORT -e REPO=$REPO nadim:1.0.0

# Using node and running the specified file
docker run -d --name sample \
    -p $LOCAL_PORT:$INTERNAL_PORT \
    -e REPO=$REPO -e MAINFILE=$MAINFILE nadim:1.0.0

# Using nodemon and running the specified file
docker run -d --name sample \
    -p $LOCAL_PORT:$INTERNAL_PORT \
    -e REPO=$REPO -e MAINFILE=$MAINFILE -e LAUNCHER="nodemon" nadim:1.0.0

# See the logs
docker container logs -f sample
```

