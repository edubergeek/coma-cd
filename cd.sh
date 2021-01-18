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

fitsinfo=$HOME/Projects/coma-cd/fitsinfo.sh

function tree() {
	find $1 -type 'd' -depth -print
}

function map_dir() {
	case "$1" in
	*[dD][aA][rR][kK]*)
		product=dark
		bundle=dark;;
	*[bB][iI][aA][sS]*)
		product=bias
		bundle=bias;;
	*[fF][lL][aA][tT]*)
		product=flat
		bundle=flat;;
	*[tT][wW][iI]*)
		product=twilight
		bundle=flat;;
	*)
		product=data;;
	esac

	echo $product $bundle
	return 0
}
	
function map_telinst() {
	case "$1-$2" in
	"-") return 1;;

	-*) collection="$2";;
	*-) collection="$1";;
	*) collection="$1-$2";;
	esac

	echo $collection
	return 0
}

function map_object() {
	case "$1" in
	"") return 1;;

	*[dD][aA][rR][kK]*)
		product=dark
		bundle=dark;;
	*[bB][iI][aA][sS]*)
		product=bias
		bundle=bias;;
	*[fF][lL][aA][tT]*)
		product=flat
		bundle=flat;;
	*[tT][wW][iI][lL]*)
		product=twilight
		bundle=flat;;
	*) bundle="$1";;
	esac

	echo $bundle $product
	return 0
}

function toJD() {
	echo $1
	return 0
}

function scan() {
	dir=$1
	ls $dir | grep '\.' | while read fits
	do
		eval `bash $fitsinfo $dir/$fits`
		# map subdirectory and file name to PRODUCT and/or BUNDLE
		map=`map_dir "$dir"`
		read PRODUCT BUNDLE <<< "$map"

		# map telescope and instrument into a PDS4 "collection"
		COLLECTION=`map_telinst "$TELESCOP $INSTRUME"`
		nolink=$?

		# map $OBJECT to BUNDLE/PRODUCT
		map=`map_object "$OBJECT"`
		if [ $? -eq 0 ]
		then
			read BUNDLE PRODUCT <<< "$map"
		else
			nolink=$?
		fi

		# convert mm/dd/yyyy format to JD (MJD?)
		case "$JD-$DATE" in
		"") nolink=1 ;;
		-*) JD=`toJD "$DATE"` ;;
		esac

		# If we can create a link do so otherwise print out what we have
		case $nolink in
		0)
			# For now just print it out
			echo $BUNDLE $COLLECTION $PRODUCT $JD $dir/$fits

			# make sure the bundle/collection/product path exists
			#mkdir -p $LINKDIR/$BUNDLE/$COLLECTION/$PRODUCT/$JD

			# link the FITS file there
			#ln -s $dir/$fits $LINKDIR/$BUNDLE/$COLLECTION/$PRODUCT/$JD/$fits
			;;
		*)
			# Link is not possible so dump what we have
			echo obj=$OBJECT tel=$TELESCOP ins=$INSTRUM bun=$BUNDLE col=$COLLECTION pro=$PRODUCT jd=$JD fits=$dir/$fits >&2
			;;
		esac
		break
	done
}

# process root directories INCOMING and VALIDATED
for scan in $dirs
do
	cd ${SCANDIR}/$scan
	# recursively descend through the current root directory
	tree $SCANDIR/$scan | while read cdrom
	do
		cd $cdrom
		ls $cdrom | grep '\.' >/dev/null 2>&1
		case $? in
		0)
			# found a directory with files having extensions (presumably FITS) so scan it
			scan $cdrom
			;;
		*)
			find $cdrom -type 'f' -depth 1 >>/tmp/cd.err 2>&1
			;;
		esac
	done
		
done

exit 0
