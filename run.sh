#!/bin/bash

command -v docker > /dev/null && RUNNER=docker || RUNNER=podman

function confirm() {
  read -p "$@ " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    return 1
  else
    return 0
  fi
}

function filter() {
  echo "--- $1"
}

function main() {
  APP=$1
  CMD=$2
  IMAGE_NAME='nadim'
  CONTAINER_NAME='nadim_local'
  DH_USERNAME='ogranada'
  case $CMD in
    usage)
        echo ""
        echo "$APP <COMMAND>"
        echo ""
        printf "\e[0;32mCommands:\033[0m\n\n"
        printf "  \e[0;36m build  \033[0m      Build the image\n"
        printf "  \e[0;36m create \033[0m      Create an image instance\n"
        printf "  \e[0;36m remove \033[0m      Remove an image instance\n"
        printf "  \e[0;36m logs   \033[0m      Write image logs\n"
        printf "  \e[0;36m usage  \033[0m      Show this help\n"
        echo ""
        echo ""
        ;;
    push)
        echo "Pushing image to docker registry"
        ${RUNNER} image push $DH_USERNAME/$IMAGE_NAME
        ;;
    build)
        read -e -p "VERSION: " VERSION
        history -s "$VERSION"
        ${RUNNER} build . --tag $DH_USERNAME/$IMAGE_NAME:$VERSION
        ${RUNNER} build . --tag $DH_USERNAME/$IMAGE_NAME:latest
        ${RUNNER} build . --tag $IMAGE_NAME:$VERSION
        ${RUNNER} build . --tag $IMAGE_NAME:latest
        ;;
    create)
        read -e -p "REPO URL: " REPO
        history -s "$REPO"
        read -e -p "APP PORT: " INTERNAL_PORT
        history -s "$INTERNAL_PORT"
        read -e -p "LOCAL PORT: " LOCAL_PORT
        history -s "$LOCAL_PORT"
        confirm "Do you want to use start script?"
        if [ "$?" = "1" ]; then
          ${RUNNER} run -d --name $CONTAINER_NAME -p $LOCAL_PORT:$INTERNAL_PORT -e REPO=$REPO $IMAGE_NAME:latest
        else
          read -e -p "Node launcher (node, pm2, nodemon): " LAUNCHER
          history -s "$LAUNCHER"
          read -e -p "Main file path (path/to/index.js): " MAINFILE
          history -s "$MAINFILE"
          ${RUNNER} run -d --name $CONTAINER_NAME \
              -p $LOCAL_PORT:$INTERNAL_PORT \
              -e REPO=$REPO -e MAINFILE=$MAINFILE -e LAUNCHER=$LAUNCHER $IMAGE_NAME:latest
        fi
        ;;
    remove)
        ${RUNNER} container rm -f $CONTAINER_NAME
        ;;
    logs)
        ${RUNNER} container logs -f $CONTAINER_NAME
        ;;
    ls)
        echo "$(command $RUNNER image ls | grep $IMAGE_NAME | grep latest)"
        ;;
    *)
        echo "Invalid command $CMD"
      ;;
  esac
}

function finish {
  history -w .script_history
}

trap finish EXIT
history -r .script_history
set -o vi
main "$0" "$1";
