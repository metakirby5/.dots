import logging
from time import sleep
from datetime import datetime
from updater import Updater

MIN_INTERVAL = 1
TIME_FMT = '%a %b %d %H:%M'

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)


class DatetimeUpdater(Updater):
    def __init__(self, observers=[]):
        super(DatetimeUpdater, self).__init__(observers)
        self.build()

    def main(self):
        while True:
            sleep(MIN_INTERVAL)
            self.build()
            self.notify_observers()

    def build(self):
        self.time = datetime.now().strftime(TIME_FMT)
        logger.debug('built dtm: %s' % self.time)

    def query(self):
        return self.time

