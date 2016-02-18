from Indicators.Indicator import *
from Indicators.EMA import *

class MACD(Indicator):

    def __init__(self, short, long, sig, array):
        self.short = short
        self.long = long
        self.signal = sig
        self.source = array
        self.macd = np.empty([2, len(self.source)])

    def get(self):
        self.macd[0, ] = np.array([EMA(self.short, self.source).get() - EMA(self.long, self.source).get()], float)
        self.macd[0, 0:self.long] = [0 for i in range(self.long)]
        self.macd[1, self.long:] = np.array(EMA(self.signal, self.macd[0, self.long:]).get())
        self.macd[1, 0:(self.long + self.signal)] = 0
        return self.macd

    def getPrediction(self):
        if(self.macd[0, -1] > self.macd[1, -1]):
            return 'Price increase predicted'
        else:
            return 'Price decrease predicted'
