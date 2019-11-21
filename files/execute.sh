#!/bin/sh
DIRNAME=$(echo `echo $(dirname "$0")`)
cd $DIRNAME

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "This is the script: execute" >> /tmp/campaign.log

echo "This is the script: execute" >> /tmp/campaign.log
echo "Execution location: $DIRNAME" >> /tmp/campaign.log
echo "Puropose: Install $SERVICENAME service." >> /tmp/campaign.log

## Create the folders for the scripts
DIRECTORY0=/opt/scripts
sudo mkdir $DIRECTORY0
echo "Created directory: $DIRECTORY0" >> /tmp/campaign.log

DIRECTORY1=/opt/scripts/sensehat
sudo mkdir $DIRECTORY1
echo "Created directory: $DIRECTORY1" >> /tmp/campaign.log

## Copy the files to the correct locations
sudo cp humidity.py $DIRECTORY1 && sudo cp pressure.py $DIRECTORY1 && sudo cp temperature.py $DIRECTORY1 && sudo cp sensehat.sh $DIRECTORY1
echo "Copied the script files to: $DIRECTORY1" >> /tmp/campaign.log

## Install the service.
sudo cp $SERVICENAME.service /etc/systemd/system
echo "Copied the service file to: /etc/systemd/system" >> /tmp/campaign.log

## Set rights on folders
sudo chmod 777 -R $DIRECTORY0
echo "Set permissions on directory tree: $DIRECTORY0" >> /tmp/campaign.log

## Start and enable the service
sudo systemctl start $SERVICENAME.service
sudo systemctl enable $SERVICENAME.service
echo "Started and enabled the service: $SERVICENAME.service" >> /tmp/campaign.log