cmake_minimum_required(VERSION 3.14)
project(statediff_python LANGUAGES CXX)

find_package(pybind11 CONFIG REQUIRED)
find_package(Kokkos REQUIRED CONFIG)
find_package(OpenSSL REQUIRED)
find_package(OpenMP REQUIRED)

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
)

add_dependencies(statediff state-diff-install)

set(_RPATHS "${STATE_DIFF_INSTALL}/lib;${STATE_DIFF_INSTALL}/lib64;$ORIGIN")

foreach(t Kokkos::kokkoscore Kokkos::kokkoscontainers Kokkos::kokkos)
  if(TARGET ${t})
    get_target_property(_loc ${t} IMPORTED_LOCATION)
    if(_loc)
      list(APPEND _RPATHS "$<TARGET_FILE_DIR:${t}>")
      break()
    endif()
  endif()
endforeach()

set_target_properties(statediff PROPERTIES
  BUILD_WITH_INSTALL_RPATH ON
  SKIP_BUILD_RPATH OFF
  BUILD_RPATH   "${_RPATHS}"
  INSTALL_RPATH "${_RPATHS}"
  PREFIX ""
)