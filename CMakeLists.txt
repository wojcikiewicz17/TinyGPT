cmake_minimum_required(VERSION 3.15)
project(TinyGPT C CXX ASM)

set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)

option(TINYGPT_BUILD_PYBINDING "Whether or not to build pybinding" OFF)
option(TINYGPT_BUILD_DEMO "Whether or not to build demo" ON)
option(TINYGPT_BUILD_TEST "Whether or not to build the tests" ON)
option(TINYGPT_BUILD_RAFAELIA_ADDON "Whether or not to build RafaelIA addon" OFF)
option(TINYGPT_ASM_ONLY "Build only low-level RafaelIA addon (ASM/fallback) and skip TinyGPT core" OFF)
option(TINYGPT_FORCE_ALL_ASM "Generate and build ASM stubs for all C/C++/Python units in repository" OFF)
option(TINYGPT_AUTO_FETCH_DEPS "Auto-fetch missing git dependencies during CMake configure" ON)

if (TINYGPT_FORCE_ALL_ASM)
    find_package(Python3 REQUIRED COMPONENTS Interpreter)
    execute_process(
        COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/convert_all_to_asm.py
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE TINYGPT_ALL_ASM_GEN_RESULT
    )
    if (NOT TINYGPT_ALL_ASM_GEN_RESULT EQUAL 0)
        message(FATAL_ERROR "TINYGPT_FORCE_ALL_ASM generation failed")
    endif ()

    include(${CMAKE_SOURCE_DIR}/generated/all_asm/sources.cmake)
    add_library(TinyGPT_all_asm STATIC ${TINYGPT_ALL_ASM_SOURCES})
    set_target_properties(TinyGPT_all_asm PROPERTIES OUTPUT_NAME "tinygpt_all_asm")

    set(TINYGPT_BUILD_PYBINDING OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_DEMO OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_TEST OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_RAFAELIA_ADDON ON CACHE BOOL "" FORCE)
    set(TINYGPT_ASM_ONLY ON CACHE BOOL "" FORCE)
endif ()

if (TINYGPT_ASM_ONLY)
    set(TINYGPT_BUILD_PYBINDING OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_DEMO OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_TEST OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_RAFAELIA_ADDON ON CACHE BOOL "" FORCE)
endif ()

if (NOT TINYGPT_ASM_ONLY)
    add_subdirectory(src)

    if (${TINYGPT_BUILD_PYBINDING})
        set(TINYGPT_BUILD_TEST OFF)
        set(TINYGPT_BUILD_DEMO OFF)
    endif ()

    if (${TINYGPT_BUILD_DEMO})
        add_subdirectory(demo)
    endif ()

    if (${TINYGPT_BUILD_TEST})
        enable_testing()
        add_subdirectory(test)
    endif ()
endif ()

if (${TINYGPT_BUILD_RAFAELIA_ADDON})
    add_subdirectory(addons/rafaelia_core)
endif ()

message(STATUS "TINYGPT_FORCE_ALL_ASM ${TINYGPT_FORCE_ALL_ASM}")
message(STATUS "TINYGPT_ASM_ONLY ${TINYGPT_ASM_ONLY}")
message(STATUS "TINYGPT_BUILD_PYBINDING ${TINYGPT_BUILD_PYBINDING}")
message(STATUS "TINYGPT_BUILD_DEMO ${TINYGPT_BUILD_DEMO}")
message(STATUS "TINYGPT_BUILD_TEST ${TINYGPT_BUILD_TEST}")
message(STATUS "TINYGPT_BUILD_RAFAELIA_ADDON ${TINYGPT_BUILD_RAFAELIA_ADDON}")
