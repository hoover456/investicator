from Stock import Stock
from Indicators.MACD import MACD
import numpy as np
import matplotlib.pyplot as plt

stock = Stock('NUGT')

mcd = MACD(3,10,3,stock.getClose())
m = mcd.get()
d = stock.getDates('%Y-%m-%d')

funds = 100000
shares = 0
price = 0

cash = np.empty([len(m[0, ])])

for i in range(len(m[0, ])):
    if mcd.getAllPredictions()[i] == -1:
        if int(funds / stock.getClose()[i]) != 0:
            shares += int(funds/ stock.getClose()[i])
            funds -= int(funds / stock.getClose()[i]) * stock.getClose()[i]
            if stock.getClose()[i] > price:
                price = stock.getClose()[i]
    elif mcd.getAllPredictions()[i] == 1 and shares * price < shares * stock.getClose()[i]:
        funds += shares * stock.getClose()[i]
        shares = 0
        price = 0
    cash[i] = funds
    #print(mcd.getAllPredictions()[i])
    #print('Buy = ', bool(mcd.getAllPredictions()[i]-1),' Close = ', stock.getClose()[i],' Funds = ', funds,' shares = ', shares)
    print('Buy = %2d' % mcd.getAllPredictions()[i] + ' Close = %5.2f' % stock.getClose()[i] + ' Funds = $%-10.2f' % funds + ' Shares = %d' % shares)

plt.plot_date(d, cash)
plt.show()