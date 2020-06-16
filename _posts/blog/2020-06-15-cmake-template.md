---
layout: post
title: "A minimal CMake project template"
categories: blog
excerpt: "An attempt to understand what all the hype is about..."
tags: [cmake]
date: 2020-06-15
---

I grew tired of slowly constructing a Franken-Makefile for each of my C++ projects and their dependencies for each machine that I use. 
Each one was messy, bug-prone, and full of machine- and OS-dependent conditionals.
I eventually got fed up and decided to convert my active projects to CMake. 
I (naively) figured that I could get a baseline `CMakeLists.txt` working quickly in order to continue working on projects as I slowly added all the fancy CMake bells and whistles that I had heard so much about.

Unfortunately, I was sadly mistaken. 
The learning curve was *very* steep.
It seemed that the more that I read about CMake, the more confused I became.
Even worse, it became apparent that the "bells and whistles" are actually strictly required to get a project up and running.
My Franken-Makefile was starting to look very appealing again.

## Success...?
After many days of reading documentation, debugging, and frustration, I was able to make [this project template](https://github.com/mmorse1217/cmake-project-template) that is able to do 90% of the things I want:

* Compile source code into a static library
* Link the source code into an executable
* Handle unit testing
* Import third party libraries *and their dependencies* transitively
* Export the static library *and its dependencies* transitively

By "transitive," I mean that if I import `LibA` in my project, and `LibB` is a dependency of `LibA`, then `LibB` will be automatically included in my project as well. 
This is enough for my purposes in my workflow for the moment. 

Throughout this process, I had a hard time finding a complete working example with inline comments.
CMake requires several files in several places to be written by hand, which can be confusing coming from Makefiles.
Meanwhile, reading the official documentation was like drinking from a firehose.
Even when I found a solution, I often found myself asking the question: "ok, but where should this code actually *go*?"

I'm going to review [my sample project](https://github.com/mmorse1217/cmake-project-template) one file at a time, comments and all, with some added commentary between files as needed.
This somewhat long, and may make some people's eyes glaze over, but I think that adding the text right next to the CMake code as comments helps to follow what is happening.
To kick things off, the project structure looks like this:
```bash
    ├── CMakeLists.txt
    ├── LICENSE
    ├── README.md
    ├── cmake
    │   ├── CMakeDemo-config.cmake
    │   └── FindCMakeDemo.cmake
    ├── include
    │   ├── CMakeLists.txt
    │   └── source_file.hpp
    ├── src
    │   ├── CMakeLists.txt
    │   └── source_file.cpp
    └── tests
        ├── CMakeLists.txt
        ├── catch.hpp
        └── test_cmake_demo.cpp
```

We will start at the lower levels of the project, `src/`, `include/` and `tests/`, then discuss the root-level `CMakeLists.txt`, then `cmake/`.

#### Source and include files: `src/CMakeLists.txt` and `include/CMakeLists.txt`
The files `src/CMakeLists.txt` and `include/CMakeLists.txt` are extremely simple and nearly identical. 
Here is `src/CMakeLists.txt`:
```cmake
# Make an explicit list of all source files in `CMakeDemo_SRC`. This is important
# because CMake is not a build system: it is a build system generator. Suppose
# you add a file foo.cpp to src/ after running "cmake ..". If you set
# `CMakeDemo_SRC` with `file(GLOB ... )`, this change is not passed to the makefile;
# the makefile doesn't know that foo.cpp exists and will not re-run cmake. Your
# collaborator's builds will fail and it will be unclear why. Whether you use
# file(GLOB ...) or not, you will need to re-run cmake, but with an explicit
# file list, you know beforehand why your code isn't compiling. 
set(CMakeDemo_SRC
    source_file.cpp
)

# Form the full path to the source files...
PREPEND(CMakeDemo_SRC)
# ... and pass the variable to the parent scope.
set(CMakeDemo_SRC ${CMakeDemo_SRC}  PARENT_SCOPE)
```

This simply makes a list of files that is visible in the "parent scope," i.e., from within the `CMakeLists.txt` that contains `add_subdirectory(src)`. 
The `PREPEND` function just adds the full path to the beginning of each file.
This is used to tell CMake what files are associated with a certain *target*.
A target is an executable or a library; each target has a list of *properties*.
This is the core operation in CMake: associating targets with properties.

#### Testing code: `tests/CMakeLists.txt` 
The file `tests/CMakeLists.txt` is very similar to `src/CMakeLists.txt`, but also contains our first target definition: `TestCMakeDemo`.
This is where having a list of source and header files comes in handy:
```cmake
cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 11)

# Explicitly list the test source code and headers. The Catch header-only unit
# test framework is stored in with the test source.
set(CMakeDemo_TEST_SRC
    test_cmake_demo.cpp
)
set(CMakeDemo_TEST_HEADER
    catch.hpp
)

PREPEND(CMakeDemo_TEST_SRC)

# Make an executable target that depends on the test source code we specified
# above.
add_executable(TestCMakeDemo ${CMakeDemo_TEST_SRC} ${CMakeDemo_TEST_HEADER})

# Enable testing via CTest
enable_testing()
# Add our test as runnable via CTest
add_test(NAME TestCMakeDemo  COMMAND TestCMakeDemo)

# Link our unit tests against the library we compiled
target_link_libraries(TestCMakeDemo CMakeDemo)
```

There are a couple other things happening here. The `enable_testing()` and `add_test()` calls are related to CTest, which is how CMake runs unit tests.
After building our CMake targets, we can run all registered unit tests with the command `ctest`.
This can be helpful if tests live in multiple directories or spread across multiple files.
`enable_testing()` tells CMake to allow for unit testing via CTest after building all targets.
The `add_test` call registers our test target, `TestCMakeDemo`, with CTest. 

#### Project compilation: `CMakeLists.txt`
The biggest file is the root-level `CMakeLists.txt`:
```cmake
# It's important to specify the minimum CMake version upfront required by
# CMakeLists.txt. This is so that a user can clearly understand the reason the 
# build will fail before the build actually occurs, instead of searching for the
# CMake function that was used that is causing the failure.
cmake_minimum_required(VERSION 3.1)

# Set the global package-wide C++ standard. This will be inherited by all
# targets specified in the project. One can also specify the C++ standard in a
# target-specific manner, using:
#   set_target_properties(foo PROPERTIES CXX_STANDARD 11)
# for a target foo
set(CMAKE_CXX_STANDARD 11)

# Set the project name and version number. This allows for a user of your
# library or tool to specify a particular version when they include it, as in 
#   find_package(CMakeDemo 1.0 REQUIRED)
project(CMakeDemo VERSION 1.0)
set(CMakeDemo_VERSION 1.0)

# enable unit testing via "make test" once the code has been compiled.
include(CTest)

# Function to prepend the subdirectory to source files in subdirectories
function(PREPEND var )
   set(listVar "")
   foreach(f ${${var}})
       list(APPEND listVar "${CMAKE_CURRENT_SOURCE_DIR}/${f}")
   endforeach(f)
   set(${var} "${listVar}" PARENT_SCOPE)
endfunction(PREPEND)

# After a normal build, we can specify the location of various outputs of the
# build. We put executables and static libraries outside the build directory in
# bin/ and lib/, respectively.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib")

# Find LAPACK on the system. This is mostly for demonstration.
find_package(LAPACK REQUIRED)

# Include source code and headers. This runs the CMakeLists.txt in each
# subdirectory. These can define their own libraries, executables, etc. as targets, 
# but here we define all exportable targets in the root CMakeLists.txt.
add_subdirectory(src)
add_subdirectory(include)

# Add the test directory. It is optional and can be disabled during with
#   cmake -DBUILD_TESTING=OFF ..
# To run unit tests produced here, we only need to run:
#   make test
# or
#   ctest 
# In case your tests are printing to console, you can view their output to
# stdout with:
#   ctest -V

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

# Add the library CMakeDemo as a target, with the contents of src/ and include/
# as dependencies.
add_library(CMakeDemo STATIC ${CMakeDemo_SRC} ${CMakeDemo_INC})

# These variables slightly modify the install location to allow for version
# specific installations.
set(CMakeDemo_INCLUDE_DEST "include/CMakeDemo-${CMakeDemo_VERSION}")
set(CMakeDemo_LIB_DEST "lib/CMakeDemo-${CMakeDemo_VERSION}")


# generator expressions are needed for the include directories, since installing 
# headers changes the include path.
# Specify that CMakeDemo requires the files located in the include/ directory at
# compile time. This would normally look like 
#   target_include_directories(CMakeDemo PUBLIC include/)
# PUBLIC means that other libraries including CMakeDemo should also include the
# directory include/.
# However, there is a catch. If we are installing the project in
# CMAKE_INSTALL_PREFIX, we can't specify include/ in the build directory: we have 
# copied the contents of include to CMAKE_INSTALL_PREFIX/include and we would
# like  other projects to include this directory instead of include/. The following
# CMake command handles this. $<BUILD_INTERFACE:...> and
# $<INSTALL_INTERFACE:...> are macros whose values change depending on if we are
# simply building the code or if we are installing it.
target_include_directories(CMakeDemo PUBLIC
   # headers to include when building from source
   $<BUILD_INTERFACE:${CMakeDemo_SOURCE_DIR}/include> 
   $<BUILD_INTERFACE:${CMakeDemo_BINARY_DIR}/include> 

   # headers to include when installing  
   # (implicitly prefixes with ${CMAKE_INSTALL_PREFIX}).
   $<INSTALL_INTERFACE:include> 
   )

# Specify that CMakeDemo requires LAPACK to link properly. Ideally, LAPACK would
# specify LAPACK::LAPACK for linking so that we can avoid using the variables.
# However, each package is different and one must check the documentation to 
# see what variables are defined.
target_link_libraries(CMakeDemo ${LAPACK_LIBRARIES})

# Install CMakeDemo in CMAKE_INSTALL_PREFIX (defaults to /usr/local on linux). 
# To change the install location, run 
#   cmake -DCMAKE_INSTALL_PREFIX=<desired-install-path> ..

# install(...) specifies installation rules for the project. It can specify
# location of installed files on the system, user permissions, build
# configurations, etc. Here, we are only copying files.
# install(TARGETS ...) specifies rules for installing targets. 
# Here, we are taking a target or list of targets (CMakeDemo) and telling CMake
# the following:
#   - put shared libraries associated with CMakeDemo in ${CMakeDemo_LIB_DEST}
#   - put static libraries associated with CMakeDemo in ${CMakeDemo_LIB_DEST}
#   - put include files associated with CMakeDemo in ${CMakeDemo_INCLUDE_DEST}
# We also need to specify the export that is associated with CMakeDemo; an export 
# is just a list of targets to be installed.
# So we are associating CMakeDemo with CMakeDemoTargets.
install(
    # targets to install
    TARGETS CMakeDemo 
    # name of the CMake "export group" containing the targets we want to install
    EXPORT CMakeDemoTargets
    # Dynamic, static library and include destination locations after running
    # "make install"
    LIBRARY DESTINATION ${CMakeDemo_LIB_DEST}
    ARCHIVE DESTINATION ${CMakeDemo_LIB_DEST} 
    INCLUDES DESTINATION ${CMakeDemo_INCLUDE_DEST}
    )

# We now need to install the export CMakeDemoTargets that we defined above. This
# is needed in order for another project to import CMakeDemo using 
#   find_package(CMakeDemo)
# find_package(CMakeDemo) will look for CMakeDemo-config.cmake to provide
# information about the targets contained in the project CMakeDemo. Fortunately,
# this is specified in the export CMakeDemoTargets, so we will install this too.
# install(EXPORT ...) will install the information about an export. Here, we
# save it to a file {$CMakeDemo_LIB_DEST}/CMakeDemoTargets.cmake and prepend 
# everything inside CMakeDemoTargets  with the namespace CMakeDemo::.
install(
    # The export we want to save (matches name defined above containing the
    # install targets)
    EXPORT CMakeDemoTargets
    # CMake file in which to store the export's information
    FILE  CMakeDemoTargets.cmake
    # Namespace prepends all targets in the export (when we import later, we
    # will use CMakeDemo::CMakeDemo)
    NAMESPACE CMakeDemo::
    # where to place the resulting file (here, we're putting it with the library)
    DESTINATION ${CMakeDemo_LIB_DEST}
    )

# install(FILES ...) simply puts files in a certain place with certain
# properties. We're just copying include files to the desired include directory
# here.
install(FILES ${CMakeDemo_INC} DESTINATION ${CMakeDemo_INCLUDE_DEST})

# Write a "version file" in case someone wants to only load a particular version of
# CMakeDemo 
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    CMakeDemoConfigVersion.cmake
    VERSION ${CMakeDemo_VERSION}
    COMPATIBILITY AnyNewerVersion
    )

# Copies the resulting CMake config files to the installed library directory
install(
    FILES 
        "cmake/CMakeDemo-config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/CMakeDemoConfigVersion.cmake"
    DESTINATION ${CMakeDemo_LIB_DEST}
    )
```
An important note: in the above code, everything after 
```cmake
add_library(CMakeDemo STATIC ${CMakeDemo_SRC} ${CMakeDemo_INC})
```
is needed for installing the project in `/usr/local/`, *except for the `target_include_directories()` call*. 
If you only need to compile your code and don't care about installation, you can remove these lines without a problem, provided that the `target_include_directories()` is replaced with the simpler call mentioned in the comments.

#### Specify dependencies: `cmake/CMakeDemo-config.cmake`
The contents of `cmake/CMakeDemo-config.cmake` are fairly straightforward.
The purpose of the file is to indicate the dependencies of the project and describe how to configure them within CMake. 
```cmake
#get_filename_component(SELF_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

include(CMakeFindDependencyMacro)
# Capturing values from configure (optional)
#set(my-config-var @my-config-var@)

# Same syntax as find_package
find_dependency(LAPACK REQUIRED)

# Any extra setup

# Add the targets file. include() just loads and executes the CMake code in the
# file passed to it. Note that the file loaded here is the same one generated in
# the second install() command in the root-level CMakeLists.txt
include("${CMAKE_CURRENT_LIST_DIR}/CMakeDemoTargets.cmake")
```

#### Find module: `cmake/FindCMakeDemo.cmake`
The final file in the project is `cmake/FindCMakeDemo.cmake`. 
This file is used by projects that want to import the `CMakeDemo` project as an external library.
It is what allows other projects to add your library as a dependency without any explicit reference to explicit path, like this:
```cmake
find_package(CMakeDemo REQUIRED)
target_link_libraries(target CMakeDemo)
```
Without a file called `cmake/FindCMakeDemo.cmake` present in your project, the build will fail and tell you that `CMakeDemo` hasn't been properly initialized.
The file is split into two parts:
the first part finds the library and include files on your system, according to some prescribed rule;
the second part populates and exports the CMake targets for users to include.

```cmake
# - Try to find the CMakeDemo library
# Once done this will define
#
#  CMakeDemo_FOUND - system has CMakeDemo
#  CMakeDemo_INCLUDE_DIR - CMakeDemo include directory
#  CMakeDemo_LIB - CMakeDemo library directory
#  CMakeDemo_LIBRARIES - CMakeDemo libraries to link

if(CMakeDemo_FOUND)
    return()
endif()

# We prioritize libraries installed in /usr/local with the prefix .../CMakeDemo-*, 
# so we make a list of them here
file(GLOB lib_glob "/usr/local/lib/CMakeDemo-*")
file(GLOB inc_glob "/usr/local/include/CMakeDemo-*")

# Find the library with the name "CMakeDemo" on the system. Store the final path
# in the variable CMakeDemo_LIB
find_library(CMakeDemo_LIB 
    # The library is named "CMakeDemo", but can have various library forms, like
    # libCMakeDemo.a, libCMakeDemo.so, libCMakeDemo.so.1.x, etc. This should
    # search for any of these.
    NAMES CMakeDemo
    # Provide a list of places to look based on prior knowledge about the system.
    # We want the user to override /usr/local with environment variables, so
    # this is included here.
    HINTS
        ${CMakeDemo_DIR}
        ${CMAKEDEMO_DIR}
        $ENV{CMakeDemo_DIR}
        $ENV{CMAKEDEMO_DIR}
        ENV CMAKEDEMO_DIR
    # Provide a list of places to look as defaults. /usr/local shows up because
    # that's the default install location for most libs. The globbed paths also
    # are placed here as well.
    PATHS
        /usr
        /usr/local
        /usr/local/lib
        ${lib_glob}
    # Constrain the end of the full path to the detected library, not including
    # the name of library itself.
    PATH_SUFFIXES 
        lib
)

# Find the path to the file "source_file.hpp" on the system. Store the final
# path in the variables CMakeDemo_INCLUDE_DIR. The HINTS, PATHS, and
# PATH_SUFFIXES, arguments have the same meaning as in find_library().
find_path(CMakeDemo_INCLUDE_DIR source_file.hpp
    HINTS
        ${CMakeDemo_DIR}
        ${CMAKEDEMO_DIR}
        $ENV{CMakeDemo_DIR}
        $ENV{CMAKEDEMO_DIR}
        ENV CMAKEDEMO_DIR
    PATHS
        /usr
        /usr/local
        /usr/local/include
        ${inc_glob}
    PATH_SUFFIXES 
        include
)


# Check that both the paths to the include and library directory were found.
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMakeDemo
    "\nCMakeDemo not found --- You can download it using:\n\tgit clone 
    https://github.com/mmorse1217/cmake-project-template\n and setting the 
    CMAKEDEMO_DIR environment variable accordingly"
    CMakeDemo_LIB CMakeDemo_INCLUDE_DIR)

# These variables don't show up in the GUI version of CMake. Not required but
# people seem to do this...
mark_as_advanced(CMakeDemo_INCLUDE_DIR CMakeDemo_LIB)

# Finish defining the variables specified above. Variables names here follow
# CMake convention.
set(CMakeDemo_INCLUDE_DIRS ${CMakeDemo_INCLUDE_DIR})
set(CMakeDemo_LIBRARIES ${CMakeDemo_LIB})

# If the above CMake code was successful and we found the library, and there is
# no target defined, lets make one.
if(CMakeDemo_FOUND AND NOT TARGET CMakeDemo::CMakeDemo)
    add_library(CMakeDemo::CMakeDemo UNKNOWN IMPORTED)
    # Set location of interface include directory, i.e., the directory
    # containing the header files for the installed library
    set_target_properties(CMakeDemo::CMakeDemo PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMakeDemo_INCLUDE_DIRS}"
        )

    # Set location of the installed library
    set_target_properties(CMakeDemo::CMakeDemo PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        IMPORTED_LOCATION "${CMakeDemo_LIBRARIES}"
        )
endif()
```

## Putting it all together

To compile the project with CMake, we prefer *out-of-source* builds, which
seperate the source code and the compiled object files. We make a seperate build
directory and the compile the code there:

```bash
mkdir build
cd build
cmake ..
make 
```

This will compile all targets specified in the project. To install our compiled
targets in `/usr/local`, we run 
```bash
make install
```
from within the `build` directory.
To run unit tests, we can run
```bash
make test
```
or 
```bash
ctest
```
again from within the `build` directory.

## Some closing thoughts
My time learning the ropes of CMake has been somewhat of a wild ride.
Since I'm fairly new to it, I think I don't appreciate the power of it yet.
My biggest problem with Makefiles is the different conditionals for different
operating systems, setting certain flags for different compilers, etc.
It does address the compiler flag issue between `icc`, `gcc`, and `clang`.
However, if your find-module requires several conditionals in order to handle
different operating system, is it really platform independent?

A big problem that I had with Makefiles was simple dependency mistakes.
In the past, I have written Makefiles (accidentally) that seem to work at first, but ultimately don't properly trigger recompilation in certain files when their 
dependencies change, which wastes a lot of time. 
Moreover, parallel compilation is [inherently
bottlenecked](https://www.cmcrossroads.com/article/pitfalls-and-benefits-gnu-make-parallelization) by how well you
express your dependencies in `make`-speak. 
CMake seems to solved this issue, at least for my projects; my compilation times have definitely improved.

In terms of final opinions, it seems that people on the Internet have intense feelings
about CMake. 
I am pretty indifferent about it.
It solves some problems, but seems to create about as many problems as it
solves. 
This [article](https://izzys.casa/2019/02/everything-you-never-wanted-to-know-about-cmake/) describes some of the induced insanity nicely.

Finally, here's some links that came in handy in my travels:
* [C++Now 2017: Daniel Pfeifer “Effective CMake"](https://youtu.be/bsXLMQ6WgIk)
    (also
    [here](https://github.com/boostcon/cppnow_presentations_2017/blob/master/05-19-2017_friday/effective_cmake__daniel_pfeifer__cppnow_05-19-2017.pdf)
    are the slides themselves)
* [foonathan::blog(): Tutorial: Easily supporting CMake install and find_package()](https://foonathan.net/2016/03/cmake-install/)
* [Effective Modern CMake](https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1)
* [CMake Documentation: Exporting and Importing Targets](https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets)
* [An Introduction to Modern CMake](https://cliutils.gitlab.io/modern-cmake/)
