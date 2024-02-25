#!/usr/bin/env bash
USAGE="usage:

%s command arguments

commands:

  command               argument     description
  
  add_program           program_name     creates a program in the project
  add_library           library_name     creates a library in the project
  add_criterion_test    test_name        creates a criterion test in the project
  add_io_test           program_name     creates a io test for the given program 
  remove_program        program_name     deletes a program in the project
  remove_library        library_name     deletes a library in the project
  remove_criterion_test test_name        deletes a criterion test in the project
  remove_io_test        program_name     deletes io tests for the given program 
  list_targets                           lists targets in the project

  command           arguments                    description

  list_dependencies target_name                  lists the dependencies of a target
  add_dependency    target_name dependency_name  add dependency to a single target
  remove_dependency target_name dependency_name  remove denepency from a single target

"

PROJECT_ROOT=$(cd $(dirname $0);pwd)
PROGRAMS_ROOT=${PROJECT_ROOT}/src/programs/
LIBRARIES_ROOT=${PROJECT_ROOT}/src/libraries/
CRITERION_ROOT=${PROJECT_ROOT}/tests/criterion/
IO_TEST_ROOT=${PROJECT_ROOT}/tests/io_tests/

main() {
  command=$1
  [ -z ${command} ] && fail 1 No command given || shift
  case ${command} in
    list_targets)
      print_targets src/programs program targets:
      print_targets src/libraries library targets:
      print_targets tests/criterion criterion test targets:
      print_targets tests/io_tests io test targets:
      ;;
    list_dependencies)
      target_name=$1; [ -z ${target_name} ] && fail 30 No target given || shift
      print_deps ${target_name}
      ;;
    add_dependency)
      target_name=$1; [ -z ${target_name} ] && fail 2 No target given || shift
      add_dep ${target_name} $*
      ;;
    remove_dependency)
      target_name=$1; [ -z ${target_name} ] && fail 3 No target given || shift
      for dependency in $*; do
        rm_dep ${target_name} ${dependency}
      done
      ;;
    add_io_test)
      io_test_name=$1
      add_target "00.in:00.out:00.err" ${IO_TEST_ROOT}/${io_test_name}
      ;;
    remove_io_test)
      io_test_name=$1
      remove_target ${IO_TEST_ROOT} ${io_test_name}
      ;;
    add_criterion_test)
      criterion_test_name=$1
      add_target "dummy_test.cpp" ${CRITERION_ROOT}/${criterion_test_name}
      ;;
    remove_criterion_test)
      criterion_test_name=$1
      remove_target ${CRITERION_ROOT} ${criterion_test_name}
      ;;
    add_program)
      program_name=$1
      add_target "main.cpp" ${PROGRAMS_ROOT}/${program_name}
      ;;
    remove_program)
      program_name=$1
      remove_target ${PROGRAMS_ROOT} ${program_name}
      ;;
    add_library)
      library_name=$1
      library_lower_name=$(echo ${library_name} | tr '[:upper:]' '[:lower:]')
      add_target "${library_lower_name}.cpp:include/${library_lower_name}.h"  ${LIBRARIES_ROOT}/${library_name}
      ;;
    remove_library)
      library_name=$1
      remove_target ${LIBRARIES_ROOT} ${library_name}
      ;;
    *)
      usage
      fail 1 Unknown command ${command}
      ;;
  esac
}

fail() {
  exit_code=$1
  shift
  echo "Error: " $* >&2
  exit ${exit_code}
}

usage() {
  printf "${USAGE}" $(basename $0) >&2
}

rm_dep() {
  target_name=$1; [ -z ${target_name} ] && fail 40 target not given || shift
  real_target=$(find_target ${target_name})
  deps_file=${real_target}/deps.txt
  single_dependency=$1; [ -z ${single_dependency} ] && fail 41 dependency not given || shift
  grep ^${single_dependency}$ ${deps_file} 2>&1 > /dev/null || fail 42 ${single_dependency} is not set in ${target_name}
  sed -i /^${single_dependency}$/d ${deps_file} 
}

add_dep() {
  target_name=$1; [ -z ${target_name} ] && fail 40 target not given || shift
  real_target=$(find_target ${target_name})
  deps_file=${real_target}/deps.txt
  for single_dependency in $*; do
    echo ${single_dependency} >> ${deps_file}
  done
  cat ${deps_file} | sort | uniq > ${deps_file}.tmp && mv ${deps_file}.tmp ${deps_file}
}

print_deps() {
  target_name=$1; [ -z ${target_name} ] && fail 31 target not given || shift
  real_target=$(find_target ${target_name})
  [ -e ${real_target} ] || fail 31 target ${real_target} does not exist
  echo dependencies for target ${target_name}:
  echo ================================================================================
  cat ${real_target}/deps.txt 2>/dev/null
  echo
}

find_target() {
  target_name=$1; [ -z ${target_name} ] && fail 32 target not given || shift
  for target_base in ${PROGRAMS_ROOT} ${LIBRARIES_ROOT} ${CRITERION_ROOT} ; do
    if [ -d ${target_base}/${target_name} ]; then 
      echo ${target_base}/${target_name}
      return 0
    fi
  done
  fail 32 target ${target_name} not found
}

remove_target() {
  target_dir=$1; [ -z ${target_dir} ] && fail 20 no target given || shift
  target_name=$1; [ -z ${target_name} ] && fail 20 no target given || shift 
  target_dir=${target_dir}/${target_name}
  [ -e ${target_dir} ] || fail 20 ${target_name} does not exist
  echo ================================================================================
  find ${target_dir}
  echo ================================================================================
  echo -n "do you realy want to remove this files then enter ${target_name} : "
  read confirmation
  if [ ${confirmation} == ${target_name} ]; then 
    rm -rf ${target_dir}
  else
    fail 21 Removal of ${target_name} canceled
  fi
}

add_target() {
  add_files=$1; shift
  target_dir=$1; [ -z ${target_dir} ] && fail 10 no target given || shift
  [ -e ${target_dir} ] && fail 10 target $(basename ${target_dir}) already exists
  mkdir -p ${target_dir}
  IFS=':' read -ra FILES <<< "${add_files}"
  for i in "${FILES[@]}"; do
    mkdir -p ${target_dir}/$(dirname $i)
    touch ${target_dir}/$i
    case "$(basename $i)" in
      main.cpp)
        echo "int main(int argc, char ** argv) {}" >> ${target_dir}/$i
        ;;
      dummy_test.cpp)
        echo "#include <criterion/criterion.h>" >> ${target_dir}/$i
        echo "Test(misc, pi) { cr_assert(fabs(M_PI -3.141) < 0.01); }" >> ${target_dir}/$i
        ;;
      *)
        ;;
    esac
  done
}

print_targets() {
  target_dir=$1
  shift
  echo
  echo ================================================================================
  echo $*
  echo ================================================================================
  find ${target_dir} -mindepth 1 -maxdepth 1 -type d | sed s:^.*/::
  echo ================================================================================
  echo
}

main $*
