# Sources:
# https://redd.it/4ljbdq
# https://github.com/mpv-player/mpv/issues/566
# http://avisynth.nl/index.php/SMDegrain

import vapoursynth as vs
core = vs.get_core()
core.std.LoadPlugin(path="/usr/local/lib/libmvtools.dylib")

FPS = 60
BLK = 16
SCENE_THRESH = 48

clip = video_in
if container_fps < FPS:
    print("{}fps -> {}fps".format(container_fps, FPS))
    clip = core.std.AssumeFPS(clip, fpsnum=int(container_fps), fpsden=1)
    sup  = core.mv.Super(clip, pel=2, hpad=BLK, vpad=BLK)
    bvec = core.mv.Analyse(sup, truemotion=True, isb=True , chroma=True,
                           search=3, blksize=BLK)
    fvec = core.mv.Analyse(sup, truemotion=True, isb=False, chroma=True,
                           search=3, blksize=BLK)
    clip = core.mv.BlockFPS(clip, sup, bvec, fvec, num=FPS, den=1,
                            mode=3, thscd2=SCENE_THRESH)
clip.set_output()
