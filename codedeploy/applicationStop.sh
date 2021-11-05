#!/bin/bash
cd /home/ubuntu/webapp/
sudo pm2 delete all || true
sudo killall node