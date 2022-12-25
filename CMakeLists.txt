# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------
# Copyright © 2011, libcork authors
# Please see the COPYING file in this distribution for license details.
# ----------------------------------------------------------------------

cmake_minimum_required(VERSION 2.6)
set(PROJECT_NAME libcork)
set(RELEASE_DATE 2015-09-03)
project(${PROJECT_NAME})

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
find_package(CTargets)

set(VERSION      "0.15.0-cosmo")
set(CORK_VERSION "0.15.0")

include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE MinSizeRel CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
        FORCE)
endif(NOT CMAKE_BUILD_TYPE)

set(ENABLE_SHARED NO CACHE BOOL "Whether to build a shared library")
set(ENABLE_SHARED_EXECUTABLES NO CACHE BOOL
    "Whether to link executables using shared libraries")
set(ENABLE_SHARED_TESTS NO CACHE BOOL
    "Whether to link test cases using shared libraries")
set(ENABLE_STATIC YES CACHE BOOL "Whether to build a static library")

if(NOT CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR lib CACHE STRING
        "The base name of the installation directory for libraries")
endif(NOT CMAKE_INSTALL_LIBDIR)

add_definitions(-w)

#-----------------------------------------------------------------------
# Check for prerequisite libraries

find_package(Threads)
set(THREADS_LDFLAGS "${CMAKE_THREAD_LIBS_INIT}")
set(THREADS_STATIC_LDFLAGS "${CMAKE_THREAD_LIBS_INIT}")
set(PTHREAD_LIBS "${CMAKE_THREAD_LIBS_INIT}")

#-----------------------------------------------------------------------
# Include our subdirectories

add_subdirectory(include)
add_subdirectory(src)
