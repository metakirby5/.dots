# Sources:
# http://avisynth.nl/index.php/SMDegrain
# https://redd.it/4ljbdq
# https://github.com/mpv-player/mpv/issues/566
# http://www.milanvit.net/post/115879507744/and-now-for-something-completely-different-motion

import vapoursynth as vs
core = vs.get_core()
core.std.LoadPlugin(path="/usr/local/lib/libmvtools.dylib")

FPS = 60             # Target fps
BLK = 32             # Block size (larger = faster, lower accuracy)
SCENE_THRESH = 32    # Scene change threshold
PRECISION = int(1e8) # Precision for FPS

clip = video_in
if container_fps < FPS:
    print("{}fps -> {}fps".format(container_fps, FPS))
    clip = core.std.AssumeFPS(clip, fpsnum=int(container_fps * PRECISION),
                              fpsden=PRECISION)
    sup  = core.mv.Super(clip)
    bvec = core.mv.Analyse(sup, isb=True , blksize=BLK)
    fvec = core.mv.Analyse(sup, isb=False, blksize=BLK)
    clip = core.mv.BlockFPS(clip, sup, bvec, fvec,
                            num=int(FPS * PRECISION), den=PRECISION,
                            thscd2=SCENE_THRESH)
clip.set_output()
