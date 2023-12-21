      function GLOBE_elevation(xxlon,xxlat)
c************************************************************
c          extract the GLOBE elevation for (xxlon,xxlat)
c          GLOBE_elevation= elevation in meters of point
c                         = < -500 = file does not exist
c                           This should only happen if your data files
c                           are not in the directory specified by path.
c          NOTE: GLOBE flags ocean values as -500.
c                These routines change any -500 value to 0.
c                If you wish to identify ocean values, you should modify
c                the code in get_GLOBE_data to suit your needs.
c************************************************************
c          The elevation of the 4 points that contain the 
c          (xxlon,xxlat) are found and the elevation is interpolated.
c          The 4 points are:
c                   2   3
c                   1   4
c************************************************************
c          In order to get the same value at Latitude=-90
c          regardless of longitude, any Latitude below -89.99167
c          has been forced to = 2777 meters elevation.
c          This is because the lowest latitude data record
c          corresponds to latitude=-89.9916666666...,
c          which is NOT the South Pole, and the values at
c          different longitude are slightly different.
c************************************************************
      common /C_GLOBE_init/ lu_globe,path,tiles(16)
	 character path*60,tiles*4
      dimension z(4)
      save ionce
      data ionce/0/
c*************************************************************
      if(ionce.eq.0) then     !  read in names of the Globe data base files
         ! set directory path location to GLOBE data base
         path='/home/ed/work/GLOBE/' !  (unix systems use '/')
	 lu_globe=61                 !  FORTRAN unit number used to OPEN Globe files
	 open(lu_globe,file=trim(path)//'GLOBE.DAT',
     +        status='old',iostat=ios,err=920)
	 rewind(lu_globe)
	 read(lu_globe,'(a)') tiles(1)
         do i=1,16         !  read data for the 16 tiles
           read(lu_globe,'(a)') tiles(i)
         end do
	 close(lu_globe)
	 ionce=1
      end if
c*************************************************************
      if(xxlat.lt.-89.99167) then       !  force South Pole = 2777 meters
	 GLOBE_elevation=2777
	 return
      end if
      xlon=xxlon
      if(xlon.lt.0.) xlon=xlon+360.     !  make xlon [0 - 360]
      xlat=xxlat
      call GLOBE_index(xlat,xlon,ix,iy,dx,dy)    !  get (ix,iy) cell that contains (xlat,xlon)
      call GLOBE_record(ix,iy,itile,irec)
      call get_GLOBE_data(itile,irec,z(1),*900)  !  get elevation of point #1
      iy2=iy+1                          !  move 1 cell north
      if(iy2.gt.21599) iy2=21599        !  maximum cell north
      call GLOBE_record(ix,iy2,itile,irec)
      call get_GLOBE_data(itile,irec,z(2),*900)  !  get elevation of point #2
      ix2=ix+1                          !  move 1 cell east
      if(ix2.gt.43199) ix2=0            !  wrap around
      call GLOBE_record(ix2,iy2,itile,irec)
      call get_GLOBE_data(itile,irec,z(3),*900)  !  get elevation of point #3
      call GLOBE_record(ix2,iy,itile,irec)
      call get_GLOBE_data(itile,irec,z(4),*900)  !  get elevation of point #4
      elevation=GLOBE_interp(dx,dy,z)   !  interpolate to find elevation at (xlat,xlon)
      go to 910
c          file does not exist
900   elevation =-501.                  !  flag invalid elevation value
910   GLOBE_elevation=nint(elevation)
      return
920   write(*,921) ios,trim(path)//'GLOBE.DAT'
921   format(' OPEN error=',i5,' file=',a)
      stop 'OPEN error in  GLOBE_elevation'
      end

c-----------------------------------------------------------------
      subroutine get_GLOBE_data(itile,irec,elev,*)
c**********************************************************************
c          Look in this routine for changes you need to make depending
c          on your computer system.  PCs do not need byte swaping,
c          while unix systems do.  Macs are not known.
c**********************************************************************
c          open a GLOBE data file and get the elevation corresponding
c          to a particular cell corner.
c
c          itile = tile number of data file [1 to 16]
c          irec  = record number of the cell to read
c          elev  = returned elevation value in meters.
c                  The GLOBE database contains -500 to signify ocean.
c                  That value is converted to 0.
c                  If you wish to do something different, do so in the routine.
c**********************************************************************
      common /C_GLOBE_init/ lu_globe,path,tiles(16)
	 character path*60,tiles*4
      integer*2 data!!, mask
      integer*4 byte1,byte2
      save last_tile
      !!data mask/255/
      data last_tile/0/
