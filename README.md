
This camse from:  
https://its.ntia.gov/research-topics/radio-propagation-software/globe/globe-1-0-elevation-extraction-subroutines/

Paul McKenna looks after Globe and many other things at ITS:  
pmckenna@its.bldrdoc.gov

The data is next door in ../GLOBE/
and is from:  
https://its.ntia.gov/research-topics/radio-propagation-software/resampled-terrain-data/re-sampled-terrain-data/

So you don't actually have to byte-swap on a Linux system on a PC.  
- [ ] It would be smarter to detect endianness  
- [ ] It would be smarter to take the GLOBE data path as a parameter or  
- [ ] Ditto the GLOBE.DAT  

I also had to go into the ../GLOBE/GLOBE.DAT file and make the file names upper case
to match the case of te filenames in that directory.
