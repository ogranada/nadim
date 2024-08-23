#!/bin/bash

command -v docker > /dev/null && RUNNER=docker || RUNNER=PODMAN

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

function main() {
  APP=$1
  CMD=$2
  CONTAINER_NAME='naim_local'
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
        ${RUNNER} image push --all-tags $DH_USERNAME/nadim
        ;;
    build)
        read -e -p "VERSION: " VERSION
        history -s "$VERSION"
        ${RUNNER} build . --tag $DH_USERNAME/nadim:$VERSION
        ${RUNNER} build . --tag $DH_USERNAME/nadim:latest
        ${RUNNER} build . --tag nadim:$VERSION
        ${RUNNER} build . --tag nadim:latest
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
          ${RUNNER} run -d --name $CONTAINER_NAME -p $LOCAL_PORT:$INTERNAL_PORT -e REPO=$REPO nadim:latest
        else
          read -e -p "Node launcher (node, pm2, nodemon): " LAUNCHER
          history -s "$LAUNCHER"
          read -e -p "Main file path (path/to/index.js): " MAINFILE
          history -s "$MAINFILE"
          ${RUNNER} run -d --name $CONTAINER_NAME \
              -p $LOCAL_PORT:$INTERNAL_PORT \
              -e REPO=$REPO -e MAINFILE=$MAINFILE -e LAUNCHER=$LAUNCHER nadim:latest
        fi
        ;;
    remove)
        ${RUNNER} container rm -f $CONTAINER_NAME
        ;;
    logs)
        ${RUNNER} container logs -f $CONTAINER_NAME
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
