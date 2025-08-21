project(statediff_python LANGUAGES CXX)

set(PYBIND11_FINDPYTHON ON)
find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)
find_package(pybind11 CONFIG REQUIRED)
find_package(Kokkos CONFIG REQUIRED)
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

set_property(TARGET statediff APPEND PROPERTY BUILD_RPATH "$<TARGET_FILE_DIR:Kokkos::kokkos>")
set_property(TARGET statediff APPEND PROPERTY INSTALL_RPATH "$<TARGET_FILE_DIR:Kokkos::kokkos>")

set_target_properties(statediff PROPERTIES
  BUILD_WITH_INSTALL_RPATH ON
  SKIP_BUILD_RPATH OFF
  BUILD_RPATH   "${_RPATHS}"
  INSTALL_RPATH "${_RPATHS}"
  PREFIX ""
)