from Stock import *
from Indicators.MACD import *
from Indicators.Aroon import *
from Indicators.RSI import *
import numpy as np
class Backtest:

    def __init__(self):
        None

    def simulate(self, close, dates, rsi, macd, aroon, simLen):
        self.c = close
        self.d = dates
        self.r = rsi
        self.m = macd
        self.a = aroon
        self.SIMULATION_LENGTH = simLen

        MACD_WEIGHT = 0.5
        RSI_WEIGHT = 0.5
        AROON_WEIGHT = 0.5

        macdPredictions = self.m.getAllPredictions()
        aroonPredictions = self.a.getAllPredictions()
        rsiPredictions = self.r.getAllPredictions()

        BUY_THRESHOLD = 0.4
        SELL_THRESHOLD = -0.4

        predictions = np.zeros(self.SIMULATION_LENGTH)
        actuals = np.zeros(self.SIMULATION_LENGTH)

        funds = 100000
        shares = 0
        price = 0

        for i in range(1, len(self.d)):
            predictions[i-1] = (macdPredictions[i-1] * MACD_WEIGHT + aroonPredictions[i-1] * AROON_WEIGHT + rsiPredictions[i-1] * RSI_WEIGHT) / 3

            if self.c[i] > self.c[i-1]:
                actuals[i] = 1
            elif self.c[i] < self.c[i-1]:
                actuals[i] = -1


            if predictions[i-1] > BUY_THRESHOLD:
                shares += int(funds / self.c[i])
                funds -= int(funds / self.c[i]) * self.c[i]
                if self.c[i] > price:
                    price = self.c[i]
            elif predictions[i-1] < SELL_THRESHOLD:
                if self.c[i] > price:
                    funds += shares * self.c[i]
                    shares = 0
                    price = 0

            if macdPredictions[i-1] == actuals[i]:
                MACD_WEIGHT = (1 / (1 + MACD_WEIGHT))
            elif macdPredictions[i-1] == -1 * actuals[i]:
                MACD_WEIGHT = (1 / (1 + MACD_WEIGHT ** -1))

            if rsiPredictions[i-1] == actuals[i]:
                RSI_WEIGHT = (1 / (1 + RSI_WEIGHT ))
            elif rsiPredictions[i-1] == -1 * actuals[i]:
                RSI_WEIGHT = (1 / (1 + RSI_WEIGHT ** -1))

            if aroonPredictions[i-1] == actuals[i]:
                AROON_WEIGHT = (1 / (1 + AROON_WEIGHT))
            elif aroonPredictions[i-1] == -1 * actuals[i]:
                AROON_WEIGHT = (1 / (1 + AROON_WEIGHT ** -1))

        predictions = None
        actuals = None
        total = (funds + shares * self.c[len(self.d)-1])
        return total


# Define Constants
# MACD_LONG = 26
# MACD_SHORT = 14
MACD_SIGNAL = 9
# AROON_LENGTH = 23
RSI_LENGTH = 13
SIMULATION_LENGTH = 500

maxEarn = 0
# Get all variables and indicators
stock = Stock('AAPL')  # Stock
d = stock.getDates('%Y-%m-%d')  # dates
c = stock.getClose()[len(d)-SIMULATION_LENGTH:len(d)] # Closing Price
ac = stock.getAdjClose()[len(d)-SIMULATION_LENGTH:len(d)]
d = d[len(d)-SIMULATION_LENGTH:len(d)]
bt = Backtest()
for AROON_LENGTH in range(20, 28):
    for RSI_LENGTH in range(12, 16):
        for MACD_SIGNAL in range(3, 10):
            MACD_SHORT = MACD_SIGNAL * 1.5
            MACD_LONG = MACD_SHORT * 2

            m = MACD(c, long=MACD_LONG, short=MACD_SHORT, signal=MACD_SIGNAL)  # MACD object
            a = Aroon(c, length=AROON_LENGTH)  # Aroon Object
            r = RSI(c, length=RSI_LENGTH)  # RSI object
            l = 500

            total = bt.simulate(c,d,r,m,a,l)
            movement = ((total - 100000) / 100000) * 100
            if total > maxEarn:
                maxEarn = total
            print('AROON LENGTH = %2d' % AROON_LENGTH + ' RSI LENGTH = %2d' % RSI_LENGTH + ' MACD LONG = %2d' % MACD_LONG + ' MACD SHORT = %2d' % MACD_SHORT + ' MACD SIGNAL = %2d' % MACD_SIGNAL + ' total = $%-10.2f' % total + ' Movement = %+3.2f%%' % movement)