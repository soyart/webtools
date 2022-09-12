#!/usr/bin/env bash
# linkweb-jq.sh is a wtjq replacement for linkweb.sh.

PROG=${0#'./'}
MODELIVE="live-links"
MODEDRY="dry-run"
MODECLEAN="clean-links"

# Source jq wrapper functions
. init-jq.sh

main() {
	if [ -z $2 ] || [ $1 == "-*" ]; then
	# PROG
	# PROG -n
	# PROG -a;
	# PROG -a -n;
		echo "[$PROG] all sites mode"
		[ -z $1 ]\
			&& runflag="";
		[[ $1 == "-a" ]]\
			&& runflag=$2\
			|| runflag=$1;

		link_func="link_many_sites";
		data=$(get_all_sites_json);
	else
	# PROG sitename;
	# PROG sitename -n;
		sitekey="$1";
		runflag="$2";
		link_func="link_one_site";
		data=$(get_site_from_file_json "${sitekey}");
		sitename=$(get_name_json "$data");
	fi

	case $runflag in
		"-n")
			runmode="$MODEDRY"; ;;
		"-c")
			runmode="$MODECLEAN"; ;;
		*)
			runmode="$MODELIVE"; ;;
	esac

	"${link_func}" "$runmode" "$data" "$sitename";
}

link_many_sites() {
	runmode=$1;
	data_json=$2;
	sites=$(echo $data_json | jq -c 'keys | .[]');

	for site in ${sites[@]}; do
		sitedata=$(access_field_json $data_json $site);
		sitename=$(get_name_json $sitedata);
		link_one_site "$runmode" "$sitedata" "$sitename";
	done;
}

link_one_site() {
	runmode="$1";
	sitedata="$2";
	sitename="$3";

	links_map=$(echo $sitedata | jq -c '.links');
	links_sources=$(echo $links_map | jq -c 'keys | .[]');

	wrapped_looplink "$runmode" "$links_map" "$links_sources" "$sitename";
}

wrapped_looplink() {
	runmode=$1;
	linksmap=$2;
	sources=$3;
	sitename=$4;

	simyn "[$PROG] Run for $sitename ($runmode)?"\
		&& looplink "$linksmap" "$sources" "$runmode";
}

looplink() {
	site_links="$1";
	link_sources="$2";
	runmode="$3";

	for src in ${link_sources[@]}; do
		# These strings contain double quotes
		dst=$(echo $site_links| jq -c ".$src");

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
		echo "[$PROG] $src -> $dst ($runmode)";
	done
}

rmlink() {
	test -L "$1" && rm "$1";
}

main $1 $2;
