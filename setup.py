from setuptools import setup
import os
from pybind11.setup_helpers import Pybind11Extension, build_ext

kokkos_prefix = os.environ.get("KOKKOS_PREFIX", "kokkos-not-found")

ext_modules = [
    Pybind11Extension(
        "statediff",
        ["python/bindings.cpp"],
        include_dirs=[
            "external/state-diff/include",
            "external/state-diff/src",
            "external/state-diff/src/readers",
            "external/state-diff/src/common",
            "external/state-diff/extern/cereal/include",
            os.path.join(kokkos_prefix, "include"),
        ],
        cxx_std=17,
    ),
]

setup(
    name="statediff",
    version="0.1",
    author="Your Name",
    description="Python bindings for state-diff",
    ext_modules=ext_modules,
    cmdclass={"build_ext": build_ext},
    zip_safe=False,
    python_requires=">=3.6",
)
