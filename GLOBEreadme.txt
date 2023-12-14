c*****************************************************************
c  This is a program to test extraction of the GLOBE data base.
c  It is written in Fortran and there may need to be modifications
c  depending on the Fortran compiler used and computer system.
c  PCs and unix handle binary data differently, and therefore
c  a few lines of code need to be changed depending on your computer
c  system.  It is also assumed that the GLOBE data base has been
c  placed on your computer system.
c  Since PCs & unix use different directory separators
c  (e.g. / vs \), you must be aware of that difference also.
c
c  These routines have been developed for GLOBE Version 1.0.
c  This was a significant change from GLOBE Version 0.5.
c  The Globe web site is:
c      http://www.ngdc.noaa.gov/seg/topo/globe.shtml
c  This site will allow you to download the Globe data free
c  or you can order CDs containing the data.
c  The data exists as 16 tiles and must be gunziped to be usable.
c  The unzipped 16 files will require about 2GBytes of disk storage.
c  Make sure when the files are unzipped, the file names are of
c  the form: ?10g. There should ne NO SUFFIX. As future versions
c  of Globe are released, the file name may change (e.g. a11g
c  would be Globe version 1.1).  If you obtain such a file in the future,
c  you will need to modify the file name in the file globe.dat below,
c  or rename the file to its original name (e.g. a10g).
c
c  In addition to the 16 files (tiles) that contain the elevation
c  data, the following data must exist in the file named globe.dat
c  and should reside in the same directory as the GLOBE data files.
c  The record with the headings should be the first record in the file.
c*******************************************************************
c  file lat1 lat2 lon1 lon2 Description
c  a10g   50   90  180  270 Tile A lat(50-90N) lon(180- 90W)
c  b10g   50   90  270  360 Tile B lat(50-90N) lon( 90-  0W)
c  c10g   50   90    0   90 Tile C lat(50-90N) lon(  0- 90E)
c  d10g   50   90   90  180 Tile D lat(50-90N) lon( 90-180E)
c  e10g    0   50  180  270 Tile E lat( 0-50N) lon(180- 90W)
c  f10g    0   50  270  360 Tile F lat( 0-50N) lon( 90-  0W)
c  g10g    0   50    0   90 Tile G lat( 0-50N) lon(  0- 90E)
c  h10g    0   50   90  180 Tile H lat( 0-50N) lon( 90-180E)
c  i10g  -50    0  180  270 Tile I lat(50S-0 ) lon(180- 90W)
c  j10g  -50    0  270  360 Tile J lat(50S-0 ) lon( 90-  0W)
c  k10g  -50    0    0   90 Tile K lat(50S-0 ) lon(  0- 90E)
c  l10g  -50    0   90  180 Tile L lat(50S-0 ) lon( 90-180E)
c  m10g  -90  -50  180  270 Tile M lat(90-50S) lon(180- 90W)
c  n10g  -90  -50  270  360 Tile N lat(90-50S) lon( 90-  0W)
c  o10g  -90  -50    0   90 Tile O lat(90-50S) lon(  0- 90E)
c  p10g  -90  -50   90  180 Tile P lat(90-50S) lon( 90-180E)
c*******************************************************************
c  You MUST remove the initial 3 columns from the data above.
c  The file name should appear in column 1.
c  As you obtain new versions of the Globe database, you may need
c  to change the file names within this data file.
c  This data file contains the 4 character names of the 16 tiles.
c*******************************************************************
c*******************************************************************
c  4 Fortran source files make up this test program.
c    globe.f         - the main program
c    get_GLOBE_pfl.f - the subroutine that extracts the profile from
c                      the GLOBE database. This file also contains
c                      the subroutine DAZEL that is used to calculate
c                      the points along a great circle path between
c                      the 2 points given.
c    subsunix.f      - the GLOBE extractions subroutines for unix systems.
c    subspc.f        - the GLOBE extractions subroutines for PC systems.
c
c  For all system:
c   1. Obtain the Globe data base and place the 16 tile files into
c      a directory on your system.
c   2. Place the file globe.dat from this web site into the same directory.
c
c  For unix systems:
c   3. Modify subsunix.f to define the GLOBE data directory.
c      This is contained in the 3 lines:
c          path='/disc3/terrain2/globe/'  !  directory containing GLOBE data
c          nchp=22                        !  # characters in path
c          lu_globe=61                    !  FORTRAN unit number to use
c   4. Combine the source code files:
c          globe.f get_GLOBE_pfl.f subsunix.f
c   5. Compile and link using your FORTRAN compiler.
c      This has been tested on HP-UX with HP's FORTRAN/9000.
c   6. Execute and input the recommended data to compare with the results
c      you should obtain.
c                      
c  For PC systems:
c   3. Modify subspc.f to define the GLOBE data directory.
c      This is contained in the 3 lines:
c          path='E:\globe\'               !  directory containing GLOBE data
c          nchp=9                         !  # characters in path
c          lu_globe=61                    !  FORTRAN unit number to use
c   4. Combine the source code files:
c          globe.f get_GLOBE_pfl.f subsunix.f
c   5. Compile and link using your FORTRAN compiler.
c      This has been tested using Salford FTN77.
c   6. Execute and input the recommended data to compare with the results
c      you should obtain.
c
c*******************************************************************
c*******************************************************************
c
c  This code was written for the U.S. Department of
c  Commerce NTIA/ITS in Boulder, Colorado.  April 1999.
c  It is freely available, but do not remove the comments.
c  
c*******************************************************************
c*******************************************************************
