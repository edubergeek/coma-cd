#/bin/bash

#TODO
# toss empty values
# collect ranked list of tokens found
# adjust date spanning overnight to earlier date
# detect multiple nights in one data set and split them

export SCANDIR=/Volumes/PDS/CDROMS
export LINKDIR=/Volumes/PDS/COMA
export RUNDIR=`pwd`

cp /dev/null /tmp/cd.err

dirs="INCOMING VALIDATED"

function tree() {
	find $1 -type 'd' -depth -print
}

function scan() {
	dir=$1
	ls $dir | grep '\.' | while read fits
	do
		eval `gethead -e $dir/$fits @$RUNDIR/keys`
		echo "$dir,$fits,$TELESCOP,$INSTRUME,$OBJECT,$JD,$DATE"

		nolink=0
		case "$dir" in
		"*[bB][iI][aA][sS]*") PRODUCT="cal";;
		"*[fF][lL][aA][tT]*") PRODUCT="flat";;
		"*[tT][wW][iI][lL]*") PRODUCT="flat";;
		"*") PRODUCT="raw";;
		esac

		case "$OBJECT" in
		"") nolink=1;;
		"*[bB][iI][aA][sS]*")
			PRODUCT="cal"
			BUNDLE="$OBJECT";;
		"*[fF][lL][aA][tT]*")
			PRODUCT="flat"
			BUNDLE="$OBJECT";;
		"*[tT][wW][iI][lL]*")
			PRODUCT="flat"
			BUNDLE="$OBJECT";;
		"*") BUNDLE="$OBJECT";;
		esac

		case "$TELESCOP-$INSTRUME" in
		"") nolink=1;;
		"-*") COLLECTION="$INSTRUME";;
		"*-") COLLECTION="$TELESCOP";;
		"*") COLLECTION="$TELESCOP-$INSTRUME";;
		esac

		case "$JD-$DATE" in
		"") nolink=1;;
		"-*") ;;
		"*-") DATE="$JD";;
		"*") DATE="$JD";;
		esac

		case $nolink in
		0)
			mkdir -p $LINKDIR/$BUNDLE/$COLLECTION/$PRODUCT/$DATE
			ln -s $dir/$fits $LINKDIR/$BUNDLE/$COLLECTION/$PRODUCT/$DATE/$fits
			;;
		esac
		break
	done
}

echo "Dir,File,Telescope,Instrument,Object,JD,DATE"
for scan in $dirs
do
	cd ${SCANDIR}/$scan
	tree $SCANDIR/$scan | while read cdrom
	do
		cd $cdrom
		ls $cdrom | grep '\.' >/dev/null 2>&1
		case $? in
		0)
			scan $cdrom
			;;
		*)
			find $cdrom -type 'f' -depth 1 >>/tmp/cd.err 2>&1
			;;
		esac
	done
		
done

exit 0
