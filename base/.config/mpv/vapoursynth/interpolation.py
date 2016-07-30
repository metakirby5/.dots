# https://redd.it/4ljbdq
import vapoursynth as vs
core = vs.get_core()
core.std.LoadPlugin(path="/usr/local/lib/libmvtools.dylib")
core.std.LoadPlugin(path='/usr/local/lib/libffms2.dylib')

clip = video_in

src_num = int(float(container_fps) * 1e3)
src_den = int(1e3)
play_num = int(float(display_fps) * 1e3)
play_den = int(1e3)

clip = core.std.AssumeFPS(clip, fpsnum=src_num, fpsden=src_den)
sup  = core.mv.Super(clip, pel=2, hpad=16, vpad=16)
bvec = core.mv.Analyse(sup, truemotion=True, blksize=16, isb=True, chroma=True, search=3)
fvec = core.mv.Analyse(sup, truemotion=True, blksize=16, isb=False, chroma=True, search=3)
clip = core.mv.BlockFPS(clip, sup, bvec, fvec, num=play_num, den=play_den, mode=3, thscd2=48)

clip.set_output()

print("Source fps", (src_num/src_den))
print("Playback fps", (play_num/play_den))
