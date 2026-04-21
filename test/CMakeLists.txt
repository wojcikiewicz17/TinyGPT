cmake_minimum_required(VERSION 3.15)
project(TinyGPT_test)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(THIRD_PARTY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../third_party)

if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/googletest/CMakeLists.txt")
    if (TINYGPT_AUTO_FETCH_DEPS)
        find_package(Git QUIET)
        if (NOT GIT_FOUND)
            message(FATAL_ERROR
                    "Dependência de testes ausente em '${CMAKE_CURRENT_SOURCE_DIR}/googletest' e Git indisponível.\\n"
                    "Execute: ./scripts/bootstrap_submodules.sh")
        endif ()
        message(STATUS "googletest ausente. Auto-bootstrap via git clone.")
        execute_process(
                COMMAND "${GIT_EXECUTABLE}" clone --depth 1 "https://github.com/google/googletest.git" "${CMAKE_CURRENT_SOURCE_DIR}/googletest"
                RESULT_VARIABLE gtest_clone_result
                OUTPUT_VARIABLE gtest_clone_stdout
                ERROR_VARIABLE gtest_clone_stderr
        )
        if (NOT gtest_clone_result EQUAL 0)
            message(FATAL_ERROR
                    "Falha ao clonar googletest.\\nstdout:\\n${gtest_clone_stdout}\\nstderr:\\n${gtest_clone_stderr}")
        endif ()
    else ()
        message(FATAL_ERROR
                "Dependência de testes ausente em '${CMAKE_CURRENT_SOURCE_DIR}/googletest'.\\n"
                "Execute: ./scripts/bootstrap_submodules.sh")
    endif ()
endif ()

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
add_subdirectory(googletest)

file(GLOB test_src
        "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)

add_executable(${PROJECT_NAME} ${test_src})

target_include_directories(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/../src
        ${THIRD_PARTY_DIR}/TinyTorch/src
        ${THIRD_PARTY_DIR}
        googletest/googletest/include
        googletest/googlemock/include
)
target_link_libraries(${PROJECT_NAME} TinyGPT_lib gtest_main)

if (MSVC)
    set_source_files_properties(${test_src} PROPERTIES COMPILE_FLAGS "/utf-8")
endif ()

include(GoogleTest)

# copy assets
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E remove_directory $<TARGET_FILE_DIR:${PROJECT_NAME}>/assets
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/../assets $<TARGET_FILE_DIR:${PROJECT_NAME}>/assets
)

# add tests
gtest_discover_tests(${PROJECT_NAME} WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)
