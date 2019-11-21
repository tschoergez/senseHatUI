#!/bin/bash
#############################################################################
# Filename: sensehat.sh
# Date Created: 03/15/19
# Date Modified: 04/07/19
# Author: Parth Trivedi 
#
# Version 1.3
#
# Description: Script called by the sensehat service to gather information
#              necessary to send to Pulse as Metrics (SenseHat) and Custom
#              properties (uptime).
#
# Usage: Place this script in /opt/scripts/sensehat and make it executable 
#        with chmod.  Gateway and Thing (SenseHat) need to be enrolled on Pulse
#        in order for this to function.  Thing can be enrolled utilizing:
#        ./iotc-agent-cli enroll --device-id=<device Id> --parent-id=<parent Id>
#
# Version history:
# 1.3 - Ken Osborn: Added While Loop instead of Sleep command to avoid having
#                   systemd constantly restarting the service. The service will
#                   still attempt restart if it crashes.
# 1.2 - Ken Osborn: Added Application Checks (SenseHat Service Status) and
#                   Pulse instrumentation.
# 1.1 - Ken Osborn: Re-named script.  Added additional SenseHat and uptime 
#                   capabilities.
# 1.0 - Parth Trivedi: First version of the script.
#############################################################################

while true; do
# Set and Get Python Return variables for Temperature, Humidity and Barometric Pressure
SENSEHATTEMP=$(/usr/bin/python3 /opt/scripts/sensehat/temperature.py)
SENSEHATHUMIDITY=$(/usr/bin/python3 /opt/scripts/sensehat/humidity.py)
SENSEHATPRESSURE=$(/usr/bin/python3 /opt/scripts/sensehat/pressure.py)

# Set uptime variable via bash command in -p 'pretty format' | sed strips out whitespace
# and occurences of ',-' and replaces with '-'
UP=$(uptime -p | sed -e 's/ /-/g' | sed -e 's/,-/,/g')

# Set Gateway and SenseHat Device Variables by retrieving them from /opt/vmware/iotc-agent/data/data/deviceIDs.data 
RPIDEVICEID=$(cat -v /opt/vmware/iotc-agent/data/data/deviceIds.data | awk -F '^' '{print $1}' | awk -F '@' '{print $1}')
SENSEHATDEVICEID=$(cat -v /opt/vmware/iotc-agent/data/data/deviceIds.data | awk -F '^' '{print $2}' | awk -F '@' '{print $2}')

# Utilize iotc-agent-cli to send metrics and properties to Pulse
sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$SENSEHATDEVICEID --name=Temperature --type=double --value=$SENSEHATTEMP
sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$SENSEHATDEVICEID --name=Humidity --type=double --value=$SENSEHATHUMIDITY
sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$SENSEHATDEVICEID --name=BarometricPressure --type=double --value=$SENSEHATPRESSURE
sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-properties --device-id=$RPIDEVICEID --key=uptime --value=$UP
sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-properties --device-id=$SENSEHATDEVICEID --key=Uptime --value=$UP

# Check SenseHat Service Status and update Pulse System Property
SERVICESTATUS=$(systemctl show -p ActiveState --value sensehat.service)
sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-properties --device-id=$RPIDEVICEID --key="app-sensehat-service" --value=$SERVICESTATUS

# Update Pulse Application Monitoring Boolean Metric
if [ $SERVICESTATUS = "active" ]; then
 sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$RPIDEVICEID --name=SenseHatService-Runstate --type=boolean --value="true"
else
 sudo /opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$RPIDEVICEID --name=SenseHatService-Runstate --type=boolean --value="false"
fi

# Configure While Loop Interval
sleep 15
done
