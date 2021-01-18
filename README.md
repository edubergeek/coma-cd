# coma-cd
Scripts to parse CDROMs containing FITS files of comet observations
- cd.sh       - main script to process FITS files found in $SCANDIR/INCOMING $SCANDIR/VALIDATED directories and construct a link hierarchy to the FITS files rooted in $LINKDIR
-- fitsinfo    - bash script to run Jan's coma pipeline to obtain FITS header values
-- map_dir     - PDS4 bundle/collection/product mapping from directory names
-- map_telinst - PDS4 collection from union of telescope and instrument
-- map_object  - PDS4 bundle/product from object info
-- scan        - process the FITS files in a given directory

