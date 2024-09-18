# Generic CMake template.

This repository represents a generic CMake template for CPP and C programs and libraries.

## Programs

To build programs, create a subfolder in the `./src/programs/` folder. The name of this subfolder represents the executable name.

All h files in the `include` subfolder and all `c` and `cpp` files in the program folder are added as project dependencies and are watched for changes.

## Libraries

To build libraries, create a subfolder in the `/src/llibraries/` folder. The name of this subfolder represents the library name.

All h files in the `include` subfolder and all `c` and `cpp` files in the program folder are added as project dependencies and are watched for changes.

## Dependency management

To manage dependencies in the program and library folders, you have to create a deps.txt file can be created. The dependencies should be added line by line.

If a line matches the exact name of a library within the same project, this library is used as dependency and include path is added. Otherwise, the CMake capability is used to find the library within your system and is added as an external dependency.

## Tests

This template also supports testing. At the moment, there are to type of supported tests.

### Criterion

If you create a subfolder in `tests/criterion/` the files in there are build to a criterion test. These tests are automatically linked to the `libCriterion` library, which must be existent in your system. Dependency handling is done in the same way as it is done for regular programs and libraries.

### IO-Tests.  

You can create subfolders in `/tests/io_tests/`. These subfolders must match the name of a program you have created within the project. The tests fail, if the program is not yet build. You can implement multiple IO-Tests for a single executable, by adding `<xx>.in`, `<xx>.out` and `<xx>.err` files (`<xx>` is the matching test number, e.g. 01). If the program is implemented, every `<xx>.in` file is applied to the program as stdin and the created stdout of the program is matched with the `<xx>.out` file, as the created stderr is matched with the `<xx>.err`. The tests fail if the outputs don't match the requirements. 

### Devcontainer

A devcontainer configuration is provided to use this template from within github codespaces. An Ubuntu container was chosen, in which gcc/gdb/cmake and libcriterion (for testing) was added.

__TODO__:  
  This codespace will still ask you to choose a compiler kit, even if there is only one.
  
  The cmake extension is buggy and showing a configuration moved warning message every time a container starts. 
            

