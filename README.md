Access to Global Land One-kilometer Base Elevation (GLOBE)
----------------------------------------------------------

This came from:  
https://its.ntia.gov/research-topics/radio-propagation-software/globe/globe-1-0-elevation-extraction-subroutines/

Paul McKenna looks after Globe and many other things at ITS:  
pmckenna@its.bldrdoc.gov

The data is next door in ../GLOBE/
and is from:  
https://its.ntia.gov/research-topics/radio-propagation-software/resampled-terrain-data/re-sampled-terrain-data/

So you don't actually have to byte-swap on a Linux system on a PC.  

Ideas:  
- [ ] It would be smarter to detect endianness and filenames (see below) and merge subspc.f and subsunix.f.  
- [ ] It would be smarter to take the GLOBE data path as a parameter or an environment variable.  
- [ ] Ditto for the GLOBE.DAT file.  
- [ ] Take a profile filename and write out to that.  
- [ ] We could make a callable C wrapper with a header and a library...  
- [ ] It would be nice to report the data step size (it's 1 km or 30 sec).  
- [ ] It would be nice to have a version that takes a trial stepsize and does the usual tweak of stepsize and num_points.  

I also had to go into the ../GLOBE/GLOBE.DAT file and make the file names upper case
to match the case of the filenames in that directory.
