from __future__ import absolute_import, print_function, unicode_literals
from streamparse.spout import Spout

import time
import pickle

from sklearn import datasets


class EmitCycle(Spout):

    def initialize(self, stormconf, context):
        iris = datasets.load_iris()
        self.data = iris.data
        self.i = 0

    def next_tuple(self):
        time.sleep(3)
        row = str(self.data[self.i, :])
        if self.i >= 150:
            self.i = 0
        else:
            self.i = self.i + 1
        self.emit([row])


if __name__ == '__main__':
    EmitCycle().run()
