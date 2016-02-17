from Indicators.Indicator import *
from Indicators.SMA import *

class EMA(Indicator):

    def __init__(self, length, array):
        self.length = length
        self.source = array
        self.EMAdata = np.array([float(0) for i in range(len(self.source))], float)
        self.EMAdata[self.length] = SMA(self.length, self.source).get()[self.length]

    def get(self):
        multiplier = 2 / (self.length + 1)
        for i in range(1, len(self.EMAdata) - self.length):
            self.EMAdata[self.length+i] = (self.source[self.length+i] - self.EMAdata[self.length+i-1]) * multiplier + self.EMAdata[self.length+i-1]
        return np.array(self.EMAdata, float)