#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <pybind11/numpy.h>

#include "io_uring_stream.hpp"
#include "statediff.hpp"

namespace py = pybind11;
using namespace state_diff;

PYBIND11_MODULE(statediff, m) {
    m.doc() = "Python bindings for state-diff project";

    py::class_<io_uring_stream_t<float>>(m, "IOUringStream")
    .def(py::init([](const std::string &filename, size_t chunk_size) {
        std::string fname_copy = filename;
        return new io_uring_stream_t<float>(fname_copy, chunk_size);
    }));


    py::class_<client_t<float, io_uring_stream_t>>(m, "StateDiffClient")
        .def(py::init<int, io_uring_stream_t<float>&, size_t, float, char, size_t, int, bool>())
        .def("create", [](client_t<float, io_uring_stream_t>& self, py::array_t<float> data) {
            auto buf = data.request();
            float* ptr = static_cast<float*>(buf.ptr);
            std::vector<float> vec(ptr, ptr + buf.size);
            self.create(vec);
        })
        .def("compare_with", &client_t<float, io_uring_stream_t>::compare_with)
        .def("get_num_changes", &client_t<float, io_uring_stream_t>::get_num_changes);
}