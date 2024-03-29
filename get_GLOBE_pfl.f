      subroutine get_GLOBE_pfl(tlat,tlon,rlat,rlon,npoints,pfl,ierror)
c*****************************************************************
c          WARNING: there is some code that MUST be changed depending on your
c                   computer system.  This is because the GLOBE data base is
c                   stored in a binary format and unix systems must byte swap
c                   the data.  PCs do not.  The code can be found in subroutine
c                   get_GLOBE_data.  Follow instructions in the comments.
c*****************************************************************
c          Written for GLOBE Version 1.0
c*****************************************************************
c          Extract a path profile array from Tx to Rx from the GLOBE data base.
c          Elevation points are in meters.  The great circle SHORTEST path
c          will be extracted from the data base.  Longitude values should be
c          in the range [-180 to +180 degrees], with +lon=East.
c
c          (tlat,tlon) = lat/lon (degrees) at Tx +lon=East, -lon=West
c          (rlat,rlon) = lat/lon (degrees) at Rx +lon=East, -lon=West
c          npoints = number of points to get between Tx & Rx
c          pfl = array to fill (result will be in meters)
c                pfl(1) = npoints
c                pfl(2) = distance between points (meters)
c                         thus, (pfl(1)-1)*pfl(2)=distance between Tx & Rx
c                pfl(3) = Tx elevation in meters
c                pfl(npoints+2) = Rx elevation in meters
c          return 1 = no GLOBE data exists
c*****************************************************************
c          Written by Greg Hand NTIA/ITS.S1 April 1999
c          for the NOAA's Globe Ver 1.0 elevation data
c*****************************************************************
      dimension pfl(*)
      real*8 delta
      integer ierror
c          common block used by SUBROUTINE DAZEL to calculate great circle paths
      COMMON/AZEL/ ZTLAT,ZTLON,ZTHT,ZRLAT,ZRLON,ZRHT,ZTAZ,ZRAZ,
     * ZTELV,ZRELV,ZD,ZDGC,ZTAKOF,ZRAKOF
      ierror = 0
      ztht=GLOBE_elevation(tlon,tlat)           !  height at Tx
      if(ztht.lt.-500.) then ! error in GLOBE data file
        ierror = 1
        return
      end if
      zrht=GLOBE_elevation(rlon,rlat)           !  height at Rx
      if(zrht.lt.-500.) then ! error in GLOBE data file
        ierror = 2
        return
      end if
      ztlat=tlat
      ztlon=tlon
      zrlat=rlat
      zrlon=rlon
      call dazel(0)                       !  calc ZTAZ & ZDGC
      pfl(1)=npoints
      delta=zdgc/dfloat(npoints-1)
      pfl(2)=delta*1000.D0                !  convert to meters
      pfl(3)=ztht
      pfl(npoints+2)=zrht
      do i=2,npoints-1
        zdgc=dfloat(i-1)*delta
        call dazel(1)                        !  calc ZRLAT,ZRLON
        zz=GLOBE_elevation(zrlon,zrlat)      !  height at point
        if(zz.lt.-500.) then ! error in GLOBE data file
          ierror = i+2
          return
        end if
        pfl(i+2)=zz
      end do
      return
      end subroutine

c-------------------------------------------------------
      SUBROUTINE DAZEL(MODE)
C#  SUB DAZEL(MODE)             Great circle calculations.
       IMPLICIT DOUBLE PRECISION(A-L,N-Y)
