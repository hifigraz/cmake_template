#!/usr/bin/env sh

criterion_target=$1

rm -f ./${criterion_target} 

cmake --build . --target $(basename ${criterion_target})

out_file="./$(dirname ${criterion_target})/Testing/$(basename ${criterion_target}).out"

timeout 10 ./${criterion_target} --verbose > ${out_file}  2>&1 || {
    tail -n 10 ${out_file}
    rm -f ${out_file}
    exit 2
}
