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

# Get all variables and indicators
stock = Stock('NUGT')  # Stock
c = stock.getClose()  # Closing Price
m = MACD(stock.getAdjClose(), long=MACD_LONG, short = MACD_SHORT, signal = MACD_SIGNAL)  # MACD object
d = stock.getDates('%Y-%m-%d')  # dates
a = Aroon(stock.getAdjClose(), length = AROON_LENGTH)  # Aroon Object
r = RSI(stock.getAdjClose(), length = RSI_LENGTH)  # RSI object





















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