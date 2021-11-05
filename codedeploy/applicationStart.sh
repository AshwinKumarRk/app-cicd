#!/bin/sh
cd /home/ubuntu/webapp/
unzip *.zip
npm i
sudo npm i nodemon -g
sudo npm install pm2 -g
# sudo pm2 delete all
sudo pm2 start npm -- start
# nohup npm start &
