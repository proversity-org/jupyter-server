#!/bin/bash

# Set openresty version
VERSION='1.9.15.1'

# Check if openresty is installed.

if [ -d /usr/local/openresty/ ]
then
  exit
fi

# Remove Amazon Linux Nginx
yum remove nginx -y

rm -rf /etc/nginx/

# Download and install openresty
wget https://openresty.org/download/openresty-$VERSION.tar.gz
tar xvf openresty-$VERSION.tar.gz
cd openresty-$VERSION
./configure --with-luajit && make && make install

# Create statup configuration
touch /etc/init.d/nginx
cat /var/app/current/.ebextensions/.nginx/startup > /etc/init.d/nginx
chmod 755 /etc/init.d/nginx

# Create symlink to make EB happy
ln -s '/usr/local/openresty/nginx/conf/' '/etc/nginx'

/etc/init.d/nginx restart

# Run on startup
/sbin/chkconfig nginx on
