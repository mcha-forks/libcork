# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------
# Copyright © 2015, libcork authors
# Please see the COPYING file in this distribution for license details.
# ----------------------------------------------------------------------


#-----------------------------------------------------------------------
# Configuration options that control all of the below

set(ENABLE_SHARED NO CACHE BOOL "Whether to build a shared library")
set(ENABLE_SHARED_EXECUTABLES NO CACHE BOOL
    "Whether to link executables using shared libraries")
set(ENABLE_STATIC YES CACHE BOOL "Whether to build a static library")


#-----------------------------------------------------------------------
# Library, with options to build both shared and static versions

function(target_add_shared_libraries TARGET_NAME LIBRARIES LOCAL_LIBRARIES)
    foreach(lib ${LIBRARIES})
        string(REPLACE "-" "_" lib ${lib})
        string(TOUPPER ${lib} upperlib)
        target_link_libraries(
            ${TARGET_NAME}
            ${${upperlib}_LDFLAGS}
        )
    endforeach(lib)
    foreach(lib ${LOCAL_LIBRARIES})
        target_link_libraries(${TARGET_NAME} ${lib}-shared)
    endforeach(lib)
endfunction(target_add_shared_libraries)

function(target_add_static_libraries TARGET_NAME LIBRARIES LOCAL_LIBRARIES)
    foreach(lib ${LIBRARIES})
        string(REPLACE "-" "_" lib ${lib})
        string(TOUPPER ${lib} upperlib)
        target_link_libraries(
            ${TARGET_NAME}
            ${${upperlib}_STATIC_LDFLAGS}
        )
    endforeach(lib)
    foreach(lib ${LOCAL_LIBRARIES})
        target_link_libraries(${TARGET_NAME} ${lib}-static)
    endforeach(lib)
endfunction(target_add_static_libraries)

set_property(GLOBAL PROPERTY ALL_LOCAL_LIBRARIES "")

function(add_c_library __TARGET_NAME)
    set(options)
    set(one_args OUTPUT_NAME PKGCONFIG_NAME VERSION_INFO)
    set(multi_args LIBRARIES LOCAL_LIBRARIES SOURCES)
    cmake_parse_arguments(_ "${options}" "${one_args}" "${multi_args}" ${ARGN})

    if (__VERSION_INFO MATCHES "^([0-9]+):([0-9]+):([0-9]+)(-dev)?$")
        set(__VERSION_CURRENT  "${CMAKE_MATCH_1}")
        set(__VERSION_REVISION "${CMAKE_MATCH_2}")
        set(__VERSION_AGE      "${CMAKE_MATCH_3}")
    else (__VERSION_INFO MATCHES "^([0-9]+):([0-9]+):([0-9]+)(-dev)?$")
        message(FATAL_ERROR "Invalid library version info: ${__VERSION_INFO}")
    endif (__VERSION_INFO MATCHES "^([0-9]+):([0-9]+):([0-9]+)(-dev)?$")

    # Mimic libtool's behavior in calculating SONAME and VERSION from
    # version-info.
    # http://git.savannah.gnu.org/cgit/libtool.git/tree/build-aux/ltmain.in?id=722b6af0fad19b3d9f21924ae5aa6dfae5957378#n7042
    math(EXPR __SOVERSION "${__VERSION_CURRENT} - ${__VERSION_AGE}")
    set(__VERSION "${__SOVERSION}.${__VERSION_AGE}.${__VERSION_REVISION}")

    get_property(ALL_LOCAL_LIBRARIES GLOBAL PROPERTY ALL_LOCAL_LIBRARIES)
    list(APPEND ALL_LOCAL_LIBRARIES ${__TARGET_NAME})
    set_property(GLOBAL PROPERTY ALL_LOCAL_LIBRARIES "${ALL_LOCAL_LIBRARIES}")

    if (ENABLE_SHARED OR ENABLE_SHARED_EXECUTABLES)
        add_library(${__TARGET_NAME}-shared SHARED ${__SOURCES})
        set_target_properties(
            ${__TARGET_NAME}-shared PROPERTIES
            OUTPUT_NAME ${__OUTPUT_NAME}
            CLEAN_DIRECT_OUTPUT 1
            VERSION ${__VERSION}
            SOVERSION ${__SOVERSION}
        )

        if (CMAKE_VERSION VERSION_GREATER "2.8.11")
            target_include_directories(
                ${__TARGET_NAME}-shared PUBLIC
                ${CMAKE_SOURCE_DIR}/include
                ${CMAKE_BINARY_DIR}/include
            )
        else (CMAKE_VERSION VERSION_GREATER "2.8.11")
            include_directories(
                ${CMAKE_SOURCE_DIR}/include
                ${CMAKE_BINARY_DIR}/include
            )
        endif (CMAKE_VERSION VERSION_GREATER "2.8.11")

        target_add_shared_libraries(
            ${__TARGET_NAME}-shared
            "${__LIBRARIES}"
            "${__LOCAL_LIBRARIES}"
        )

        # We have to install the shared library if the user asked us to, or if
        # the user asked us to link our programs with the shared library.
        install(TARGETS ${__TARGET_NAME}-shared
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
    endif (ENABLE_SHARED OR ENABLE_SHARED_EXECUTABLES)

    if (ENABLE_STATIC OR NOT ENABLE_SHARED_EXECUTABLES)
        add_library(${__TARGET_NAME}-static STATIC ${__SOURCES})
        set_target_properties(
            ${__TARGET_NAME}-static PROPERTIES
            OUTPUT_NAME ${__OUTPUT_NAME}
            CLEAN_DIRECT_OUTPUT 1
        )

        if (CMAKE_VERSION VERSION_GREATER "2.8.11")
            target_include_directories(
                ${__TARGET_NAME}-static PUBLIC
                ${CMAKE_SOURCE_DIR}/include
                ${CMAKE_BINARY_DIR}/include
            )
        else (CMAKE_VERSION VERSION_GREATER "2.8.11")
            include_directories(
                ${CMAKE_SOURCE_DIR}/include
                ${CMAKE_BINARY_DIR}/include
            )
        endif (CMAKE_VERSION VERSION_GREATER "2.8.11")

        target_add_static_libraries(
            ${__TARGET_NAME}-static
            "${__LIBRARIES}"
            "${__LOCAL_LIBRARIES}"
        )
    endif (ENABLE_STATIC OR NOT ENABLE_SHARED_EXECUTABLES)

    if (ENABLE_STATIC)
        # We DON'T have to install the static library if the user asked us to
        # link our programs statically.
        install(TARGETS ${__TARGET_NAME}-static
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
    endif (ENABLE_STATIC)

    set(PACKAGE_TARNAME "${PROJECT_NAME}")
    set(prefix ${CMAKE_INSTALL_PREFIX})
    set(exec_prefix "\${prefix}")
    set(datarootdir "\${prefix}/share")
    set(includedir "\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}")
    set(libdir "\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}")
endfunction(add_c_library)
