from __future__ import absolute_import, print_function, unicode_literals

import time
import itertools

from streamparse.spout import Spout

class WordSpout(Spout):

    def initialize(self, stormconf, context):
        self.words = itertools.cycle(['dog', 'cat',
                                      'zebra', 'elephant'])

    def next_tuple(self):
        time.sleep(3)
        word = next(self.words)
        self.emit([word])


if __name__ == '__main__':
    WordSpout().run()
