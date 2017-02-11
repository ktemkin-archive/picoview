#
#  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
#  This will hopefully be replaced with an FOSS license soon.
#
#  Copyright (c) Assured Information Security, inc.
#  Author: Kyle J. Temkin
#

#
# NOTE: This isn't a great testbench-- the tests should be orthogonal,
# and shouldn't be tied with implementation details. It's meant to be quick,
# for now, but is a good candidate for replacement.
#

import inspect

import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestSuccess, TestFailure
from cocotb.handle import ModifiableObject

CLK_HALF = 5

#
# TODO: pull these into a simulation utilities module?
#

def tb_assert(condition, fail_message=None):
    """
        Simple assertion helper for testbenches.
    """
    if fail_message is None:
        _, _, line_number, _, lines, _ = inspect.stack()[1]
        fail_message = "FAILED: {} (line {})".format("".join(lines), line_number)

    if not condition:
        raise TestFailure(fail_message)

def tb_assert_equal(a, b):
    """
        Simple message-generating helper for testbenches that verifies equality.
    """

    _, _, line_number, _, lines, _ = inspect.stack()[1]


    repr_a = a.value.binstr if isinstance(a, ModifiableObject) else repr(a)
    repr_b = a.value.binstr if isinstance(b, ModifiableObject) else repr(b)
    fail_message = "FAILED: ({} != {}) {} (line {})".format(repr_a, repr_b, "".join(lines), line_number)

    tb_assert(a == b, fail_message)



@cocotb.coroutine
def clk_tick(dut, count=1):
    """
        Issues a tick of the system clock.
    """
    for _ in range(count):
        dut.clk = 0
        yield Timer(CLK_HALF)
        dut.clk = 1
        yield Timer(CLK_HALF)


@cocotb.test()
def test_sample_run(dut):
    """
        
    """

    # Set up initial inputs.
    dut.request_run           = 0
    dut.pre_value             = 0
    dut.post_value            = 0xFFFF
    dut.delay_characteristics = 0
    dut.dut_signal_select     = 4
    dut.total_cycles          = 128


    yield clk_tick(dut)
    tb_assert_equal(dut.running, 0)

    dut.request_run = 1
    yield clk_tick(dut)
    tb_assert_equal(dut.running, 1)

    # run the test and generate our VCD
    dut.request_run = 0
    yield clk_tick(dut, 1000)
    tb_assert_equal(int(dut.result), 128)



