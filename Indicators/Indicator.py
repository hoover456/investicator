import numpy as np
from abc import ABCMeta, abstractmethod


class Indicator:

    @abstractmethod
    def get(self): pass

    @abstractmethod
    def getPrediction(self): pass
