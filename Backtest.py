from Stock import *
from Indicators.MACD import *
from Indicators.Aroon import *
from Indicators.RSI import *
import numpy as np
import math

class Metric:
    def __init__(self, name, initialWeightX, indicatorObject):
        self.name = name
        self.weightX = initialWeightX
        self.predictions = indicatorObject.getAllPredictions()
        self.weight = 1 / (1 + math.e ** self.weightX)

    def reweight(self, direction):
        self.weightX += direction
        self.weight = 1 / (1 + math.e ** self.weightX)
        # print('Indicator: {:s} Weight: {:5.2f}'.format(self.name, self.weight))

    def getWeight(self):
        return self.weight

    def getPrediction(self, n):
        return self.predictions[n]


class Backtest:

    def __init__(self, metrics, prices, funds, buyThreshold, sellThreshold):
        self.metrics = metrics
        self.prices = prices
        self.funds = funds
        self.initialFunds = funds
        self.shares = 0
        self.buyThreshold = buyThreshold
        self.sellThreshold = sellThreshold

    def simulate(self):
        SIMULATION_LENGTH = len(self.prices)
        guess = np.zeros(SIMULATION_LENGTH)
        meanTime = int(0.05 * SIMULATION_LENGTH)
        # print(meanTime)
        # print('--------------------------------')
        # print('            SIMULATING          ')
        # print('--------------------------------')
        for i in range(SIMULATION_LENGTH):
            # Get guess for all metrics
            for n in range(len(self.metrics)):
                guess[i] += self.metrics[n].getPrediction(i) * self.metrics[n].getWeight()

            guess[i] /= len(self.metrics)
            # print(guess[i])
            # Buy or sell based on guess
            if guess[i] >= self.buyThreshold:
                self.buy(self.prices[i])
            elif guess[i] <= self.sellThreshold:
                self.sell(self.prices[i])

            # reweight based on last n days where n = 0.05 * SIMULATION_LENGTH

            if i > meanTime:
                mean = 0
                for num in range(i - meanTime, i):
                    mean += (self.prices[num] - self.prices[num - 1])
                mean /= meanTime
                if mean != 0:
                    mean /= abs(mean)

                # for n in range(len(self.metrics)):
                #     if self.metrics[n].getPrediction(i-meanTime) == mean:
                #         self.metrics[n].reweight(0.25)
                #     elif self.metrics[n].getPrediction(i-meanTime) == -1 * mean:
                #         self.metrics[n].reweight(-0.25)

            # print(self.funds)
            total = (self.funds + self.shares * self.prices[i])
            movement = 100 * ((total - self.initialFunds) / self.initialFunds)
            # print(total, movement)
            # print(i, self.shares)
            # print(self.funds, self.shares, total, movement)
            # print('Day: {:<4d} Funds: ${:<9.2f} Shares: {:<7d} Price: {:<5.2f} Total: ${:<9.2f} Movement: {:5.2f}%%'.format(i, self.funds, self.shares, self.prices[i], total, movement))
        total = (self.funds + self.shares * self.prices[len(self.prices)-1])
        movement = 100 * ((total - self.initialFunds) / self.initialFunds)
        # print('Total = $%-7.2f' % total + ' Movement = %4.2f%%' % movement)
        return total

    def buy(self, price):
        self.shares += math.floor(self.funds / price)
        self.funds -= (price * math.floor(self.funds / price))

    def sell(self, price):
        self.funds += self.shares * price
        self.shares = 0

# Define Constants
print('--------------------------------')
print('            SIMULATING          ')
print('--------------------------------')
# MACD_SIGNAL = 4
# MACD_SHORT = 1.5 * MACD_SIGNAL
# MACD_LONG = 2 * MACD_SHORT
AROON_LENGTH = 1
RSI_LENGTH = 2
BUY_THRESHOLD = 0.25
SELL_THRESHOLD = -0.25
SIMULATION_LENGTH = 200

stock = Stock('NUGT')  # Stock
close = stock.getClose()[(len(stock.getClose()) - SIMULATION_LENGTH): len(stock.getClose())]
aroon = Aroon(close, length=AROON_LENGTH)
rsi = RSI(close, length=RSI_LENGTH)

# for i in range(5, 15):
# for j in range(1, 15):
MACD_SIGNAL = 0
MACD_SHORT = 1.5 * MACD_SIGNAL
MACD_LONG = 2 * MACD_SHORT
macd = MACD(close, long=MACD_LONG, short=MACD_SHORT, signal=MACD_SIGNAL)

metrics2 = []
metrics2.append(Metric('MACD', 0, macd))
metrics2.append(Metric('RSI', 0, rsi))
metrics2.append(Metric('Aroon', 0, aroon))
# print(metrics2)
# maxTotal = 0
test = Backtest(metrics2, close, 100000, BUY_THRESHOLD, SELL_THRESHOLD)
total = test.simulate()
print('Total ${:<9.2f} RSI {:<2d} SIGNAL {:<2d}'.format(total, RSI_LENGTH, MACD_SIGNAL))
total = 0
test = None
metrics2 = None
macd = None

'''
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
SIMULATION_LENGTH = 200

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
'''