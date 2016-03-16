from Indicators.Indicator import Indicator
import numpy as np


class RSI(Indicator):
    def __init__(self, close, **kwargs):
        self.data = close
        self.length = kwargs.get('length', 14)

    def get(self):
        change = np.zeros(len(self.data))
        for i in range(1, len(self.data)):
            change[i] = self.data[i] - self.data[i-1]
        gain = np.zeros(len(self.data))
        loss = np.zeros(len(self.data))
        for i in range(len(self.data)):
            if change[i] > 0:
                gain[i] = change[i]
            elif change[i] < 0:
                loss[i] = abs(change[i])
        avgGain = 0
        avgLoss = 0
        for i in range(self.length):
            avgGain = avgGain + gain[i]
            avgLoss = avgLoss + loss[i]
        avgGain = avgGain / self.length
        avgLoss = avgLoss / self.length
        rsi = np.zeros(len(self.data))
        rsi[self.length] = (100 - (100 / (1 + (avgGain / avgLoss))))
        for i in range(self.length + 1, len(self.data)):
            avgGain = (avgGain * (self.length - 1) + gain[i]) / self.length
            avgLoss = (avgLoss * (self.length - 1) + loss[i]) / self.length
            rsi[i] = (100 - (100 / (1 + (avgGain / avgLoss))))
        return rsi