---
layout: post
title: "A dependency-free VTK writer"
categories: blog
excerpt: For saving 2D and 3D data without installing VTK 
tags: [software,c++,vtk,paraview]
date: 2020-09-04
---

[VTK](https://vtk.org/) is a graphics library for rendering scientific data in various formats with particularly nice support for parallel processing.
It's built on OpenGL and pretty comprehensive, with many different data formats, rendering options, and image processing algorithms.
## I just want to use Paraview...
I generally don't need most of the features of VTK inside my C++ project. 
I just want to run a simulation and visualize the output in a dynamic fashion using [Paraview](https://www.paraview.org/), which is a GUI wrapped around VTK. 
Unfortunately, it seems that the whole VTK library needs to be linked into the project in order to write VTK files.

After compiling and installing the library, the supported way to achieve this is via CMake, as described on the package's [wiki page](https://vtk.org/Wiki/VTK/Tutorials/CMakeListsFile):
```cmake
cmake_minimum_required(VERSION 2.6)
project(Test)
set(VTK_DIR "PATH/TO/VTK/BUILD/DIRECTORY")
find_package(VTK REQUIRED)
include(${VTK_USE_FILE})
add_executable(Test Test.cxx)
target_link_libraries(Test ${VTK_LIBRARIES})
```
But this has a few downsides:
1. It links all the VTK libraries by default, which seems to be about 110 or so in version 7.1.0. I'm not aware of an option to only use particular library components without naming them explicitly. 
This causes the linking time of one of my project to inflate from less than one second to around five seconds, which is mildly annoying but survivable.
2. You are a second-class citizen if you aren't using CMake. 
It is simple to link against VTK if you are already using CMake. 
If not, buckle up: there's not much official documentation for this case. 
You will be greeted with the advice to "convert your project to CMake." 
If you don't take this advice, you need to discover which of the 110 libraries you need to explicitly link against, depending on which parts of the project you are using. 
The best part is that these libraries aren't immediately obvious to a typical user and they could change with different version of VTK. 
There isn't an obvious approach to handle this possibility ( see [this stackoverflow post](https://stackoverflow.com/a/43162402/3479119) for a fix for this).
3. Adding VTK to a project adds a lot of complexity just to use one function. I shouldn't have to change build systems or sift through CMake build files to link against just to write a VTK file.

## A standalone VTK writer
To solve these problems, people tend to implement their own basic VTK writers for their [personal](https://github.com/cburstedde/p4est/blob/f73f9431af466e999e7a4d3ce1003444cb3f75f8/src/p4est_vtk.c#L301) [needs](https://github.com/dmalhotra/pvfmm/blob/67595dd1a1ebcfb5c8079c960910bd72e637aedf/include/mpi_tree.txx#L2124).
The result is usually building up the file contents by hand.
[Teseo Schneider](https://cs.nyu.edu/~teseo/) mentioned that he had written a basic VTK writer for [polyfem](https://github.com/polyfem/polyfem/blob/3f58d84cd0ad930b71e8c6db917fe46e8dd4e100/src/mesh/VTUWriter.cpp). 
It seemed pretty modular, so I refactored it a bit to only depend on `std::vector`'s to pass around data and added more common primitives. 
The result is available [here](https://github.com/mmorse1217/lean-vtk). 
Currently, the library supports writing the following data types to `.vtu` files:
- point clouds
- triangle and quad volumetric meshes in 2D
- triangle and quad surface meshes in 3D
- hex and tet volumetric meshes in 3D

Each of these primitives can be saved with scalar and 3D vector data at each point. 
This covers most of the cases that I have needed from VTK in the past few years, so it should be a good starting point. 

It's fairly straightforward to use:

```cpp
vector<double> points = {
		 1.,  1., -1.,
		 1., -1., 1.,
		-1., -1., 0.
	};
vector<int> elements = { 0, 1, 2 };
vector<double> scalar_field = { 0., 1., 2.  };
vector<double> vector_field = points; # just a  silly test

const int dim = 3;
const int cell_size = 3;
std::string filename = "single_tri.vtu";
VTUWriter writer;

writer.add_scalar_field("scalar_field", scalar_field);
writer.add_vector_field("vector_field", vector_field, dim);

writer.write_surface_mesh(filename, dim, cell_size, points, elements);
```

But most importantly, it's easy to add to a project: simply copy `include/lean_vtk.hpp` and `src/lean_vtk.cpp` into the project and add appropriate includes to source files.

I may add support for reading VTK files into `std::vector`'s, but this isn't a priority for my personal use cases at the moment.
