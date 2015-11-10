# Constants for blocks

C_BG            = '#ff272727'
C_FG            = '#fffafafa'
C_URGENT        = '#ffff0000'
C_TRANSPARENT   = '#00000000'
# C_BG        = '{{ n_black }}'
# C_FG        = '{{ fgc }}'
# C_URGENT    = '{{ b_red }}'

S_NORMAL        = '%%{B%s}%%{F%s}' % (C_BG, C_FG)
S_TRANSPARENT   = '%%{B%s}%%{F%s}' % (C_TRANSPARENT, C_TRANSPARENT)

TICK = 1                        # For TickBlock
TIME_FMT = '%a %b %d %H:%M'     # For DatetimeBlock
MAX_TITLE_LEN = 80              # For TitleBlock
