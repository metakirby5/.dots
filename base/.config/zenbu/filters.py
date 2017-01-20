import struct
import codecs


# Hex to X

def nohash(hex):
    return hex.lstrip('#')


def to_rgb(hex):
    return struct.unpack('BBB', codecs.decode(nohash(hex), 'hex'))


def to_chrome(hex):
    return '[{}]'.format(', '.join(map(str, to_rgb(hex))))


# alpha: 0 - 255
def to_apple(hex, alpha=0):
    return '{{{}}}'.format(', '.join(map(
        lambda x: str(x * 257), to_rgb(hex) + (alpha,)
    )))


# <dict> ... </dict>
def to_iterm_dict(hex):
    return """<dict>
        <key>Red Component</key>
        <real>{}</real>
        <key>Green Component</key>
        <real>{}</real>
        <key>Blue Component</key>
        <real>{}</real>
    </dict>""".format(*(x / 255.0 for x in to_rgb(hex)))
