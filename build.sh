#! /bin/bash

gfortran -g -o globe get_GLOBE_pfl.f globe.f subsunix.f
./globe < globe.in

gfortran -c -fc-prototypes globe_wrap.f95 > globe.h
gfortran -g -shared -fPIC -o libglobe.so globe_wrap.f95 get_GLOBE_pfl.f globe.f subsunix.f

gcc -g -o test_globe test_globe.c -L. -lglobe
LD_LIBRARY_PATH=. ./test_globe < test.in

g++ -g -o test_globepp test_globepp.cpp -L. -lglobe
LD_LIBRARY_PATH=. ./test_globepp < test.in
