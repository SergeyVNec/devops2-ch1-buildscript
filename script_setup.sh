#!/bin/bash

# Project URL
REPO_URL="https://github.com/DevOps2-Fundamentals/example-app-nodejs-backend-react-frontend"
PROJECT_DIR="example-app-nodejs-backend-react-frontend"

# Remove previous project folder if exists
rm -rf /var/www/html/"$PROJECT_DIR"

# Clone the repo
cd /var/www/html
git clone "$REPO_URL"
cp -rpf /var/www/html/"$PROJECT_DIR"/* /var/www/html/

# --------- npm install timing ----------
echo "==== NPM INSTALL ===="
START_NPM=$(date +%s)
npm install
END_NPM=$(date +%s)
NPM_DURATION=$((END_NPM - START_NPM))
echo "npm install completed in $NPM_DURATION seconds"
echo

# Remove node_modules to clean before yarn

rm -rf node_modules package-lock.json

# --------- yarn install timing ---------
echo "==== YARN INSTALL ===="
if ! command -v yarn >/dev/null 2>&1; then
    echo "Yarn not found, installing globally..."
    npm install -g yarn
fi
START_YARN=$(date +%s)
yarn install
END_YARN=$(date +%s)
YARN_DURATION=$((END_YARN - START_YARN))
echo "yarn install completed in $YARN_DURATION seconds"
echo

# Show summary
echo "==================================="
echo "Setup time:"
echo "npm  install: $NPM_DURATION seconds"
echo "yarn install: $YARN_DURATION seconds"
echo "==================================="

# Client file
TARGET_FILE="src/client/components/ExampleComponent.js"

# Full Name
NAME="Serhii Nechytailo"

# Port
PORT="${PORT:-3000}"

# Get IP Address
HOST=$(hostname -I | awk '{print $1}')

# OS info
OSINFO=$(hostnamectl | sed ':a;N;$!ba;s/\n/<br \/>/g')

# Change content between<h1>...</h1> and info
sed -i "s|return <h1>.*</h1>;|return (\
  <div style={{ textAlign: \"center\" }}>\
    <h1>$NAME</h1>\
    <p style={{ color: \"red\" }}>NPM install: $NPM_DURATION seconds</p>\
    <p style={{ color: \"red\" }}>YARN install: $YARN_DURATION seconds</p>\
    <p>Project is running on host: $HOST, port: $PORT</p>\
    <p>$OSINFO</p>\
  </div>\
);|" "$TARGET_FILE"

# Add listen address for all address
APP_FILE="src/server/app.js"

# Insert line -hostname-
sed -i "/const PORT = 3000;/i const hostname = '0.0.0.0';" "$APP_FILE"

# Insert hostname in app.listen
sed -i "s/app\.listen(\s*PORT\s*,/app.listen(PORT, hostname,/" "$APP_FILE"

echo "File $APP_FILE was successfuly changed"

yarn build
npm start
