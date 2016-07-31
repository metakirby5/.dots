# Sources:
# http://avisynth.nl/index.php/SMDegrain
# https://redd.it/4ljbdq
# https://github.com/mpv-player/mpv/issues/566
# http://www.milanvit.net/post/115879507744/and-now-for-something-completely-different-motion

import vapoursynth as vs
core = vs.get_core()
core.std.LoadPlugin(path="/usr/local/lib/libmvtools.dylib")

BLK = 32             # Block size (larger = faster, lower accuracy)

analyse_args = {
    'blksize':     BLK,
    'search':      0,
    'searchparam': 1,
    'truemotion':  True,
}

clip = video_in
if container_fps < 60:
    clip = core.std.AssumeFPS(clip,
                              fpsnum=int(container_fps * 1e3), fpsden=1001)
    sup  = core.mv.Super(clip)
    bvec = core.mv.Analyse(sup, isb=True , **analyse_args)
    fvec = core.mv.Analyse(sup, isb=False, **analyse_args)
    clip = core.mv.BlockFPS(clip, sup, bvec, fvec,
                            num=60000, den=1001)
clip.set_output()
