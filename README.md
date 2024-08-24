# NADIM
NADIM (Node App Docker Image) is an image to run node apps, you can use PM2, nodemon or simply node.

## How to build the image
```bash
docker build . --tag nadim:latest
```

# How to use the image
You can use the command line
```bash
./run.sh usage
```

Or use raw docker:
```bash
export INTERNAL_PORT=5000
export LOCAL_PORT=5050
export REPO=https://github.com/ogranada-mentoring/dummy-be
export MAINFILE=src/server.js

# Using the `start` script
docker run -d --name sample -p $LOCAL_PORT:$INTERNAL_PORT -e REPO=$REPO nadim:latest

# Using node and running the specified file
docker run -d --name sample \
    -p $LOCAL_PORT:$INTERNAL_PORT \
    -e REPO=$REPO -e MAINFILE=$MAINFILE nadim:latest

# Using nodemon and running the specified file
docker run -d --name sample \
    -p $LOCAL_PORT:$INTERNAL_PORT \
    -e REPO=$REPO -e MAINFILE=$MAINFILE -e LAUNCHER="nodemon" nadim:latest

# See the logs
docker container logs -f sample
```

# Using dorcker compose or an equivalent tool
```yml
services:
    app:
        container_name: app
        image: ogranada/nadim
        restart: always
        stdin_open: true
        tty: true
        environment:
            REPO: "https://github.com/ogranada-mentoring/dummy-be"
            MAINFILE: "src/server.js"
            PORT: "5051"
        ports:
            - "6060:5051" ## local:remote

```
