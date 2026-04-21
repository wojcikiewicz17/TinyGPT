cmake_minimum_required(VERSION 3.15)
project(GeoLM_core ASM)

add_library(GeoLM_core STATIC asm/geolm_core.S)
set_target_properties(GeoLM_core PROPERTIES OUTPUT_NAME "geolm_core")
target_include_directories(GeoLM_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
