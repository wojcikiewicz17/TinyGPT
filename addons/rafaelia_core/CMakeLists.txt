cmake_minimum_required(VERSION 3.15)
project(RafaelIA_core C ASM)

option(RAFAELIA_BUILD_ADDON "Build RafaelIA addon library" ON)

if (NOT RAFAELIA_BUILD_ADDON)
    return()
endif ()

set(RAFAELIA_CORE_SOURCES
    rmr_engine.c
    vectra_dispatch.c
)

if (CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
    list(APPEND RAFAELIA_CORE_SOURCES asm/arm64/vectra_pulse.S)
    add_compile_definitions(RAFAELIA_ARCH_ARM64=1)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "^(armv7|armv7l|arm)$")
    list(APPEND RAFAELIA_CORE_SOURCES asm/arm32/vectra_pulse.S)
    add_compile_definitions(RAFAELIA_ARCH_ARM32=1)
else ()
    list(APPEND RAFAELIA_CORE_SOURCES vectra_fallback.c)
    add_compile_definitions(RAFAELIA_ARCH_FALLBACK=1)
    message(STATUS "RafaelIA ASM core skipped: unsupported CPU (${CMAKE_SYSTEM_PROCESSOR}); using portable fallback")
endif ()

add_library(RafaelIA_core STATIC ${RAFAELIA_CORE_SOURCES})

target_include_directories(RafaelIA_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

set_target_properties(RafaelIA_core PROPERTIES
    OUTPUT_NAME "rafaelia_core"
)

if (UNIX)
    target_link_libraries(RafaelIA_core PUBLIC m)
endif ()
