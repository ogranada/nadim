#!/bin/sh

function current() {
  echo $(git branch | grep "*" | awk '{print $2}')
}

git --version
echo "NAIM - Node App IMage"
echo "RUNNING AS: $(whoami)"
echo "CURRENT FOLDER: $(pwd)"

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