C
C     TWO MODES--   0   INPUT LAT AND LON OF END POINT
C                       RETURN DISTANCE AND AZIMUTH TO END PT WITH ELEVATIONS
C                   1   INPUT BEARING (AZIMUTH) OF END POINT
C                       RETURN LAT AND LON OF END POINT WITH ELEVATIONS
C
C   MODE 0
C   INPUT PARAMETERS (THESE DEFINE LOCATION OF POINTS T (TRANSMITTER)
C     AND R (RECEIVER) RELATIVE TO A SPHERICAL EARTH.
C     ZTLAT - LATITUDE (DECIMAL DEGREES NORTH OF EQUATOR) OF POINT T
C     ZTLON - LONGITUDE (DECIMAL DEGREES EAST OF PRIME (GREENWICH)
C            MERIDIAN) OF POINT T
C     ZTHT  - HEIGHT (METERS ABOVE MEAN SEA LEVEL) OF POINT T
C     ZRLAT - LATITUDE (DECIMAL DEGREES NORTH OF EQUATOR) OF POINT R
C     ZRLON - LONGITUDE (DECIMAL DEGREES EAST OF PRIME MERIDIAN OF POINT R
C     ZRHT  - HEIGHT (METERS ABOVE MEAN SEA LEVEL) OF POINT R
C
C   OUTPUT PARAMETERS
C     ZTAZ  - AZUMUTH (DECIMAL DEGREES CLOCKWISE FROM NORTH) AT T OF R
C     ZRAZ  - AZIMUTH (DECIMAL DEGREES CLOCKWISE FROM NORTH) AT R OF T
C     ZTELV - ELEVATION ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT T
C            OF STRAIGHT LINE BETWEEN T AND R
C     ZRELV - ELEVATION ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT R)
C            OF STRAIGHT LINE BETWEEN T AND R
C     ZTAKOF - TAKE-OFF ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT T)
C            OF REFRACTED RAY BETWEEN T AND R (ASSUMED 4/3 EARTH RADIUS)
C     ZRAKOF - TAKE-OFF ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT R)
C            OF REFRACTED RAY BETWEEN T AND R (ASSUMED 4/3 EARTH RADIUS)
C     ZD    - STRAIGHT LINE DISTANCE (KILOMETERS) BETWEEN T AND R
C     ZDGC  - GREAT CIRCLE DISTANCE (KILOMETERS) BETWEEN T AND R
C
C   MODE 1
C   INPUT PARAMETERS                    OUTPUT PARAMETERS
C     ZTLAT                                ZRLAT
C     ZTLON                                ZRLON
C     ZTAZ                                 RELEV,ZRAKOF
C     ZDGC                                 TELEV,ZTAKOF
C
C
C     ALL OF THE ABOVE PARAMETERS START WITH THE LETTER Z AND ARE SINGLE
C     PRECISION.  ALL PROGRAM VARIABLES ARE DOUBLE PRECISION.
C     PROGRAM IS UNPREDICTABLE FOR SEPARATIONS LESS THAN 0.00005 DEGREES,
C     ABOUT 5 METERS.
C
C   WRITTEN BY KEN SPIES 5/79
C   REFRACTION AND ST. LINE ELEVATIONS BY EJH
C
      COMMON/AZEL/ ZTLAT,ZTLON,ZTHT,ZRLAT,ZRLON,ZRHT,ZTAZ,ZRAZ,
     * ZTELV,ZRELV,ZD,ZDGC,ZTAKOF,ZRAKOF
      DATA PI/3.141592653589793238462643D0/,RERTH/6370.0D0/
      DATA DTOR/0.01745329252D0/,RTOD/57.29577951D0/
      IF(MODE .EQ. 1) GO TO 200
      TLATS=ZTLAT
      TLONS=ZTLON
      THTS=ZTHT*1.0E-3
      RLATS=ZRLAT
      RLONS=ZRLON
      RHTS=ZRHT*1.0E-3
      IF(TLATS.LE.-90.0) TLATS=-89.99
      IF(TLATS.GE. 90.0) TLATS= 89.99
      IF(RLATS.LE.-90.0) RLATS=-89.99
      IF(RLATS.GE. 90.0) RLATS= 89.99
      DELAT=RLATS-TLATS
      ADLAT=DABS(DELAT)
      DELON=RLONS-TLONS
      DO WHILE (DELON .LT. -180.0)
        DELON=DELON+360.0
      END DO
      DO WHILE (DELON .GT. 180.0)
        DELON=DELON-360.0
      END DO
      ADLON=DABS(DELON)
      DELHT=RHTS-THTS
      IF(ADLON .LE. 1.0E-5) THEN
        IF(ADLAT .LE. 1.0E-5) THEN
          !
          !   POINTS T AND R HAVE THE SAME COORDINATES
          !
          ZTAZ=0.0
          ZRAZ=0.0
          IF (DELHT .LT. 0.0) THEN
            ZTELV=-90.0
            ZRELV=90.0
            ZD=-DELHT
            ZDGC=0.0
            RETURN
          ELSE IF (DELHT .EQ. 0.0) THEN
            ZTELV=0.0
            ZRELV=0.0
            ZD=0.0
            ZDGC=0.0
            RETURN
          ELSE
            ZTELV=90.0
            ZRELV=-90.0
            ZD=DELHT
            ZDGC=0.0
            RETURN
          END IF
        ELSE
          !
          !   POINTS T AND R HAVE SAME LONGITUDE, DISTINCT LATITUDES
          !
          IF (DELAT .LE. 0.0) THEN
            ZTAZ=180.0
            ZRAZ=0.0
          ELSE
            ZTAZ=0.0
            ZRAZ=180.0
          END IF
          GC=ADLAT*DTOR
          SGC=DSIN(0.5*GC)
          D=DSQRT(DELHT*DELHT+4.0*(RERTH+THTS)*(RERTH+RHTS)*SGC*SGC)
          ZD=D
          GO TO 140
        END IF
      ELSE
        !
        !   POINTS T AND R HAVE DISTINCT LONGITUDES
        !
        IF (DELON .LE. 0.0) THEN
          WLAT=RLATS*DTOR
          ELAT=TLATS*DTOR
        ELSE
          WLAT=TLATS*DTOR
          ELAT=RLATS*DTOR
        END IF
      END IF
      !
      !   CALCULATE AZIMUTHS AT POINTS W AND E
      !
      SDLAT=DSIN(0.5*ADLAT*DTOR)
      SDLON=DSIN(0.5*ADLON*DTOR)
      SADLN=DSIN(ADLON*DTOR)
      CWLAT=DCOS(WLAT)
      CELAT=DCOS(ELAT)
      P=2.0*(SDLAT*SDLAT+SDLON*SDLON*CWLAT*CELAT)
      SGC=DSQRT(P*(2.0-P))
      SDLAT=DSIN(ELAT-WLAT)
      CWAZ=(2.0*CELAT*DSIN(WLAT)*SDLON*SDLON+SDLAT)/SGC
      SWAZ=SADLN*CELAT/SGC
      WAZ=DATAN2(SWAZ,CWAZ)*RTOD
      CEAZ=(2.0*CWLAT*DSIN(ELAT)*SDLON*SDLON-SDLAT)/SGC
      SEAZ=SADLN*CWLAT/SGC
      EAZ=DATAN2(SEAZ,CEAZ)*RTOD
      EAZ=360.0-EAZ
      IF (DELON .LE. 0.0) THEN
        ZTAZ=EAZ
        ZRAZ=WAZ
      ELSE
        ZTAZ=WAZ
        ZRAZ=EAZ
      END IF
      !
      !   COMPUTE THE STRAIGHT LINE DISTANCE AND GREAT CIRCLE ANGLE BETWEEN T AND R
      !
      D=DSQRT(DELHT*DELHT+2.0*(RERTH+THTS)*(RERTH+RHTS)*P)
      ZD=D
      CGC=1.0-P
      GC=DATAN2(SGC,CGC)
      !
      !   COMPUTE GREAT CIRCLE DISTANCE AND ELEVATION ANGLES
      !
