
module globe

  implicit none

  integer, parameter:: max_prfl = 5003

contains

  !
  ! Fill a terrain profile - elevation as a function of distance array
  ! for the given transmitter and receiver latitudes and longitudes.
  !
  subroutine get_profile(tx_lat, tx_lon, rx_lat, rx_lon, num_pts, prfl) bind(c)

    use iso_c_binding

    implicit none
    real(c_float), value :: tx_lat, tx_lon, rx_lat, rx_lon
    integer(c_int), value :: num_pts
    real(c_float) :: prfl(3 + num_pts)

    call get_globe_pfl(tx_lat, tx_lon, rx_lat, rx_lon, num_pts, prfl, *900)
    900 write(*,901)
    901 format('Error in get_GLOBE_pfl')

  end subroutine

  !
  ! Return the elevation at the given longitude and latitude.
  !
  integer function elevation(lat, lon) bind(c)

    use iso_c_binding

    implicit none
    real(c_float), value :: lat, lon
    integer globe_elevation

    elevation = globe_elevation(lon, lat)

  end function

end module
