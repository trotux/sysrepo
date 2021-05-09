#!/bin/sh

build () {
    echo "Building project"
    cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Debug \
        -DGEN_LANGUAGE_BINDINGS=ON \
        -DGEN_CPP_BINDINGS=ON \
        -DBUILD_CPP_EXAMPLES=ON \
        -DGEN_PYTHON_BINDINGS=OFF \
        -DENABLE_PYTHON_TESTS=OFF \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DCMAKE_VERBOSE_MAKEFILE=YES
    cmake --build build
    ln -sf build/compile_commands.json
}

install() {
    echo "Not implemented"
}

clean() {
    echo "Cleaning project"
    rm -rf build
}

pvs () {
    echo "Checking project with PVS"
    pvs-studio-analyzer analyze -a 36 \
        -l ~/store/PVS-Studio.lic \
        -e /opt/ngfw/include \
        -o project.log

    plog-converter -a GA:1,2,3 -t tasklist -m cwe -o ga_results.tasks project.log
    plog-converter -a MISRA:1,2,3 -t tasklist -m misra -o misra_results.tasks project.log
}

ACTION="build"

for i in "$@"
do
    echo ">>$i"
case $i in
    build)
        ACTION="build"
    ;;
    install)
        ACTION="install"
    ;;
    pvs)
        ACTION="pvs"
    ;;
    clean)
        ACTION="clean"
    ;;
    *)
    ;;
esac
done

echo "Action ${ACTION}"

if [ $ACTION = "build" ]; then
    build
elif [ $ACTION = "install" ]; then
    install
elif [ $ACTION = "clean" ]; then
    clean
elif [ $ACTION = "pvs" ]; then
    pvs
else
   echo "Unknown action!"
fi


