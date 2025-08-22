project(statediff_python LANGUAGES CXX)

set(PYBIND11_FINDPYTHON ON)
find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)
find_package(pybind11 CONFIG REQUIRED)
find_package(Kokkos CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(OpenMP REQUIRED)

# find through spack
find_library(LIBURING_LIB NAMES uring
  HINTS $ENV{LIBURING_PREFIX} ${CMAKE_PREFIX_PATH}
  PATH_SUFFIXES lib lib64
)
# lookup liburing on system
if(NOT LIBURING_LIB)
  find_library(LIBURING_LIB NAMES uring)
endif()
if(NOT LIBURING_LIB)
  message(FATAL_ERROR "liburing not found. Set LIBURING_PREFIX or add liburing to CMAKE_PREFIX_PATH.")
endif()
get_filename_component(LIBURING_DIR "${LIBURING_LIB}" DIRECTORY)

pybind11_add_module(statediff MODULE ${CMAKE_CURRENT_SOURCE_DIR}/bindings.cpp)
target_compile_features(statediff PRIVATE cxx_std_17)
target_compile_definitions(statediff PRIVATE _GLIBCXX_USE_CXX11_ABI=1)

target_include_directories(statediff PRIVATE
    ${CMAKE_SOURCE_DIR}/external/state-diff/include
    ${CMAKE_SOURCE_DIR}/external/state-diff/src
    ${CMAKE_SOURCE_DIR}/external/state-diff/src/readers
    ${CMAKE_SOURCE_DIR}/external/state-diff/extern/cereal/include
)

target_link_libraries(statediff PRIVATE
  statediff_external
  Kokkos::kokkos 
  OpenSSL::SSL 
  OpenMP::OpenMP_CXX
  "${LIBURING_LIB}"
)

add_dependencies(statediff state-diff-install)

set(_RPATHS
  "$ORIGIN"
  "${STATE_DIFF_INSTALL}/lib"
  "${STATE_DIFF_INSTALL}/lib64"
  "$<TARGET_FILE_DIR:statediff_external>"
  "$<TARGET_FILE_DIR:OpenSSL::SSL>"
  "$<TARGET_FILE_DIR:Kokkos::kokkoscore>"
  "${LIBURING_DIR}"
)

set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_BUILD_RPATH_USE_ORIGIN TRUE)

set_target_properties(statediff PROPERTIES
  BUILD_RPATH   "${_RPATHS}"
  INSTALL_RPATH "${_RPATHS}"
  SKIP_BUILD_RPATH OFF
  PREFIX "" 
)


install(TARGETS statediff DESTINATION ".")