#!/bin/bash
cd /home/ubuntu/webapp
unzip *.zip
# sudo cp .env ./webapp
# sudo cd webapp
npm i
npm i nodemon -g
npm start
