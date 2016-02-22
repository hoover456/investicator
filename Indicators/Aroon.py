from Indicator import *


class Aroon(Indicator):

    def __init__(self, data, **kwargs):
        self.length = kwargs.get('length', 25) #length of aroon occilation
        self.data = data
        self.up = None
        self.down = None

    def getUp(self):
        self.up = np.empty([len(self.data)])
        for i in range(self.length, len(self.data)):
            self.up[i] = (self.length - np.argmax(self.data[i-self.length:i])) / self.length * 100
        return self.up

    def getDown(self):
        self.down = np.empty([len(self.data)])
        for i in range(self.length, len(self.data)):
            self.down[i] = (self.length - np.argmin(self.data[i-self.length:i])) / self.length * 100
        return self.down

    def getOccilator(self):
        return self.getUp() - self.getDown()

    def get(self):
        r = np.empty([3, len(self.data)])
        r[0, ] = self.up
        r[1, ] = self.down
        r[2, ] = self.getOccilator()
        return r
