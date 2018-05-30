if which java &>/dev/null; then
  export CLASSPATH='*':'.' # Use current directory for default Java classpath
  export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
fi
