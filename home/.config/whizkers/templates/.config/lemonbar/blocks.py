# -* coding: utf-8 -*-
import logging
import i3ipc
import constants
from time import sleep
from datetime import datetime

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.NullHandler())


# Abstract block
class Block(object):
    def __init__(self, observers=[]):
        self.__observers = observers

    def register_observers(self, func):
        self.__observers.append(func)

    def notify_observers(self):
        for observer in self.__observers:
            observer.notify()

    # Should update block output state
    def update(self):
        raise NotImplementedError

    # Should return block output with minimal logic involved
    def query(self):
        raise NotImplementedError


# Abstract block which updates every constants.TICK seconds
class TickBlock(Block):
    def __init__(self, observers=[]):
        super(TickBlock, self).__init__(observers)
        self.update()

    # Should run in a separate thread
    # TODO: maybe make running itself in a thread its job?
    def main(self):
        while True:
            sleep(constants.TICK)
            self.update()
            self.notify_observers()


# Abstract block which updates via an i3ipc connection
class I3Block(Block):
    def __init__(self, conn, observers=[]):
        super(I3Block, self).__init__(observers)
        self.conn = conn
        self.do_registration()
        self.update()

    # Here is where all callback registration should be done
    def do_registration(self):
        raise NotImplementedError

    # Registers a self.__on_change to the i3 connection
    def register(self, events):
        for event in events:
            self.conn.on(event, self.__on_change)

    def __on_change(self, ipc, e):
        self.update()
        self.notify_observers()


class DatetimeBlock(TickBlock):
    def update(self):
        self.time = datetime.now().strftime(constants.TIME_FMT)
        logger.debug('built dtm: %s' % self.time)

    def query(self):
        return self.time


class WorkspaceBlock(I3Block):
    def do_registration(self):
        self.register(['workspace'])

    def update(self):
        spaces_text = []
        for space in self.conn.get_workspaces():
            current = space['name'].partition(':')[-1] \
                if ':' in space['name'] \
                else space['name']

            if space['visible']:
                current = '%%{+u}%s%%{-u}' % (current)
            current = '%%{A:i3-msg workspace "%s":}  %s  %%{A}' % (
                space['name'].replace(':', '\\:'), current)
            if space['urgent']:
                current = '%%{B%s}%s%%{B%s}' % (
                    constants.C_URGENT, current, constants.C_BG)

            spaces_text.append(current)
        self.spaces_str = ''.join(spaces_text).encode('utf-8')
        logger.debug('built wks: %s' % self.spaces_str)

    def query(self):
        return self.spaces_str


class TitleBlock(I3Block):
    def do_registration(self):
        self.register(['window', 'workspace::focus'])

    def update(self):
        name = self.conn.get_tree().find_focused().name
        self.title = (name[:constants.MAX_TITLE_LEN] + (
            u'…' if len(name) > constants.MAX_TITLE_LEN else ''
        )).encode('utf-8')
        logger.debug('built win: %s' % self.title)

    def query(self):
        return self.title
