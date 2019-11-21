#!/usr/bin/python3
from sense_hat import SenseHat
sense = SenseHat()
sensetemp = 0
sensetemp = round(sense.get_temperature(),3) -20
print (sensetemp)