140   ZDGC=GC*RERTH
142   IF (DELHT .LT. 0.0) THEN
        AHT=THTS
        BHT=RHTS
      ELSE
        AHT=RHTS
        BHT=THTS
      END IF
      SAELV=0.5*(D*D+DABS(DELHT)*(RERTH+AHT+RERTH+BHT))/(D*(RERTH+AHT))
      ARG=DMAX1(0.0D0,(1.0D0-SAELV*SAELV))
      AELV=DATAN2(SAELV,DSQRT(ARG))
      BELV=(AELV-GC)*RTOD
      AELV=-AELV*RTOD
C   COMPUTE TAKE-OFF ANGLES ASSUMING 4/3 EARTH RADIUS
      R4THD=RERTH*4.0/3.0
      GC=0.75*GC
      SGC=DSIN(0.5*GC)
      P=2.0*SGC*SGC
      AALT=R4THD+AHT
      BALT=R4THD+BHT
      DA=DSQRT(DELHT*DELHT+2.0*AALT*BALT*P)
      SAELV=0.5*(DA*DA+DABS(DELHT)*(AALT+BALT))/(DA*AALT)
      ARG=DMAX1(0.0D0,(1.0D0-SAELV*SAELV))
      ATAKOF=DATAN(SAELV/DSQRT(ARG))
      BTAKOF=(ATAKOF-GC)*RTOD
      ATAKOF=-ATAKOF*RTOD
      IF (DELHT .LT. 0.0) THEN
        ZTELV=AELV
        ZRELV=BELV
        ZTAKOF=ATAKOF
        ZRAKOF=BTAKOF
        RETURN
      ELSE
        ZTELV=BELV
        ZRELV=AELV
        ZTAKOF=BTAKOF
        ZRAKOF=ATAKOF
        RETURN
      END IF
C
C     COMPUTE END POINT GIVEN DISTANCE AND BEARING
C
200   TLATR=ZTLAT*DTOR
      TLONR=ZTLON*DTOR
      TAZR=ZTAZ*DTOR
      GC=ZDGC/RERTH
      COLAT=PI/2.0 - TLATR
      COSCO=DCOS(COLAT)
      SINCO=DSIN(COLAT)
      COSGC=DCOS(GC)
      SINGC=DSIN(GC)
      COSB=COSCO*COSGC + SINCO*SINGC*DCOS(TAZR)
      ARG=DMAX1(0.0D0,(1.0D0-COSB*COSB))
      B=DATAN2(DSQRT(ARG),COSB)
      ARC=(COSGC-COSCO*COSB)/(SINCO*DSIN(B))
      ARG=DMAX1(0.0D0,(1.0D0-ARC*ARC))
      RDLON=DATAN2(DSQRT(ARG),ARC)
      ZRLAT=(PI/2.0 - DABS(B))*RTOD
      DRLAT=ZRLAT
      ZRLAT=DSIGN(DRLAT,COSB)
      ZRLON=ZTLON+(DABS(RDLON)*RTOD)
      IF(ZTAZ .GT. 180) ZRLON=ZTLON-(DABS(RDLON)*RTOD)
      THTS=ZTHT*1.0E-3
      RHTS=ZRHT*1.0E-3
      DELHT=RHTS-THTS
      SGC=DSIN(0.5*GC)
      D=DSQRT(DELHT*DELHT+4.0*(RERTH+THTS)*(RERTH+RHTS)*SGC*SGC)
      GO TO 142
      END SUBROUTINE
C------------------------------------------------------------------
