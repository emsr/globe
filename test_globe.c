
#include <stdio.h>

#include "globe.h"

int
main()
{
  float tx_lat = 0.0F;
  printf("Enter Tx lat: ");
  scanf("%f", &tx_lat);

  float tx_lon = 0.0F;
  printf("Enter Tx lon: ");
  scanf("%f", &tx_lon);

  float rx_lat = 0.0F;
  printf("Enter Rx lat: ");
  scanf("%f", &rx_lat);

  float rx_lon = 0.0F;
  printf("Enter Rx lon: ");
  scanf("%f", &rx_lon);

  int num_pts = 0;
  printf("Enter num pts: ");
  scanf("%d", &num_pts);

  printf("tx_lat : %f\n", tx_lat);
  printf("tx_lon : %f\n", tx_lon);
  printf("rx_lat : %f\n", rx_lat);
  printf("rx_lon : %f\n", rx_lon);
  printf("num_pts: %d\n", num_pts);

  float prfl[2000];
  get_profile(tx_lat, tx_lon, rx_lat, rx_lon, num_pts, prfl);

  printf("num_pts : %d\n", (int)prfl[0]);
  printf("delta   : %f\n", prfl[1]);
  for (int i = 0; i < num_pts; ++i)
    printf("  %f\n", prfl[2 + i]);
}
