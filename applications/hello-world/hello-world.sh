#!/usr/bin/env bash

echo "********************Initialization started*********************"
# Stop Script on Error
set -e

# For Debugging (print env. variables into a file)  
printenv > /var/log/colony-vars-"$(basename "$BASH_SOURCE" .sh)".txt

# Update packages and Upgrade system
echo "****************************************************************"
echo "Updating System"
echo "****************************************************************"
apt-get update -y


echo "****************************************************************"
echo "Installing python"
echo "****************************************************************"
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.8
sudo apt install -y python3-pip
echo python3 --version

python3 -m pip install -U numpy --user
python3 -m pip install -U setuptools --user
python3 -m pip install -U Flask --user

echo "****************************************************************"
echo "Installing Nginx"
echo "****************************************************************"
sudo apt update -y
sudo apt install -y nginx
sudo service nginx start

cd /etc/nginx/sites-available
cat << EOF > default
server {
    listen        3001;
    server_name   *.com;
    # root /var/www/sample-api;
    location / {
        proxy_pass         http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF

echo 'sites available modified'

sudo nginx -s reload

echo 'reload successful'
echo "****************************************************************"
echo "Installing Nginx compleated"
echo "****************************************************************"


echo "****************************************************************"
echo '==> Extract api artifact to /var/hello-world'
echo "****************************************************************"
echo $ARTIFACTS_PATH

mkdir $ARTIFACTS_PATH/drop
tar -xvf $ARTIFACTS_PATH/hello-world-*.tar.gz -C $ARTIFACTS_PATH/drop/

echo $ARTIFACTS_PATH
echo "*********************artifacts copied to root**********************************"
mkdir /var/hello-world/

# tar -xvf $ARTIFACTS_PATH/drop/sample-api-* -C /var/hello-world

echo "**********************copy(scp) to certain folder**************"

rsync -av $ARTIFACTS_PATH/drop/hello-world-* /var/hello-world/

echo "*********************artifacts copied to root**********************************"

echo 'RELEASE_NUMBER='$RELEASE_NUMBER >> /etc/environment
echo 'API_BUILD_NUMBER='$API_BUILD_NUMBER >> /etc/environment
echo 'API_PORT='$API_PORT >> /etc/environment
source /etc/environment

echo "********************Initialization finished*********************"


echo '******Start api/script**************************'
echo python3 --version
python3 --version

# python3 hello-world.py
python3 /var/hello-world/hello-world-0/src/hello-world.py
echo '******End api/Script ***********************************' 
