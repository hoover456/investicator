from abc import ABCMeta, abstractmethod
import numpy as np

class Indicator:

    @abstractmethod
    def get(self): pass

    @abstractmethod
    def getPrediction(self): pass
