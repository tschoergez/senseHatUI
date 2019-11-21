#!/bin/sh
DIRNAME=$(echo `echo $(dirname "$0")`)
cd $DIRNAME

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

LOGFILE="/tmp/campaign-sensehat-service.log"
SERVICENAME=sensehat

echo "This is the script: execute" >> $LOGFILE
echo "Execution location: $DIRNAME" >> $LOGFILE
echo "Puropose: Install $SERVICENAME service." >> $LOGFILE

## Onboad the SenseHAT as a thing device.
TMPLNAME=T-SenseHAT-MT
THINGNAME=T-SenseHAT-MT-01
RPIDEVICEID=$(cat -v /opt/vmware/iotc-agent/data/data/deviceIds.data | awk -F '^' '{print $1}' | awk -F '@' '{print $1}')
sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli enroll-device --template=$TMPLNAME --name=$THINGNAME --parent-id=$RPIDEVICEID
RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "$THINGNAME not successfully onboarded." >> $LOGFILE
    exit 1
else
    echo "$THINGNAME successfully onboarded." >> $LOGFILE
fi

## Get and log the Device ID.
SENSEHATDEVICEID=$(cat -v /opt/vmware/iotc-agent/data/data/deviceIds.data | awk -F '^' '{print $2}' | awk -F '@' '{print $2}')
echo "Device IDc for $THINGNAME is: $SENSEHATDEVICEID" >> $LOGFILE

## Create the folders for the scripts
DIRECTORY0=/opt/scripts
if [ ! -d "$DIRECTORY0" ]; then
    # Control will enter here if DIRECTORY NOT exists.
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
        echo "Directory $DIRECTORY0 does not exists." >> $LOGFILE
        sudo mkdir $DIRECTORY0
        RESULT=$?
        if [ $RESULT -eq 0 ]; then
            echo "Directory $DIRECTORY0 created." >> $LOGFILE 
        else 
        echo "Directory $DIRECTORY0 could not be created." >> $LOGFILE
        fi
    else 
    echo "Directory $DIRECTORY0 exists." >> $LOGFILE 
    fi
fi

DIRECTORY1=/opt/scripts/sensehat
if [ ! -d "$DIRECTORY1" ]; then
    # Control will enter here if DIRECTORY NOT exists.
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
        echo "Directory $DIRECTORY1 does not exists." >> $LOGFILE
        sudo mkdir $DIRECTORY1
        RESULT=$?
        if [ $RESULT -eq 0 ]; then
            echo "Directory $DIRECTORY1 created." >> $LOGFILE 
        else 
        echo "Directory $DIRECTORY1 could not be created." >> $LOGFILE
        fi
    else 
    echo "Directory $DIRECTORY1 exists." >> $LOGFILE 
    fi
fi

## Set rights on folders
sudo chmod 777 $DIRECTORY0
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "Rights on directory $DIRECTORY0 set." >> $LOGFILE
else 
echo "Rights on directory $DIRECTORY0 could not be set." >> $LOGFILE
fi  

sudo chmod 777 $DIRECTORY1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "Rights on directory $DIRECTORY1 set." >> $LOGFILE
else 
echo "Rights on directory $DIRECTORY1 could not be set." >> $LOGFILE
fi  

## Copy the files to the correct locations
sudo cp humidity.py $DIRECTORY1 && sudo cp pressure.py $DIRECTORY1 && sudo cp temperature.py $DIRECTORY1 && sudo cp sensehat.sh $DIRECTORY1

RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "Copied the files to $DIRECTORY1" >> $LOGFILE
else 
    echo "Could not copy the files to $DIRECTORY " >> $LOGFILE
    exit 1
fi

## Install the service.
sudo cp $SERVICENAME.service /etc/systemd/system

RRESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "Copied the $SERVICENAME service file to /etc/systemd/system" >> $LOGFILE
else 
    echo "Could not copy the $SERVICENAME service file to directory /etc/systemd/system" >> $LOGFILE
fi

sudo chmod 777 $DIRECTORY0

## Start and enable the service
sudo systemctl start $SERVICENAME.service
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "Service $SERVICENAME started successfully." >> $LOGFILE
    sleep 2
    sudo systemctl enable $SERVICENAME.service
    if [ $RESULT -eq 0 ]; then
        echo "Service $SERVICENAME enabled successfully." >> $LOGFILE
    else 
        echo "Could not enable $SERVICENAME service." >> $LOGFILE
        exit 1
    fi
    exit 0
else
    echo "Service $SERVICENAME failed to start" >> $LOGFILE
    exit 1
fi