cmake_minimum_required(VERSION 3.20)
project(cmake_test_template)
include(CTest)

# -------------------------------------------------------------------------------- 
# build all project programs located in ./src/programs/<program_name>/*.cpp
# program wide headers are located in ./src/programs/<program_name>/include/
# -------------------------------------------------------------------------------- 

# -------------------------------------------------------------------------------- 
# build all project libraries located in ./src/libraries/<lib_name>/*.cpp
# lib wide headers are located in ./src/libs/<lib_name>/include/
# -------------------------------------------------------------------------------- 

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
set(CMAKE_CPP_FLAGS "${CMAKE_CPP_FLAGS} -Wall")

function(ADD_SINGLE_DEP target_name dependency)
  message("Trying ${dependency}/")
  if(EXISTS "${CMAKE_SOURCE_DIR}/src/libraries/${dependency}")
    message("Found internal dependecy")
    message("Add dependency for ${target_name} ${dependency}")
    add_dependencies(${target_name} ${dependency})
    target_link_libraries(${target_name} ${dependency})
    target_include_directories(${target_name} PUBLIC ${CMAKE_SOURCE_DIR}/src/libraries/${dependency}/include)
  else()
    message("trying to find external dependecy")
    find_library(external_lib ${dependency} REQUIRED)
    target_link_libraries(${target_name} ${external_lib})
  endif()
endfunction()

function(ADD_DEPS target_directory)
  if(EXISTS ${target_directory}/deps.txt)
    get_filename_component(target_name ${target_directory} NAME)
    file(READ ${target_directory}/deps.txt dependencies)
    string(REPLACE "\n" ";" dependencies ${dependencies})
    foreach(dependency ${dependencies})
      message("Dependency: ${dependency}")
      add_single_dep(${target_name} ${dependency})
    endforeach()
  endif()
endfunction()

file(GLOB target_types "src/*/")
foreach(target_type_dir ${target_types})
  if(IS_DIRECTORY ${target_type_dir})
    get_filename_component(target_type ${target_type_dir} NAME)
    file(GLOB target_directories "${target_type_dir}/*/")
    foreach(target_directory ${target_directories})
      get_filename_component(target_name ${target_directory} NAME)
      if(IS_DIRECTORY ${target_directory})
        message("Creating build instructions for ${target_name}")
        file(GLOB target_sources "${target_directory}/*.cpp" "${target_directory}/*.c")
        file(GLOB target_headers "${target_directory}/include/*.*")
        if(${target_type} MATCHES libraries)
          add_library(${target_name} ${target_sources} ${target_headers})
        elseif(${target_type} MATCHES programs)
          add_executable(${target_name} ${target_sources} ${target_headers})
        else()
          message(FATAL_ERROR "Unknown target type ${target_type}")
        endif()
        set_property(TARGET ${target_name} PROPERTY CXX_STANDARD 17)
        set_property(TARGET ${target_name} PROPERTY C++XX_STANDARD 17)
        target_include_directories(${target_name} PRIVATE ${target_directory}/include)
        add_deps(${target_directory})
      else()
        string(COMPARE EQUAL ${target_name} .keep is_keep)
        if(${is_keep})
        else()
          message(FATAL_ERROR "${target_directory} is no directory")
        endif()
      endif()
    endforeach()
  else()
    message(FATAL_ERROR "${target_type_dir} is no directory")
  endif()
endforeach()

# --------------------------------------------------------------------------------
# handle all tests.
# --------------------------------------------------------------------------------

file(GLOB test_types "tests/*/")
add_test("Dummy_test" true)
foreach(test_type_dir ${test_types})
  if(IS_DIRECTORY ${test_type_dir})
    get_filename_component(test_type ${test_type_dir} NAME)
    file(GLOB test_targets "${test_type_dir}/*/")
    foreach(test_target_dir ${test_targets})
      get_filename_component(test_target ${test_target_dir} NAME)
      if(IS_DIRECTORY ${test_target_dir})
        message("----> ${test_target}")
        if(${test_type} MATCHES io_tests)
          file(GLOB in_files "${test_target_dir}/*.in")
          foreach(in_file ${in_files})
            get_filename_component(test_number ${in_file} NAME_WLE)
            message("TEST NUMBER ${test_number} of ${in_file}")
            add_test(NAME "${test_target}.${test_number}" COMMAND ${CMAKE_SOURCE_DIR}/buildscripts/test.sh ${CMAKE_BINARY_DIR}/${test_target} ${in_file} ${test_target_dir}/${test_number}.out ${test_target_dir}/${test_number}.err)
          endforeach()
        elseif(${test_type} MATCHES criterion)
          find_library(lib_criterion criterion)
          file(GLOB criterion_sources ${test_target_dir}/*.cpp ${test_target_dir}/*.c)
          add_executable(${test_target} EXCLUDE_FROM_ALL ${criterion_sources} )
          target_link_libraries(${test_target} ${lib_criterion})
          add_deps(${test_target_dir})
          add_test(NAME ${test_target} COMMAND ${CMAKE_SOURCE_DIR}/buildscripts/criterion.sh ${test_target})
        else()
          message(FATAL_ERROR "Error: unknown test type ${test_type}")
        endif()
      else()
        string(COMPARE EQUAL ${test_target} .keep is_keep)
        if(${is_keep})
        else()
          message(FATAL_ERROR "${test_target_dir} is no directory")
        endif()
      endif()
    endforeach()
  else()
    message(FATAL_ERROR "${test_type_dir} is no directory")
  endif()
endforeach()

# --------------------------------------------------------------------------------
# todos
# --------------------------------------------------------------------------------

# add external dependiencies

