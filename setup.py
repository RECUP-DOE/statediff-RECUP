from setuptools import setup
import os
from pybind11.setup_helpers import Pybind11Extension, build_ext

kokkos_prefix     = os.environ.get("KOKKOS_PREFIX")
statediff_prefix  = os.environ.get("STATEDIFF_PREFIX")
liburing_prefix   = os.environ.get("LIBURING_PREFIX")

missing = [k for k,v in {
    "KOKKOS_PREFIX": kokkos_prefix,
    "STATEDIFF_PREFIX": statediff_prefix,
    "LIBURING_PREFIX": liburing_prefix,
}.items() if not v]
if missing:
    raise RuntimeError(f"Set {', '.join(missing)} before building.")

def libdirs(prefix):
    return [os.path.join(prefix, "lib"), os.path.join(prefix, "lib64")]

include_dirs = [
    "external/state-diff/include",
    "external/state-diff/src",
    "external/state-diff/src/readers",
    "external/state-diff/src/common",
    "external/state-diff/extern/cereal/include",
    os.path.join(kokkos_prefix, "include"),
]

library_dirs = libdirs(kokkos_prefix) + libdirs(statediff_prefix) + libdirs(liburing_prefix)

rpaths = libdirs(kokkos_prefix) + libdirs(statediff_prefix) + libdirs(liburing_prefix) + ["$ORIGIN"]

ext_modules = [
    Pybind11Extension(
        "statediff",
        ["python/bindings.cpp"],
        include_dirs=include_dirs,
        library_dirs=library_dirs,
        libraries=[
            "statediff",
            "kokkoscore",
            "uring",
        ],
        extra_compile_args=[
            "-O3",
            "-std=c++17",
            "-D_GLIBCXX_USE_CXX11_ABI=1",
        ],
        extra_link_args=[
            "-Wl,--no-as-needed",
            "-Wl,-rpath," + ":".join(rpaths),
        ],
        cxx_std=17,
    ),
]

setup(
    name="statediff",
    version="0.1",
    author="DataStates",
    description="Python bindings for state-diff",
    ext_modules=ext_modules,
    cmdclass={"build_ext": build_ext},
    zip_safe=False,
    python_requires=">=3.8",
)