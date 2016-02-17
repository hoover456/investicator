from Indicators.Indicator import *

class SMA(Indicator):

    def __init__(self, length, array):
        self.length = length
        self.source = array

    def get(self):
        self.sma = [0 for i in range(len(self.source))]
        for n in range(self.length, len(self.source)):
            sum = 0
            for i in range(self.length):
                sum += self.source[n-i-1]
            self.sma[n] = sum / self.length
        return np.array(self.sma, float)
