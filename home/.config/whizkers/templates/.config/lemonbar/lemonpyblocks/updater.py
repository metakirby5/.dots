class Updater(object):
    def __init__(self, observers=[]):
        self.observers = observers

    def register_observers(self, func):
        self.observers.append(func)

    def notify_observers(self):
        for observer in self.observers:
            observer.notify()

    def query(self):
        raise NotImplementedError

