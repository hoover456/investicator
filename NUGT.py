from Stock import Stock
from Indicators.MACD import *
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

stock = Stock('DUST')

mcd = MACD(3,10,3,stock.getClose())
m = mcd.get()
d = stock.getDates('%Y-%m-%d')
d = d[-30:]
m = m[:, -30:]

fig, ax= plt.subplots(2,1,sharex=False, sharey=False, gridspec_kw=dict(height_ratios=[3, 1]))
ax[0].plot_date(d, stock.getClose()[-30:], 'b-')
ax[1].plot(d,m[0, ], 'b-')
ax[1].plot_date(d,m[1, ], 'r-', xdate=True)
ax[0].yaxis.set_major_formatter(ticker.FormatStrFormatter('$%.2f'))
for tick in ax[0].yaxis.get_major_ticks():
    tick.label1On = False
    tick.label2On = True
for tick in ax[1].yaxis.get_major_ticks():
    tick.label1On = False
    tick.label2On = True
ax[1].axhline(y=0, color='black', ls = 'dashed')
fig.suptitle(stock.getIndex() + ' - 30 Day', size='20')
ax[0].set_title('Close Price')
ax[1].set_title('MACD')
plt.setp(ax[0].get_xticklabels(), fontsize=8, visible = True)
plt.setp(ax[1].get_xticklabels(), fontsize=8, visible = True)
ax[0].grid(b=True)
ax[1].grid(b=True)
print('MACD: ', mcd.getPrediction())
plt.show()