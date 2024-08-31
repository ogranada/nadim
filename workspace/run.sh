#!/bin/sh

function current() {
  echo $(git branch | grep "*" | awk '{print $2}')
}

function prepare_project() {
  echo "Preparing project at $(pwd)"
  npm install
  BUILD=$(npm run | grep build)
  if [ -z "$BUILD" ]; then
    echo "  - Nothing to build..."
  else
    npm run build
  fi
  echo "Project ready..."
}

function run_project() {
  cd app
  if [ -z "$MAINFILE" ]; then
    START=$(npm run | grep build)
    if [ -z "$START" ]; then
      echo "No main file or start script found"
      exit 1;
    else
      npm start
    fi
  else
    if [ "$LAUNCHER" = "pm2" ]; then
        pm2 start "./$MAINFILE"
    else
      if [ "$LAUNCHER" = "nodemon" ]; then
        nodemon "./$MAINFILE"
      else
        node "./$MAINFILE"
      fi
    fi
  fi
  cd ..
}

function main() {
  git --version
  echo "NADIM - Node App Docker IMage"
  echo "RUNNING AS: $(whoami)"
  echo "CURRENT FOLDER: $(pwd)"

  if [ -z "$REPO" ]; then
    echo "Repo not found..."
  else
    echo "Preparing Repo $REPO..."
    if [ -d "app" ]; then
      cd app
      prepare_project
      cd ..
    else
      git clone $REPO app
      cd app
      prepare_project
      cd ..
    fi
    echo "Preparing execution..."
    run_project
  fi
}

function prepare_ssh_keys() {
  if [ -z "$SSH_KEY" ]; then
    echo "No ssh key found..."
  else
    mkdir ~/.ssh || true
    echo $SSH_KEY > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/*
  fi
}

function run_restarter() {
  npm install -g pm2
  cd restarter
  rm -Rf .env 2> /dev/null || true
  echo "MONITOR_PORT=$1" >> .env
  echo "TOKENS=$2" >> .env
  npm i
  npm run start &
  cd ..
}

prepare_ssh_keys
run_restarter "$MONITOR_PORT" "$TOKENS"
main
