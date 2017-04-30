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
results = {}

for i in range(16):
    results[i] = []

TOTAL_RUNS = 1024
TIME_PER_PHASE = 23 #picoseconds

while not _has_overflowed():
    __adjust_phase(True)

    for i in range(16):
        raw_result = pv.run_test(TOTAL_RUNS, 0x00000000, 0x0001FFFF, 0x00, i)
        result = raw_result / 1024.0

        results[i].append(result)

    time.append(i * TIME_PER_PHASE)
    i += 1

args = []
labels = []
for i in range(16):
    args.append(results[i])
    args.append('')
    labels.append(str(i))

plt.plot(time, *args)
plt.legend(labels)
plt.ylabel('probability')
plt.xlabel('time')
plt.show()
