CUDA_HOME="/usr/local/cuda"
if [ -d "$CUDA_HOME" ]; then
  export \
    CUDA_HOME \
    DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$CUDA_HOME/lib" \
    PATH="$CUDA_HOME/bin:$PATH"
fi
