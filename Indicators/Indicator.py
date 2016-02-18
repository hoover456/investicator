import numpy as np

class Indicator:
    def __init__ (self):
        self.data = []
        pass

    def get(self):
        return self.data
        raise NotImplementedError

    def getPrediction(self):
        raise NotImplementedError