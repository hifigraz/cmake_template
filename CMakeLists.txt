CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
PROJECT(cmake_test_template)
INCLUDE(CTest)

# -------------------------------------------------------------------------------- 
# build all project programs located in ./src/programs/<program_name>/*.cpp
# program wide headers are located in ./src/programs/<program_name>/include/
# -------------------------------------------------------------------------------- 

# -------------------------------------------------------------------------------- 
# build all project libraries located in ./src/libraries/<lib_name>/*.cpp
# lib wide headers are located in ./src/libs/<lib_name>/include/
# -------------------------------------------------------------------------------- 

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
SET(CMAKE_CPP_FLAGS "${CMAKE_CPP_FLAGS} -Wall")

FUNCTION(ADD_SINGLE_DEP target_name dependency)
  MESSAGE("Trying ${dependency}/")
  IF(EXISTS "${CMAKE_SOURCE_DIR}/src/libraries/${dependency}")
    MESSAGE("Found internal dependecy")
    MESSAGE("Add dependency for ${target_name} ${dependency}")
    ADD_DEPENDENCIES(${target_name} ${dependency})
    TARGET_LINK_LIBRARIES(${target_name} ${dependency})
    TARGET_INCLUDE_DIRECTORIES(${target_name} PUBLIC ${CMAKE_SOURCE_DIR}/src/libraries/${dependency}/include)
  ELSE()
    MESSAGE("trying to find external dependecy")
    FIND_LIBRARY(external_lib ${dependency} REQUIRED)
    TARGET_LINK_LIBRARIES(${target_name} ${external_lib})
  ENDIF()
ENDFUNCTION()

FUNCTION(ADD_DEPS target_directory)
  IF(EXISTS ${target_directory}/deps.txt)
    GET_FILENAME_COMPONENT(target_name ${target_directory} NAME)
    # ADD_DEPENDENCIES(${target_name} ${target_directory}/deps.txt)
    FILE(READ ${target_directory}/deps.txt dependencies)
    STRING(REPLACE "\n" ";" dependencies ${dependencies})
    FOREACH(dependency ${dependencies})
      MESSAGE("Dependency: ${dependency}")
      ADD_SINGLE_DEP(${target_name} ${dependency})
    ENDFOREACH()
  ENDIF()
ENDFUNCTION()

FILE(GLOB target_types "src/*/")
FOREACH(target_type_dir ${target_types})
  IF(IS_DIRECTORY ${target_type_dir})
    GET_FILENAME_COMPONENT(target_type ${target_type_dir} NAME)
    FILE(GLOB target_directories "${target_type_dir}/*/")
    FOREACH(target_directory ${target_directories})
      IF(IS_DIRECTORY ${target_directory})
        GET_FILENAME_COMPONENT(target_name ${target_directory} NAME)
        MESSAGE("Creating build instructions for ${target_name}")
        FILE(GLOB target_sources "${target_directory}/*.cpp" "${target_directory}/*.c")
        FILE(GLOB target_headers "${target_directory}/include/*.*")
        IF(${target_type} MATCHES libraries)
          ADD_LIBRARY(${target_name} ${target_sources} ${target_headers})
        ELSEIF(${target_type} MATCHES programs)
          ADD_EXECUTABLE(${target_name} ${target_sources} ${target_headers})
        ELSE()
          MESSAGE(FATAL_ERROR "Unknown target type ${target_type}")
        ENDIF()
        SET_PROPERTY(TARGET ${target_name} PROPERTY CXX_STANDARD 17)
        SET_PROPERTY(TARGET ${target_name} PROPERTY C++XX_STANDARD 17)
        TARGET_INCLUDE_DIRECTORIES(${target_name} PRIVATE ${target_directory}/include)
        ADD_DEPS(${target_directory})
      ELSE()
        MESSAGE(FATAL_ERROR "${target_directory} is no directory")
      ENDIF()
    ENDFOREACH()
  ELSE()
    MESSAGE(FATAL_ERROR "${target_type_dir} is no directory")
  ENDIF()
ENDFOREACH()

# --------------------------------------------------------------------------------
# handle all tests.
# --------------------------------------------------------------------------------

FILE(GLOB test_types "tests/*/")
ADD_TEST("Dummy_test" true)
FOREACH(test_type_dir ${test_types})
  IF(IS_DIRECTORY ${test_type_dir})
    GET_FILENAME_COMPONENT(test_type ${test_type_dir} NAME)
    FILE(GLOB test_targets "${test_type_dir}/*/")
    FOREACH(test_target_dir ${test_targets})
      IF(IS_DIRECTORY ${test_target_dir})
        GET_FILENAME_COMPONENT(test_target ${test_target_dir} NAME)
        MESSAGE("----> ${test_target}")
        IF(${test_type} MATCHES io_tests)
          FILE(GLOB in_files "${test_target_dir}/*.in")
          FOREACH(in_file ${in_files})
            GET_FILENAME_COMPONENT(test_number ${in_file} NAME_WLE)
            MESSAGE("TEST NUMBER ${test_number} of ${in_file}")
            ADD_TEST(NAME "${test_target}.${test_number}" COMMAND ${CMAKE_SOURCE_DIR}/buildscripts/test.sh ${CMAKE_BINARY_DIR}/${test_target} ${in_file} ${test_target_dir}/${test_number}.out ${test_target_dir}/${test_number}.err)
          ENDFOREACH()
        ELSEIF(${test_type} MATCHES criterion)
          FIND_LIBRARY(lib_criterion criterion)
          FILE(GLOB criterion_sources ${test_target_dir}/*.cpp)
          ADD_EXECUTABLE(${test_target} EXCLUDE_FROM_ALL ${criterion_sources} )
          TARGET_LINK_LIBRARIES(${test_target} ${lib_criterion})
          ADD_DEPS(${test_target_dir})
          ADD_TEST(NAME ${test_target} COMMAND ${CMAKE_SOURCE_DIR}/buildscripts/criterion.sh ${test_target})
        ELSE()
          MESSAGE(FATAL_ERROR "Error: unknown test type ${test_type}")
        ENDIF()
      ELSE()
        MESSAGE(FATAL_ERROR "${test_target_dir} is no directory")
      ENDIF()
    ENDFOREACH()
  ELSE()
    MESSAGE(FATAL_ERROR "${test_type_dir} is no directory")
  ENDIF()
ENDFOREACH()

# --------------------------------------------------------------------------------
# todos
# --------------------------------------------------------------------------------

# add external dependiencies

