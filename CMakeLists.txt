cmake_minimum_required(VERSION 3.15)
project(TinyGPT)

set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)

option(TINYGPT_ASM_ONLY "Build only the low-level RafaelIA shell (no C++ core, no Python binding)" OFF)
option(TINYGPT_BUILD_PYBINDING "Whether or not to build pybinding" OFF)
option(TINYGPT_BUILD_DEMO "Whether or not to build demo" ON)
option(TINYGPT_BUILD_TEST "Whether or not to build the tests" ON)
option(TINYGPT_BUILD_RAFAELIA_ADDON "Whether or not to build RafaelIA addon" OFF)

if (TINYGPT_ASM_ONLY)
    set(TINYGPT_BUILD_PYBINDING OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_DEMO OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_TEST OFF CACHE BOOL "" FORCE)
    set(TINYGPT_BUILD_RAFAELIA_ADDON ON CACHE BOOL "" FORCE)

    message(STATUS "TINYGPT_ASM_ONLY=ON -> disabling C++/Python surfaces and building RafaelIA addon shell only")
else ()
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

message(STATUS "TINYGPT_ASM_ONLY ${TINYGPT_ASM_ONLY}")
message(STATUS "TINYGPT_BUILD_PYBINDING ${TINYGPT_BUILD_PYBINDING}")
message(STATUS "TINYGPT_BUILD_DEMO ${TINYGPT_BUILD_DEMO}")
message(STATUS "TINYGPT_BUILD_TEST ${TINYGPT_BUILD_TEST}")
message(STATUS "TINYGPT_BUILD_RAFAELIA_ADDON ${TINYGPT_BUILD_RAFAELIA_ADDON}")
