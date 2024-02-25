#!/usr/bin/env sh

criterion_target=$1

rm -f ./${criterion_target} 

cmake --build . --target $(basename ${criterion_target})

./${criterion_target} || exit 2
