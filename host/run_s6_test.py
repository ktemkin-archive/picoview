#!/usr/bin/env python3

import time
import matplotlib.pyplot as plt

from picoview import PicoViewDevice
from greatfet_connection import GreatfetConnection


gf = GreatfetConnection()
pv = PicoViewDevice(gf)


def __adjust_phase(increment=True):
    value = 0x01 if increment else 0x00
    pv._write_register(pv.REG_TIMING_CONTROL, value)
    pv._write_register(pv.REG_CONTROL, 1 << 2)

def _has_overflowed():
    status = pv._read_register(pv.REG_STATUS)
    return not bool(status & (1 << 3))

i = 0
time = []
results = []

TOTAL_RUNS = 1024

while not _has_overflowed():
    __adjust_phase(True)

    raw_result = pv.run_test(TOTAL_RUNS, 0x00000000, 0x0008FFFF, 0x00, 2)
    result = raw_result / 1024.0

    results.append(result)
    time.append(i * 23)
    i += 1

plt.plot(time, results)
plt.ylabel('probability')
plt.xlabel('time')
plt.show()
