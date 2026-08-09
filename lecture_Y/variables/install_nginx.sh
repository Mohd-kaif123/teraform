#!/bin/bash

sudo dnf update -y
sudo dnf install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1> Hello I am autmating the instance </h1>" | sudo tee /var/www/index.html