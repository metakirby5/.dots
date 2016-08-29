def nohash(hex):
  return hex.lstrip('#')

def to_chrome(hex):
  return '[{}]'.format(', '.join(
      map(lambda i: str(ord(i)), nohash(hex).decode('hex'))))
