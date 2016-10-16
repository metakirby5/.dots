CUDA_HOME="/usr/local/cuda"
if [ -d "$CUDA_HOME" ]; then
  export CUDA_HOME
  export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$CUDA_HOME/lib"
  export PATH="$CUDA_HOME/bin:$PATH"
fi
