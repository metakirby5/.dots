CUDA_HOME="/usr/local/cuda"
[ -d "$CUDA_HOME" ] && export \
  CUDA_HOME \
  DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$CUDA_HOME/lib" \
  PATH="$CUDA_HOME/bin:$PATH" ||
  unset CUDA_HOME