c********************************************************************
c          do we need to open a new data file?
      if(last_tile.ne.itile) then       !  open a new GLOBE file
         if(last_tile.ne.0) close(lu_globe)
         open(lu_globe,file=trim(path)//tiles(itile),
     +        access='direct',recl=2,status='old',iostat=ios,err=900)
	 last_tile=itile
      end if
c********************************************************************
      read(lu_globe,rec=irec,err=910) data
ccc      write(*,'('' data='',i10)') data
c***********************************************************
c***********************************************************
c          The following line should be commented when you change the
c          appropriate lines below.
c      stop 'You MUST fix subroutine get_GLOBE_data for your system!'
c***********************************************************
c          For PC systems, 'data' is OK
c***********************************************************
c***********************************************************
c          For unix systems, 'data' MUST be byte swapped
c          The following 3 lines should be uncommented for unix systems.
c***********************************************************
      !!byte1=iand(data,mask)                !  byte swap for unix systems
      !!byte2=ibits(data,8,8)               !  extract the upper 8 bits
cxxx      idata32=data                    !  if your FORTRAN does not have the
cxxx      byte2=0                         !  function ibits, use mvbits
cxxx      call mvbits(idata32,8,8,byte2,0)
      !!data=byte1*256 + byte2              !  byte swap
c***********************************************************
      if(data.eq.-500) data=0             !  ocean = 0
      elev=data
c***********************************************************
c***********************************************************
      return
900   last_tile=0
      write(*,901) ios,trim(path)//tiles(itile)
901   format(' OPEN error=',i5,' file=',a)
      return 1
910   continue
      write(*,'(''Filename='',a,''  irec='',i10)') tiles(itile),irec
      stop 'Should not get here in get_GLOBE_data'
      end
c-----------------------------------------------------------------
      subroutine GLOBE_record(ix,iy,itile,irec)
c          Given: (ix,iy) - the Globe cell location
c          Find:  itile - tile index containing (ix,iy)
c                 irec  - record number within itile containing elevation
      icol=mod(ix,10800)
      jx=ix/10800 + 1
      if(iy.ge.16800) then
	 jy=0                              !  Tiles ABCD
	 irow=21600-iy
      else if(iy.ge.10800) then
	 jy=1                              !  Tiles EFGH
	 irow=16800-iy
      else if(iy.ge. 4800) then
	 jy=2                              !  Tiles IJKL
	 irow=10800-iy
      else if(iy.ge.    0) then
	 jy=3                              !  Tiles MNOP
	 irow=4800-iy
      end if
      itile=jx + jy*4
      irec=(irow-1)*10800 + icol + 1
      return
      end
c---------------------------------------------------------
      subroutine GLOBE_index(xlat,xlon,ix,iy,dx,dy)
c          given: (xlat,xlon)
c          find:  (ix,iy) of lower left corner of cell containing (xlat,xlon)
c                         ix will range from [0 to 43199].
c                             0 = -179.99583 longitude
c                         iy will range from [0 to 21599].
c                             0 = -89.99583
c                 (dx,dy) is used to interpolate. It is the fraction of cell
c                         where (xlat,xlon) is located.
c          Note: Globe data base cell size = 30 seconds = 1/120 degree = .0083333
      real*8 dlat,dlon,x,y
      dlat=xlat+90.D0
      y=dlat*120.D0 -.5D0
      iy=y
      dlon=xlon
      if(xlon.lt.0.) dlon=dlon+360.D0
      if(dlon.ge.180.D0) then
	 x=(dlon-180.D0)*120.D0 - .5D0
	 if(x.lt.0.D0) x=x+43200.D0
      else
	 x=(dlon+180.D0)*120.D0 - .5D0
      end if
      ix=x
      dx=x-dfloat(ix)
      dy=y-dfloat(iy)
      if(dy.lt.0.D0) then                  !  South Pole flag
	 iy=0
	 dy=0.
      end if
      return
      end
c---------------------------------------------------------
      function GLOBE_interp(dx,dy,z)
c          bilinear interpolation routine
      dimension z(4)
      z12=z(1) + (z(2)-z(1))*dy
      z43=z(4) + (z(3)-z(4))*dy
      zp=z12 + (z43-z12)*dx
      GLOBE_interp=zp
      return
      end
c-------------------------------------------------------
