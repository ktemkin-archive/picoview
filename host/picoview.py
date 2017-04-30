#
#  PicoView connection based on a GreatFET
#
#  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
#  This will hopefully be replaced with an FOSS license soon.
#
#  Copyright (c) Assured Information Security, inc.
#  Author: K. Temkin
#

class PicoViewDevice(object):
    """
    Represents a PicoView connection via a GreatFET object.
    """

    EXPECTED_DEVICE_ID = 0xc001cafe

    REG_CONTROL           = 0
    REG_STATUS            = 0
    REG_RESULT            = 1
    REG_SIGNAL_INDEX      = 2
    REG_TIMING_CONTROL    = 3
    REG_ITER_COUNT        = 4
    REG_PRE_INPUT         = 5
    REG_POST_INPUT        = 6
    REG_ID                = 0b1111111

    CONTROL_BIT_RUN       = 0
    STATUS_BIT_RUNNING    = 1
    STATUS_BIT_LOCKED     = 3
    CONTROL_BIT_RESET_CLK = 4

    def __init__(self, connection):
        """
        Sets up as new connection to a PicoView instance using a GreatFET bridge.
        """

        # Store our communications connection.
        self.comms = connection
        self._verify_id()

        self.reset_clocking()


    def run_test(self, iterations, pre_input, post_input, timing_control, signal_index):
        self._write_register(self.REG_SIGNAL_INDEX, signal_index)
        self._write_register(self.REG_PRE_INPUT, pre_input)
        self._write_register(self.REG_POST_INPUT, post_input)
        self._write_register(self.REG_TIMING_CONTROL, timing_control)
        self._write_register(self.REG_ITER_COUNT, iterations)
        self._start_test()
        self._wait_for_test_completion()

        return self._read_register(self.REG_RESULT)


    def reset_clocking(self):
        """
        Resets the PicoView instance's internal clocking.
        """
        self._write_register(self.REG_CONTROL, 1 << self.CONTROL_BIT_RESET_CLK)
        self._write_register(self.REG_CONTROL, 0)

        # Wait for the device's PLL to lock.
        while not self._pll_locked():
            pass


    def _pll_locked(self):
        """
        Returns true IFF the system's PLL is locked.
        """
        status = self._read_register(self.REG_STATUS)
        return bool(status & (1 << self.STATUS_BIT_LOCKED))



    def _verify_id(self):
        """
        Verifies the connection to the PicoView device by reading its ID register.
        Raises an exception on failure.
        """

        id = self._read_register(self.REG_ID)

        if id != self.EXPECTED_DEVICE_ID:
            raise IOError("Invalid device ID ({})! Check your connections?".format(hex(id)))


    def _start_test(self):
        """
        Instantiates a single test cycle.
        """
        self._write_register(self.REG_CONTROL, 1 << self.CONTROL_BIT_RUN)


    def _wait_for_test_completion(self):
        """
        Blocks execution until the current test is complete.
        """
        while self._test_running():
            pass


    def _test_running(self):
        """
        Returns true IFF a given test is running.
        """
        status = self._read_register(self.REG_STATUS)
        return bool(status & (1 << self.STATUS_BIT_RUNNING))


    def _read_register(self, number):
        """
        Reads a PicoView register, and returns its value as an integer.
        """

        # Read five bytes: the meaningless response as we shift out the register number,
        # and the 32-bit response word.
        result = self.comms.transfer([number], receive_length = 5)

        # Extract the register value from the response.
        return int.from_bytes(result[1:], 'big')


    def _write_register(self, number, value):
        """
        Writes a value to a PicoView register.
        """

        # Generate our write command string...
        command = int.to_bytes(number | 128, 1, 'big')
        data = int.to_bytes(value, 4, 'big')

        # ... and write the register.
        self.comms.transfer(bytearray(command + data))




