# Sources:
# https://redd.it/4ljbdq
# https://github.com/mpv-player/mpv/issues/566
# http://avisynth.nl/index.php/SMDegrain

import vapoursynth as vs
core = vs.get_core()
core.std.LoadPlugin(path="/usr/local/lib/libmvtools.dylib")

FPS = 60
BLK = 32
SCENE_THRESH = 32
PRECISION = int(1e8)

analyse_args = {
    'blksize': BLK,
    'truemotion': True,
    'search': 3,
}

clip = video_in
if container_fps < FPS:
    print("{}fps -> {}fps".format(container_fps, FPS))
    clip = core.std.AssumeFPS(clip, fpsnum=int(container_fps * PRECISION),
                              fpsden=PRECISION)
    sup  = core.mv.Super(clip, pel=2, hpad=BLK, vpad=BLK)
    bvec = core.mv.Analyse(sup, isb=True , **analyse_args)
    fvec = core.mv.Analyse(sup, isb=False, **analyse_args)
    clip = core.mv.BlockFPS(clip, sup, bvec, fvec, num=int(FPS * PRECISION),
                            den=PRECISION, mode=3, thscd2=SCENE_THRESH)
clip.set_output()
