if (CMAKE_VERSION VERSION_LESS 3.0)
    PROJECT(sysrepo-cpp CXX)
    set(PROJECT_VERSION_MAJOR "${SYSREPO_MAJOR_VERSION}")
    set(PROJECT_VERSION_MINOR "${SYSREPO_MINOR_VERSION}")
    set(PROJECT_VERSION_PATCH "${SYSREPO_MICRO_VERSION}")
    set(PROJECT_VERSION "${SYSREPO_VERSION}")
else()
    cmake_policy(SET CMP0048 NEW)
    PROJECT(sysrepo-cpp VERSION "${SYSREPO_VERSION}" LANGUAGES CXX)
endif()

if(NOT CMAKE_CROSSCOMPILING)
    set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -Wall -Wpedantic -std=c++11 -fno-strict-aliasing")
    set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O2")
    set(CMAKE_CXX_FLAGS_DEBUG   "-g -O0")
endif()

set (CMAKE_CXX_STANDARD 17)

# Version of the library
# Major version is changed with every backward non-compatible API/ABI change, minor version changes
# with backward compatible change and micro version is connected with any internal change of the library.
set(SYSREPO_CPP_MAJOR_SOVERSION 4)
set(SYSREPO_CPP_MINOR_SOVERSION 0)
set(SYSREPO_CPP_MICRO_SOVERSION 1)
set(SYSREPO_CPP_SOVERSION_FULL ${SYSREPO_MAJOR_SOVERSION}.${SYSREPO_MINOR_SOVERSION}.${SYSREPO_MICRO_SOVERSION})
set(SYSREPO_CPP_SOVERSION ${SYSREPO_MAJOR_SOVERSION})

set(SYSREPO_CPP_SOURCES
    src/Sysrepo.cpp
    src/Connection.cpp
    src/Session.cpp
    src/Struct.cpp
    src/Xpath.cpp
    src/Internal.cpp)

set(SYSREPO_HPP_SOURCES
    src/Sysrepo.hpp
    src/Connection.hpp
    src/Session.hpp
    src/Struct.hpp
    src/Xpath.hpp
    src/Internal.hpp)

add_library(sysrepo-cpp SHARED ${SYSREPO_CPP_SOURCES})
add_library(sysrepo-cpp::sysrepo-cpp ALIAS sysrepo-cpp)
set_target_properties(sysrepo-cpp PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
set_target_properties(sysrepo-cpp PROPERTIES VERSION ${SYSREPO_CPP_SOVERSION_FULL} SOVERSION ${SYSREPO_CPP_SOVERSION})

# dependencies
include_directories(${LIBYANG_CPP_INCLUDE_DIRS})
include_directories(${CMAKE_SOURCE_DIR})
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/src")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../src")
target_link_libraries(sysrepo-cpp sysrepo ${LIBYANG_CPP_LIBRARIES})

# install binary
install(
    TARGETS sysrepo-cpp
    EXPORT sysrepo-cpp
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES ${SYSREPO_HPP_SOURCES} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/sysrepo-cpp)

# generate and install pkg-config file
configure_file("sysrepo-cpp.pc.in" "sysrepo-cpp.pc" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sysrepo-cpp.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

set(project_config_in "${CMAKE_CURRENT_LIST_DIR}/CMakeModules/sysrepo-cppConfig.cmake.in")
set(project_config_out "${CMAKE_CURRENT_BINARY_DIR}/sysrepo-cppConfig.cmake")
set(config_targets_file "sysrepo-cppConfigTargets.cmake")
set(version_config_file "${CMAKE_CURRENT_BINARY_DIR}/sysrepo-cppConfigVersion.cmake")
set(export_dest_dir "${CMAKE_INSTALL_LIBDIR}/cmake/sysrepo-cpp")

# ---------------------------------------------------------------------------------------
# Install CMake config files
# ---------------------------------------------------------------------------------------
install(EXPORT sysrepo-cpp DESTINATION ${export_dest_dir} NAMESPACE sysrepo-cpp:: FILE ${config_targets_file})

include(CMakePackageConfigHelpers)
configure_file("${project_config_in}" "${project_config_out}" @ONLY)

write_basic_package_version_file("${version_config_file}" COMPATIBILITY SameMajorVersion)
install(FILES "${project_config_out}" "${version_config_file}" DESTINATION "${export_dest_dir}")

# Examples
if(BUILD_CPP_EXAMPLES)
    add_subdirectory(examples)
endif()
