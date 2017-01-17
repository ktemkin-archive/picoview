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


@cocotb.coroutine
def sck_tick(dut):
    """
        Issues a tick of the SPI clock, and moves forward enough cycles
        that its result will be accepted.
    """
    dut.sck = 0
    yield clk_tick(dut)
    dut.sck = 1
    yield clk_tick(dut)


@cocotb.test()
def test_tx_and_rx(dut):
    """
        Evaluates the SPI transmitter's ability to transmit and receive..
    """
    #TODO: rewrite this to test only externally-facing characterstics

    dut.clk = 0
    dut.cs  = 0;

    # Set up the command to be passed to the DUT.
    command = 234
    command_bits = bin(command)[2:]

    # Set up the word to be transmitte to the DUT,
    # and the word the DUT will send.
    expected_output = 0xDEADBEEF
    expected_output_bits = bin(expected_output)[2:]
    dut.word_to_output = expected_output

    word_to_receive = 0xABADCAFE
    word_to_recieve_bits = bin(word_to_receive)[2:]

    tb_assert_equal(dut.state, dut.STATE_RESET)

    # After reset, we should be dumped immpediately into STALL...
    yield clk_tick(dut)
    tb_assert_equal(dut.state, dut.STATE_STALL)

    # ... and should remain there until CS goes high.
    yield clk_tick(dut)
    tb_assert_equal(dut.state, dut.STATE_STALL)

    # We should then remain in STATE_WAIT until CS goes low.
    dut.cs = 1
    yield clk_tick(dut)
    tb_assert_equal(dut.state, dut.STATE_WAIT)
    yield clk_tick(dut)
    tb_assert_equal(dut.state, dut.STATE_WAIT)

    # We should then move to READ and read in the command.
    dut.cs = 0
    yield clk_tick(dut)
    tb_assert_equal(dut.state, dut.STATE_CMD)

    # We should stay in READ no matter what unless we get SPI clk activity.
    for _ in range(100):
        yield clk_tick(dut)
        tb_assert_equal(dut.state, dut.STATE_CMD)
        tb_assert_equal(int(dut.bit_count), 0)

    # Read in the command word.
    for i in range(8):

        # Give the system some time to process.
        yield clk_tick(dut, 10)

        tb_assert_equal(dut.state, dut.STATE_CMD)
        tb_assert_equal(int(dut.bit_count), i)

        dut.sdi = int(command_bits[i])
        yield sck_tick(dut)

    # Once we've received the full command, we should be notified
    # that the command is ready within the next hundred cycles.
    for _ in range(100):
        if dut.command_ready == 1:
            break

        yield clk_tick(dut)
    else:
        raise TestFailure("command_ready was never asserted!")

    # Check that we get the right command.
    tb_assert_equal(int(dut.command), command)

    # Several ticks later, we should wind up ready to transmit/rx.
    yield clk_tick(dut)
    tb_assert_equal(dut.state, dut.STATE_DATA)

    # Perform the actual transmit and receive.
    for i in range(32):

        # Give the system some time to process.
        yield clk_tick(dut, 10)

        # Ensure that we correctly move through the data state.
        tb_assert_equal(dut.state, dut.STATE_DATA)
        tb_assert_equal(int(dut.bit_count), i + 8)

        # Ensure that the DUT is transmitting the right bit...
        tb_assert_equal(dut.sdo, int(expected_output_bits[i]))

        #... and provide it with a bit to receive.
        dut.sdi = int(word_to_recieve_bits[i])
        yield sck_tick(dut)

    # Wait for processing of the word to be complete.
    for _ in range(100):
        if dut.word_rx_complete == 1:
            break

        yield clk_tick(dut)
    else:
        raise TestFailure("device never signaled rx completion!")

    # Once we have a complete word, check that we recieved the correct data.
    tb_assert_equal(int(dut.word_received), word_to_receive)

    # Wait a while, and make sure we wind up in the STALL state.
    yield clk_tick(dut, 100)
    tb_assert_equal(dut.state, dut.STATE_STALL)

