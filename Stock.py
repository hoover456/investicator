from datetime import datetime
import numpy as np
import matplotlib.dates
import urllib.request
import shutil

class Stock:

    def __init__(self, index):
        self.index = index
        url = 'http://real-chart.finance.yahoo.com/table.csv?s=' + index
        path = 'data/' + index + '.csv'
        with urllib.request.urlopen(url) as response, open(path, 'wb') as out_file:
            shutil.copyfileobj(response, out_file)
        self.data = np.array(np.genfromtxt(path, str, delimiter=','))
        self.data = self.data[1:, ]
        self.data = self.data[::-1]

    def getDates(self, form):
        dates = np.array(self.data[:, 0])
#        print(dates)
        for i in range(len(dates)):
            dates[i] = matplotlib.dates.date2num(datetime.strptime(dates[i], form))
        return dates

    def getOpen(self):
        return np.array(self.data[:, 1], float)

    def getHigh(self):
        return np.array(self.data[:, 2], float)

    def getLow(self):
        return np.array(self.data[:, 3], float)

    def getClose(self):
        return np.array(self.data[:, 4], float)

    def getVolume(self):
        return np.array(self.data[:, 5], float)

    def getAdjClose(self):
        return np.array(self.data[:, 6], float)

    def getIndex(self):
        return self.index