#!/usr/bin/env sh

criterion_target=$1

rm -f ./${criterion_target} 

cmake --build . --target $(basename ${criterion_target})

timeout 10 ./${criterion_target} || exit 2
