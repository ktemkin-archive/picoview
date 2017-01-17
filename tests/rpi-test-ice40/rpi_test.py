#!/usr/bin/env python
#
# Test stimulator for the rpi_test.v; to be run from the relevant RPi.
#

import sys
import spi
import RPi.GPIO as GPIO

GPIO_PIN = 35

def spi_transaction(data):
    """
        Performs a simple SPI transaction with CS held low for its duration.
    """

    GPIO.output(GPIO_PIN, GPIO.LOW)
    result = spi.transfer(data)
    GPIO.output(GPIO_PIN, GPIO.HIGH)

    print("tx: {} => rx: {}".format(data, result))
    return result

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)

# Start off with CS high.
GPIO.setup(GPIO_PIN, GPIO.OUT)
GPIO.output(GPIO_PIN, GPIO.HIGH)

# Start at a gentle 100kHz
spi.openSPI(speed=100000)

# Write a series of numbers to R0.
packet = (1, 1, 2, 3, 4)
spi_transaction(packet)

packet = (0, 0, 0, 0, 0)
spi_transaction(packet)

packet = (2, 0, 0, 0, 0)
spi_transaction(packet)

packet = (3, 0, 0, 0, 0)
spi_transaction(packet)
