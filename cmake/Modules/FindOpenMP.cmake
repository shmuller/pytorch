if(OpenMP_FOUND)
  return()
endif()

set(_OPENMP_EXPECTED_ROOT "")
if(DEFINED INTEL_OPENMP_ROOT)
  set(_OPENMP_EXPECTED_ROOT "${INTEL_OPENMP_ROOT}")
elseif(DEFINED ENV{INTEL_OPENMP_ROOT})
  set(_OPENMP_EXPECTED_ROOT "$ENV{INTEL_OPENMP_ROOT}")
elseif(DEFINED CMAKE_PREFIX_PATH)
  list(GET CMAKE_PREFIX_PATH 0 _OPENMP_EXPECTED_ROOT)
endif()

message(STATUS "_OPENMP_EXPECTED_ROOT: ${_OPENMP_EXPECTED_ROOT}")

if(MSVC)
  find_library(OpenMP_CXX_LIBRARIES NAMES libiomp5md PATHS "${_OPENMP_EXPECTED_ROOT}/lib" NO_DEFAULT_PATH)
  set(OpenMP_CXX_FLAGS "-openmp:experimental")

  install(FILES "${_OPENMP_EXPECTED_ROOT}/bin/libiomp5md.dll" DESTINATION lib)
else()
  # Link GNU OpenMP dynamically so libtorch_cpu.so shares a single OpenMP
  # runtime with the rest of the Python process (numpy/scipy/sklearn/...).
  set(OpenMP_CXX_LIBRARIES "gomp")
  set(OpenMP_CXX_FLAGS "-fopenmp")
endif()

message(STATUS "OpenMP_CXX_LIBRARIES: ${OpenMP_CXX_LIBRARIES}")

set(OpenMP_FOUND FALSE)
if(OpenMP_CXX_LIBRARIES)
  set(OpenMP_FOUND TRUE)
  set(OpenMP_CXX_FOUND ${OpenMP_FOUND})
  
  set(OpenMP_C_FOUND ${OpenMP_FOUND})
  set(OpenMP_C_LIBRARIES "${OpenMP_CXX_LIBRARIES}")
  set(OpenMP_C_FLAGS "${OpenMP_CXX_FLAGS}")

  add_library(OpenMP::OpenMP_CXX INTERFACE IMPORTED)
  set_property(TARGET OpenMP::OpenMP_CXX PROPERTY INTERFACE_LINK_LIBRARIES "${OpenMP_CXX_LIBRARIES}")

  add_library(OpenMP::OpenMP_C INTERFACE IMPORTED)
  set_property(TARGET OpenMP::OpenMP_C PROPERTY INTERFACE_LINK_LIBRARIES "${OpenMP_C_LIBRARIES}")
endif()

set(OPENMP_FOUND ${OpenMP_FOUND})

mark_as_advanced(OpenMP_FOUND OPENMP_FOUND OpenMP_CXX_LIBRARIES)
