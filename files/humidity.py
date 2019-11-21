#!/usr/bin/python3
from sense_hat import SenseHat
sense = SenseHat()

humidity = 0
humidity = round(sense.get_humidity(),3)
print (humidity)
