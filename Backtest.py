from Stock import Stock
from Indicators.MACD import MACD
from Indicators.Aroon import Aroon
from Indicators.RSI import RSI
import numpy as np
import matplotlib.pyplot as plt

# Define Constants
MACD_LONG = 26
MACD_SHORT = 14
MACD_SIGNAL = 9
AROON_LENGTH = 25
RSI_LENGTH = 14
SIMULATION_LENGTH = 500

# Get all variables and indicators
stock = Stock('BA')  # Stock
d = stock.getDates('%Y-%m-%d')  # dates
c = stock.getClose()[len(d)-SIMULATION_LENGTH:len(d)]  # Closing Price
m = MACD(stock.getAdjClose()[len(d)-SIMULATION_LENGTH:len(d)], long=MACD_LONG, short = MACD_SHORT, signal = MACD_SIGNAL)  # MACD object
a = Aroon(stock.getAdjClose()[len(d)-SIMULATION_LENGTH:len(d)], length = AROON_LENGTH)  # Aroon Object
r = RSI(stock.getAdjClose()[len(d)-SIMULATION_LENGTH:len(d)], length = RSI_LENGTH)  # RSI object
d = d[len(d)-SIMULATION_LENGTH:len(d)]

MACD_WEIGHT = 0.5
RSI_WEIGHT = 0.5
AROON_WEIGHT = 0.5

macdPredictions = m.getAllPredictions()
aroonPredictions = a.getAllPredictions()
rsiPredictions = r.getAllPredictions()

BUY_THRESHOLD = 0.05
SELL_THRESHOLD = -0.05

predictions = np.empty(SIMULATION_LENGTH)
actuals = np.zeros(SIMULATION_LENGTH)
max = 0

while BUY_THRESHOLD <= 0.7:
    SELL_THRESHOLD = 0.05
    while SELL_THRESHOLD >= -0.7:
        funds = 100000
        shares = 0
        price = 0
        for i in range(1, len(d)):
            predictions[i-1] = (macdPredictions[i-1] * MACD_WEIGHT + aroonPredictions[i-1] * AROON_WEIGHT + rsiPredictions[i-1] * RSI_WEIGHT) / 3

            if c[i] > c[i-1]:
                actuals[i] = 1
            elif c[i] < c[i-1]:
                actuals[i] = -1


            if predictions[i-1] > BUY_THRESHOLD:
                shares += int(funds / c[i])
                funds -= int(funds / c[i]) * c[i]
                if c[i] > price:
                    price = c[i]
            elif predictions[i-1] < SELL_THRESHOLD:
                if c[i] > price:
                    funds += shares * c[i]
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


            # print('MACD: %2d' % macdPredictions[i-1] + ' Weight = %.3f' % MACD_WEIGHT + ' Aroon: %2d' % aroonPredictions[i-1] + ' Weight = %.3f' % AROON_WEIGHT + ' RSI: %2d' % rsiPredictions[i-1] + ' Weight: %.3f' % RSI_WEIGHT + ' Actual: %2d' % actuals[i])

            #print('close = %6.2f' % c[i] + ' funds = $%-10.2f' % funds + ' shares = %6d' % shares + ' value = $%-10.2f' % (shares * c[i]) + ' total = $%-10.2f' % (funds + shares * c[i]) + ' Movement = %+3.2f%%' % ((((funds + shares * c[i]) - 100000) / 100000) * 100))
        if (funds + shares * c[len(d)-1]) > max:
            max = (funds + shares * c[len(d)-1])
            print('BUY THRESHOLD = %5.2f' % BUY_THRESHOLD + ' SELL THRESHOLD = %5.2f' % SELL_THRESHOLD + ' total = $%-10.2f' % (funds + shares * c[len(d)-1]) + ' Movement = %+3.2f%%' % ((((funds + shares * c[len(d)-1]) - 100000) / 100000) * 100))
        SELL_THRESHOLD -= 0.05
    BUY_THRESHOLD += 0.05


'''
for i in range(1, len(d)):
    predictions[i-1] = (macdPredictions[i-1] * MACD_WEIGHT + aroonPredictions[i-1] * AROON_WEIGHT + rsiPredictions[i-1] * RSI_WEIGHT) / 3

    if c[i] > c[i-1]:
        actuals[i] = 1
    elif c[i] < c[i-1]:
        actuals[i] = -1


    if predictions[i-1] > BUY_THRESHOLD:
        shares += int(funds / c[i])
        funds -= int(funds / c[i]) * c[i]
        if c[i] > price:
            price = c[i]
    elif predictions[i-1] < SELL_THRESHOLD:
        if c[i] > price:
            funds += shares * c[i]
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


    # print('MACD: %2d' % macdPredictions[i-1] + ' Weight = %.3f' % MACD_WEIGHT + ' Aroon: %2d' % aroonPredictions[i-1] + ' Weight = %.3f' % AROON_WEIGHT + ' RSI: %2d' % rsiPredictions[i-1] + ' Weight: %.3f' % RSI_WEIGHT + ' Actual: %2d' % actuals[i])

    print('close = %6.2f' % c[i] + ' funds = $%-10.2f' % funds + ' shares = %6d' % shares + ' value = $%-10.2f' % (shares * c[i]) + ' total = $%-10.2f' % (funds + shares * c[i]) + ' Movement = %+3.2f%%' % ((((funds + shares * c[i]) - 100000) / 100000) * 100))











'''

'''
funds = 100000
shares = 0
price = 0

for i in range(50, len(d)):
    if m[0, i] < m[1,i] and m[0, i-1] > m[1, i-1] and a.getOccilator()[i] > 25:
        shares += int(funds / c[i])
        funds -= int(funds / c[i]) * c[i]
        if c[i] > price:
            price = c[i]
    if m[0,i] > m[1,i] and a.getOccilator()[i] < -25:
        if c[i] > price:
            funds += shares * c[i]
            shares = 0
            price = 0
    #print('close = %5.2f' % c[i] + ' funds = %10.2f' % funds + ' Aroon = %3.2f' % a.getOccilator()[i] + ' sell = ', bool(m[0,i] > m[1,i] and m[0,i-1] < m[1, i-1]))
    print('close = %5.2f' % c[i] + ' funds = %10.2f' % funds + ' shares = %d' % shares + ' value = %f' % (shares * c[i]))
print('close = %5.2f' % c[len(d)-1] + ' funds = %10.2f' % funds + ' shares = %d' % shares + ' value = %f' % (shares * c[len(d)-1]))
'''