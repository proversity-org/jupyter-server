#!/bin/bash

# Set openresty version
VERSION='1.9.15.1'

# Update sources list
yum update

# Install packages for compiling openresty
yum install -y pcre-devel zlib-devel openssl-devel gcc make

# Backup previous nginx rolledout with Amazon Linux and remove 
mkdir /etc/nginx-backup && cp -r /etc/nginx/ /etc/nginx/nginx-backup
yum remove nginx -y

# Download and install openresty
wget https://openresty.org/download/openresty-$VERSION.tar.gz
tar xvf openresty-$VERSION.tar.gz
cd openresty-$VERSION
./configure --with-luajit && make && make install

# Create statup configuration
touch /etc/init.d/nginx
cat /var/app/current/.ebextensions/.nginx/startup > /etc/init.d/nginx
chmod 755 /etc/init.d/nginx

/etc/init.d/nginx restart

# Run on startup
/sbin/chkconfig nginx on


