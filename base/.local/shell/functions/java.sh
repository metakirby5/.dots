# Compile and run a Java class
javar() {
    if [ ! "$1" ]; then
        echo 'Usage: javar [class name]'
        echo 'Example for a file named "Test.java":'
        echo '    $ javar Test'
        return
    fi
    javac $1.java && \
    java $1
}
