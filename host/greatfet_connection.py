#
#  PicoView connection based on a GreatFET
#
#  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
#  This will hopefully be replaced with an FOSS license soon.
#
#  Copyright (c) Assured Information Security, inc.
#  Author: K. Temkin
#

class GreatfetConnection(object):
    """
    Represents a PicoView connection via a GreatFET object.
    """

    def __init__(self):
        """
        Sets up as new connection to a PicoView instance using a GreatFET bridge.
        """
        from greatfet import GreatFET
        self.greatfet = GreatFET()


    def transfer(self, data, receive_length=None):
        """
        Defer all SPI communications to the GreatFET.
        """
        return self.greatfet.spi.transmit(data, receive_length)
