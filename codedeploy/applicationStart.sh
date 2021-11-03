#!/bin/bash
# sudo cd /home/ubuntu/csye6225/dev/webapp/
# sudo npm i
# sudo npm run start &

sudo unzip ../webapp.zip

sudo mkdir /home/ubuntu/csye_webapp

sudo mv -rf ../webapp /home/ubuntu/csye_webapp

cd /home/ubuntu/csye_webapp/webapp

npm start
