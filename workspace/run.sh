#!/bin/sh

function current() {
  echo $(git branch | grep "*" | awk '{print $2}')
}

git --version
echo "NAIM - Node App IMage"
echo "RUNNING AS: $(whoami)"
echo "CURRENT FOLDER: $(pwd)"

if [ -z "$REPO" ]; then
  echo "Repo not found..."
else
  echo "Preparing Repo $REPO..."
  if [ -d "app" ]; then
    cd app
    git pull origin $(current)
    BUILD=$(npm run | grep build)
    if [ -z "$BUILD" ]; then
      npm run build
    fi
    cd ..
  else
    git clone $REPO app
  fi
  cd app
  npm install
  if [ -z "$MAINFILE" ]; then
    npm start
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
fi
