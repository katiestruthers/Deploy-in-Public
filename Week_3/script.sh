#!/bin/bash
yum install nginx -y
echo "<html><body><h1>Hello!</h1><h2>You are viewing this application on the private instance #${instance_num}.</h2></body></html>" > /usr/share/nginx/html/index.html
systemctl start nginx