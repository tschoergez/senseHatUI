#!/usr/bin/python3
from sense_hat import SenseHat
sense = SenseHat()

pressure = 0
pressure = round(sense.get_pressure(),3)
print (pressure)
