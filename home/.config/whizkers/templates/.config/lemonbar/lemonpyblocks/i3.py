# -* coding: utf-8 -*-
import logging
import i3ipc
import colors
from updater import Updater

ENCODING = 'utf-8'
MAX_TITLE_LEN = 80

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)


class I3Updater(Updater):
    def __init__(self, conn, observers=[]):
        super(I3Updater, self).__init__(observers)
        self.conn = conn


class WorkspaceUpdater(I3Updater):
    def __init__(self, conn, observers=[]):
        super(WorkspaceUpdater, self).__init__(conn, observers)
        self.build()
        conn.on('workspace', self.on_workspace)

    def on_workspace(self, ipc, e):
        self.build()
        self.notify_observers()

    def build(self):
        spaces_text = []
        for space in self.conn.get_workspaces():
            current = space['name'].partition(':')[-1] \
                if ':' in space['name'] \
                else space['name']

            if space['visible']:
                current = '%%{+u}%s%%{-u}' % (current)
            if space['urgent']:
                current = '%%{B%s}%s%%{B-}' % (colors.C_URGENT, current)
            current = '%%{A:i3-msg workspace "%s":}%s%%{A}' % (
                space['name'].replace(':', '\\:'), current)

            spaces_text.append(current)
        self.spaces_str = ('  '.join(spaces_text)).encode(ENCODING)
        logger.debug('built wks: %s' % self.spaces_str)

    def query(self):
        return self.spaces_str


class WindowUpdater(I3Updater):
    def __init__(self, conn, observers=[]):
        super(WindowUpdater, self).__init__(conn, observers)
        self.build()
        conn.on('window', self.on_change)
        conn.on('workspace::focus', self.on_change)

    def on_change(self, ipc, e):
        self.build()
        self.notify_observers()

    def build(self):
        name = self.conn.get_tree().find_focused().name
        self.title = (name[:MAX_TITLE_LEN] + (
            u'…' if len(name) > MAX_TITLE_LEN else ''
        )).encode(ENCODING)
        logger.debug('built win: %s' % self.title)

    def query(self):
        return self.title
