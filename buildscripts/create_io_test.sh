#!/bin/env bash

cd $(dirname $0)/..

program_file=$1 ; shift

[ -z "${program_file}" ] && {
  echo "usages: $(basename $0) <progam_file> <test_number>"
  exit 1
}

test_number=$(printf "%02d" $1) ; shift

[ -z "${test_number}" ] && {
  echo "usages: $(basename $0) <progam_file> <test_number>"
  exit 1
}

printf "Creating test number %s for program %s\n" ${test_number} ${program_file}

if ! [ -x ${program_file} ]; then
  program_file=./build/${program_file};
fi

if ! [ -x ${program_file} ]; then
  echo program file not executeable 1>&2
  exit 1
fi

if [ ${test_number} -lt 0 ] || [ ${test_number} -gt 99 ]; then
  echo invalid test number 1>&2
  exit 2
fi

test_dir=./tests/io_tests/$(basename ${program_file})/

[ -d ${test_dir} ] || mkdir -p ${test_dir}

in_file=${test_dir}${test_number}.in
out_file=${test_dir}${test_number}.out
err_file=${test_dir}${test_number}.err

rm -f ${in_file}
rm -f ${out_file}
rm -f ${err_file}

tee ${in_file} | stdbuf -o0 ${program_file} 2> ${err_file} | tee ${out_file}
