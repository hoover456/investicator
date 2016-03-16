from Indicators.Indicator import *
from Indicators.EMA import *

class MACD(Indicator):

    def __init__(self, array, **kwargs):
        self.short = kwargs.get('short', 14)
        self.long = kwargs.get('long', 26)
        self.signal = kwargs.get('signal', 9)
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

    def getAllPredictions(self):
        predictions = np.empty([len(self.macd[0, ])])
        for i in range (len(self.macd[0, ])):
            if self.macd[0, i] > self.macd[1, i] and self.macd[0, i-1] < self.macd[1, i-1]:
                predictions[i] = 1
            elif self.macd[0, i] < self.macd[1, i] and self.macd[0, i-1] > self.macd[1, i-1]:
                predictions[i] = -1
            else:
                predictions[i] = 0
        return predictions
