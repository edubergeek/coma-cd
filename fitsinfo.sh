#!/bin/bash

declare -a arr
comaapi=/Software/lisp-lib/astro/COMA-PROJECT/Scripts/coma-json-server
cat <<EOF | $comaapi | jq  | awk -F: '/^ *"/ {if(NR > 5)printf("%s=%s\n",$1,$2);}' | sed 's/,$//' | sed 's/"//' | sed 's/"//' | sed 's/= /=/' | sed -e 's/FITS-FILE/FITSFILE/' -e 's/MJD-MID/MJDMID/' -e 's/OBJECT-NAME/OBJECTNAME/' -e 's/NAME-PARSED/CODE/' >/tmp/cdodds
{
    "type":"request",
    "command":"describe-fits",
    "id":"123abc",
    "parameters": {"FITS-FILE":"$1"}
}
EOF

source /tmp/cdodds 2>/dev/null

echo INSTRUME=$INSTRUMENT
echo TELESCOP=$OBSERVATORY
echo MJD=$MJDMID
echo OBJECT=$OBJECTNAME
echo DATE=
#echo $OBJECTCODE

