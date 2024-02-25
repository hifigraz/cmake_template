#!/usr/bin/env sh

fail() {
  exit_code=$1
  shift
  echo Error: $@
  exit ${exit_code}
}

usage() {
  echo "usage: $(basename $0) [-c] -[C] [-v]"
  echo "    -c clean and cmake"
  echo "    -C cmake"
  echo "    -v verbose"
  echo "    -h help"
}

taillog() {
  if [ -n "$1" ]; then
    echo
    echo --------------------------------------------------------------------------------
    echo LOGs
    echo --------------------------------------------------------------------------------
    echo
    awk -f ../buildscripts/test.awk Testing/Temporary/LastTest.log  
    echo
    echo --------------------------------------------------------------------------------
    echo Following Tests failed.
    echo --------------------------------------------------------------------------------
    cat Testing/Temporary/LastTestsFailed.log  
  else
    echo Error occured rerun with -v to show log
  fi
  exit 1
}

main() {
  CLEAN=""
  CMAKE=""
  VERBOSE=""
  while [ -n "$1" ]; do
    if [ "$1" == "-c" ]; then
      echo "got -c"
      CLEAN=Y
      CMAKE=Y
      shift
    elif [ "$1" == "-C" ]; then
      echo "got -C"
      CMAKE=Y
      shift
    elif [ "$1" == "-v" ]; then
      echo "got -v"
      VERBOSE=Y
      shift
    elif [ "$1" == "-h" ]; then
      usage
      exit 0
    else
      echo Error $1 unknown
      usage
      exit 1
    fi
  done

  cd $(dirname $0)
  if [ -n "${CLEAN}" ]; then
    echo WARNING: running clean build
    rm -rf build
  fi
  [ -e build ] || {
    mkdir build
    CMAKE=y
  }
  cd build
  if [ -n "${CMAKE}" ]; then
    echo INFO: rerunning cmake
    cmake .. || fail 1 CMAKE FAILED
  fi
  cmake --build . --target=all || fail 2 Build failed

  cmake --build . --target=test || taillog $VERBOSE
}

main $@
