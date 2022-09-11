#!/usr/bin/env bash

# linkweb-jq.sh is a wtjq replacement for linkweb.sh,
# but it only 1 website at a time, not all (yet).

test -z $1 && usage;

. init-jq.sh $1;

PROGNAME=${0#'./'}
MODELIVE="live-links"
MODEDRY="dry-run"
MODECLEAN="clean-links"

main() {
	case $1 in
		"-n")
			runmode="$MODEDRY"; ;;
		"-c")
			runmode="$MODECLEAN"; ;;
		*)
			runmode="$MODELIVE"; ;;
	esac

	# For now only single website per run is supported
	read_manifest_single_site $runmode;
}


usage() {
	echo "[${PROGNAME}]: multi-site linking not supported";
	echo "[${PROGNAME}]: Please provide your JSON manifest key";
	echo "[${PROGNAME}]: e.g. './linkweb.sh myblog'";
	exit 1;
}

read_manifest_single_site() {
	LINKSMAP=$(echo ${SITEDATA_JSON} | jq -c '.links');
	LSOURCES=$(echo ${LINKSMAP} | jq -c 'keys | .[]');

	looplink "$LINKSMAP" "$LSOURCES" "$runmode";
}

rmlink() {
	test -L "$1" && rm "$1";
}

looplink() {
	links="$1";
	lsources="$2";
	runmode="$3";
	echo "$runmode"

	for src in ${lsources[@]}; do
		# These strings contain double quotes
		dst=$(echo $links | jq -c ".$src");

		# Remove double quotes from string literals
		src=$(echo $src | tr -d '"');
		dst=$(echo $dst | tr -d '"');
			
		# Convert to full, absolute path
		pwdir="$(pwd)";
		src="$(find $pwdir -wholename $pwdir/$src)";
		dst="$pwdir/$dst";
	
		if ! [ -r "$src" ]; then
			echo "file $src not readable, skipping";
			continue;
		fi;

		case $runmode in
			"$MODECLEAN")
				rmlink "$dst"; ;;
			"$MODELIVE")
				rmlink "$dst";
				ln -s "$src" "$dst"; ;;
		esac
		echo "[$PROGNAME] $src -> $dst ($runmode)";
	done
}

main $2;
