---
layout: post
title: "A minimal CMake project template"
categories: blog
excerpt: 
tags: [cmake]
date: 2020-05-12
---

I had grew tired of slowly constructing a Franken-`makefile` for each of my C++ projects and their dependencies for each machine that I use. 
There were many of them, each messy, bug-prone, and full of machine-dependent conditionals.
I eventually got fed up and decided to take the plunge into converting my active projects to CMake. 
I figured that I could get a baseline `CMakeLists.txt` working quickly in order to try to develop with CMake while I slowly added all the fancy bells and whistles I had heard so much about.

Unfortunately, I was sadly mistaken. 
The learning curve was steep, *very* steep.
It seemed that the more that I read about CMake, the more confused I became.
Even worse, it became apparent that the "bells and whistles" are actually required to get a project up and running.
My Franken-`makefile` began to look very appealing again.

## Success...?
After many days of reading documentation, debugging, and frustration, I was able to produce [this project template](https://github.com/mmorse1217/cmake-project-template) that is able to do 90% of the things I want:

* Compile source code into a static library
* Link the source code into an executable
* Handle unit testing
* Import third party libraries *and their dependencies* transitively
* Export the static library *and its dependencies* transitively

By "transitive," I mean that if I import `LibA` in my project, and `LibB` is a dependency of `LibA`, then `LibB` will be automatically included in my project as well. 
This is enough for my purposes for the moment, but it is somewhat fragile; I'll discuss this a bit at the end of the post.

Throughout this process, I was having a hard time finding a complete working example with inline comments and reading the documentation was like drinking from a firehose.
To make matters worse, CMake requires several files to be written by hand, which can be confusing to a newcomer. 
Even when I found a solution, I often found myself asking the question: "ok, but where should this code actually *go*?"



* I wrote an explicit project template to be used as a base project for future C++ projects.
* Post the whole file with comments inline
* Discuss project tree
* Begin with the easy files: src/CMakeLists.txt, include/CMakeLists.txt tests/CMakeLists.txt
* Example usage to compile the library and run the tests.
* Write a hypothetical `CMakeLists.txt` that would compile and run the project

* If this is a small personal project, maybe this is all you need.
* If not: How to export the project to others
* talk about `cmake/` files and the real root `CMakeLists.txt`

* Limitations:
* breaks for dependencies outside `/usr/local`
* Some closing thoughts
* large CMake projects need an aggressive amount of code
* Handling external dependencies is much worse than with make
* *find_package* is evil: why should I write hundreds of lines of code to find a dependency?
* The other solutions seem to be: 
1. put all dependencies in your source tree
2. convert all dependencies to CMake and include CMakeLists.txt files
3. convert all dependencies to CMake and write find modules for each one

