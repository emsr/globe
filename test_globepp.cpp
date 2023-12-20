
#include <iostream>

#include "globe.h"

int
main()
{
  using std::cin, std::cout;

  float tx_lat = 0.0F;
  cout << "Enter Tx lat: ";
  cin >> tx_lat;

  float tx_lon = 0.0F;
  cout << "Enter Tx lon: ";
  cin >> tx_lon;

  float rx_lat = 0.0F;
  cout << "Enter Rx lat: ";
  cin >> rx_lat;

  float rx_lon = 0.0F;
  cout << "Enter Rx lon: ";
  cin >> rx_lon;

  int num_pts = 0;
  cout << "Enter num pts: ";
  cin >> num_pts;

  cout << "tx_lat  : " << tx_lat << '\n';
  cout << "tx_lon  : " << tx_lon << '\n';
  cout << "rx_lat  : " << rx_lat << '\n';
  cout << "rx_lon  : " << rx_lon << '\n';
  cout << "num_pts : " << num_pts << '\n';

  float prfl[2000];
  int ierror = 0;
  get_profile (tx_lat, tx_lon, rx_lat, rx_lon, num_pts, prfl, &ierror);

  cout << "ierror  : " << ierror << '\n';
  cout << "num_pts : " << int(prfl[0]) << '\n';
  cout << "delta   : " << prfl[1] << '\n';
  for (int i = 0; i < num_pts; ++i)
    cout << ' ' << prfl[2 + i] << '\n';
}
