#!/usr/bin/env bash

# build.sh
# ----------------------------------------------------------------------
# main build script for manual unix builds
# ----------------------------------------------------------------------
# @author Robert Ulmer (robert.ulmer@lr.htlweiz.at)


# ----------------------------------------------------------------------
# stderr
# ----------------------------------------------------------------------
# just echo everythin to stderr for logging purposes etc.

stderr() {
  echo "$@" 1>&2
}

# ----------------------------------------------------------------------
# fail
# ----------------------------------------------------------------------
# Prompt an error message and exit the script
#   fail [-u] <exit_code> <error message>
#     -u              optional switch, when set the usage message is printed
#     exit_code       the exit code, with which the script should exit
#     error_message   The error message to be printed

fail() {
  print_usage=false
  if [ "${$1}" == "-u" ]; then
    print_usage=true
    shift
  fi
  exit_code=$1
  shift
  
  stderr Error: $@
  if ${print_usage}; then
    stderr
    usage
  fi
  exit ${exit_code}
}

# ----------------------------------------------------------------------
# usage
# ----------------------------------------------------------------------
# print the build.sh usage message

usage() {
  stderr "usage: $(basename $0) [-c] -[C] [-v]"
  stderr "    -c clean and cmake"
  stderr "    -C cmake"
  stderr "    -v verbose"
  stderr "    -h help"
}

# ----------------------------------------------------------------------
# taillog
# ----------------------------------------------------------------------
# prints the log files tail
#
# if called without logfile path, it assumes a more quieter mode of
# operation

taillog() {
  if [ -n "$1" ]; then
    stderr
    stderr --------------------------------------------------------------------------------
    stderr LOGs
    stderr --------------------------------------------------------------------------------
    stderr
    awk -f ../buildscripts/test.awk Testing/Temporary/LastTest.log  | stderr
    stderr
    stderr --------------------------------------------------------------------------------
    stderr Following Tests failed.
    stderr --------------------------------------------------------------------------------
    cat Testing/Temporary/LastTestsFailed.log | stderr
  else
    stderr Error occured rerun with -v to show log
  fi
  exit 1
}

# ----------------------------------------------------------------------
# main
# ----------------------------------------------------------------------
# 
# main loop dispatch commandline arguments and run cmake tasks

main() {
  CLEAN=""
  CMAKE=""
  VERBOSE=""
  chmod +x $(dirname $0)/../buildscripts/*sh
  while [ -n "$1" ]; do
    if [ "$1" == "-c" ]; then
      CLEAN=Y
      CMAKE=Y
      shift
    elif [ "$1" == "-C" ]; then
      CMAKE=Y
      shift
    elif [ "$1" == "-v" ]; then
      VERBOSE=Y
      shift
    elif [ "$1" == "-h" ]; then
      usage
      exit 0
    else
      fail -u 1 Error $1 unknown
    fi
  done

  cd $(dirname $0)/..
  if [ -n "${CLEAN}" ]; then
    stderr WARNING: running clean build
    rm -rf build
  fi
  [ -e build ] || {
    mkdir build
    CMAKE=y
  }
  cd build
  if [ -n "${CMAKE}" ]; then
    stderr INFO: rerunning cmake
    cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .. || fail 1 CMAKE FAILED
  fi
  cmake --build . --target=all || fail 2 Build failed

  cmake --build . --target=test || taillog $VERBOSE
}

main $@
