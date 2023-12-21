cmake_minimum_required(VERSION 3.17.5)

project(GLOBE
        VERSION 1.1
        LANGUAGES Fortran C CXX)

include(FortranCInterface)

FortranCInterface_VERIFY()
FortranCInterface_VERIFY(CXX)

# Not that useful:
FortranCInterface_HEADER(poop.h)
# I want something to make a C prototype header fom a Fortran module:
# gfortran -c -fc-prototypes globe_wrap.f95 > globe.h

add_executable(test_globef get_GLOBE_pfl.f globe.f subsunix.f)

add_library(globe SHARED globe_wrap.f95 get_GLOBE_pfl.f globe.f subsunix.f)
target_sources(globe
               PRIVATE FILE_SET globe_header
               TYPE HEADERS
               FILES globe.h)

if (FortranCInterface_VERIFIED_C)
  add_executable(test_globe test_globe.c)
  target_link_libraries(test_globe globe)
endif()

if (FortranCInterface_VERIFIED_CXX)
  add_executable(test_globepp test_globepp.cpp)
  target_link_libraries(test_globepp globe)
endif()
