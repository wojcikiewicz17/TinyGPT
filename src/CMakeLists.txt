cmake_minimum_required(VERSION 3.15)
project(TinyGPT_lib)
set(THIRD_PARTY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../third_party)

if (CMAKE_BUILD_TYPE STREQUAL Debug)
    add_definitions(-DDEBUG)
endif ()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(TINYGPT_USE_CUDA "Enable TinyTorch CUDA backend" OFF)
option(TINYGPT_USE_NCCL "Enable TinyTorch NCCL backend" OFF)

function(require_dependency_dir dir_path init_hint git_url)
    if (NOT EXISTS "${dir_path}/CMakeLists.txt")
        if (TINYGPT_AUTO_FETCH_DEPS)
            find_package(Git QUIET)
            if (NOT GIT_FOUND)
                message(FATAL_ERROR
                        "Dependência ausente em '${dir_path}' e Git não encontrado para auto-bootstrap.\\n"
                        "Execute: ${init_hint}")
            endif ()

            message(STATUS "Dependência ausente em '${dir_path}'. Auto-bootstrap via git clone de ${git_url}")
            execute_process(
                    COMMAND "${GIT_EXECUTABLE}" clone --depth 1 --recurse-submodules --shallow-submodules "${git_url}" "${dir_path}"
                    RESULT_VARIABLE dep_clone_result
                    OUTPUT_VARIABLE dep_clone_stdout
                    ERROR_VARIABLE dep_clone_stderr
            )
            if (NOT dep_clone_result EQUAL 0)
                message(FATAL_ERROR
                        "Falha ao clonar dependência '${dir_path}' de '${git_url}'.\\n"
                        "stdout:\\n${dep_clone_stdout}\\n"
                        "stderr:\\n${dep_clone_stderr}\\n"
                        "Fallback manual: ${init_hint}")
            endif ()
        else ()
            message(FATAL_ERROR
                    "Dependência ausente em '${dir_path}'.\\n"
                    "Execute: ${init_hint}")
        endif ()
    endif ()
endfunction()

require_dependency_dir(
        "${THIRD_PARTY_DIR}/TinyTorch"
        "./scripts/bootstrap_submodules.sh"
        "https://github.com/keith2018/TinyTorch.git")
require_dependency_dir(
        "${THIRD_PARTY_DIR}/pcre2"
        "./scripts/bootstrap_submodules.sh"
        "https://github.com/PCRE2Project/pcre2.git")
require_dependency_dir(
        "${THIRD_PARTY_DIR}/utf8proc"
        "./scripts/bootstrap_submodules.sh"
        "https://github.com/JuliaStrings/utf8proc.git")

if (${TINYGPT_BUILD_PYBINDING})
    require_dependency_dir(
            "${THIRD_PARTY_DIR}/pybind11"
            "./scripts/bootstrap_submodules.sh"
            "https://github.com/pybind/pybind11.git")
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    set(BUILD_SHARED_LIBS OFF)
endif ()

set(TINYTORCH_BUILD_DEMO OFF CACHE BOOL "" FORCE)
set(TINYTORCH_BUILD_TEST OFF CACHE BOOL "" FORCE)
set(TINYTORCH_USE_CUDA ${TINYGPT_USE_CUDA} CACHE BOOL "" FORCE)
set(TINYTORCH_USE_NCCL ${TINYGPT_USE_NCCL} CACHE BOOL "" FORCE)
add_subdirectory(${THIRD_PARTY_DIR}/TinyTorch TinyTorch)

#pcre2
set(PCRE2_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(PCRE2_BUILD_PCRE2GREP OFF CACHE BOOL "" FORCE)
set(PCRE2_BUILD_PCRE2TEST OFF CACHE BOOL "" FORCE)
set(PCRE2_BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(PCRE2_SUPPORT_UNICODE ON CACHE BOOL "" FORCE)
set(PCRE2_SUPPORT_JIT ON CACHE BOOL "" FORCE)
set(PCRE2_BUILD_PCRE2_8 ON CACHE BOOL "" FORCE)
add_subdirectory(${THIRD_PARTY_DIR}/pcre2 pcre2)

#utf8proc
set(UTF8PROC_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(UTF8PROC_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory(${THIRD_PARTY_DIR}/utf8proc utf8proc)

file(GLOB TinyGPT_src
        "${CMAKE_CURRENT_SOURCE_DIR}/huggingface/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/model/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tokenizer/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)

add_library(${PROJECT_NAME} STATIC ${TinyGPT_src})
target_link_libraries(${PROJECT_NAME} TinyTorch_lib pcre2-8 utf8proc)
target_include_directories(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${THIRD_PARTY_DIR}/pcre2/src
        ${THIRD_PARTY_DIR}/TinyTorch/src
        ${THIRD_PARTY_DIR}
)

# disable exceptions
target_compile_options(${PROJECT_NAME} PRIVATE
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CXX_COMPILER_ID:MSVC>>:/EHs-c->
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fno-exceptions>
)

if (CMAKE_BUILD_TYPE STREQUAL Debug)
    add_definitions(-DDEBUG)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall")
elseif (CMAKE_BUILD_TYPE STREQUAL Release)
    if (MSVC)
        set_source_files_properties(${TinyGPT_src} PROPERTIES COMPILE_FLAGS "/Ox")
    else ()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG")
    endif ()
endif ()

if (${TINYGPT_BUILD_PYBINDING})
    add_subdirectory(${THIRD_PARTY_DIR}/pybind11 pybind11)
    pybind11_add_module(_tinygpt binding/pybind_tinygpt.cpp)
    target_include_directories(_tinygpt PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${THIRD_PARTY_DIR}/TinyTorch/src
            ${THIRD_PARTY_DIR}
            pybind11/include
    )
    target_link_libraries(_tinygpt PRIVATE TinyGPT_lib)
    set_target_properties(_tinygpt PROPERTIES PREFIX "" SUFFIX ".so")
    install(TARGETS _tinygpt LIBRARY DESTINATION tinygpt)
endif ()
