#!/usr/bin/env bash
# linkweb-jq.sh is a wtjq replacement for linkweb.sh.

MODELIVE="live-gen"
MODEDRY="dry-run"

# Source jq wrapper functions
. init-wt.sh

# Test if we have ssg installed
if command -v ssg; then
	ssg_cmd="ssg";
else
	get_ssg;
	ssg_cmd="bin/ssg";
fi

main() {
	if [ ! -z $1 ] && [ "$1" != "-"* ]; then
	# PROG sitename;
	# PROG sitename -n;
		sitekey="$1";
		runflag="$2";
		gen_func="gen_one_site";
		data=$(get_site_from_file_json "${sitekey}");

		[ -z $data ]\
			&& die "no sitekey $sitekey found";
	else
	# PROG
	# PROG -n
	# PROG -a;
	# PROG -a -n;
		announce "all sites mode"
		if [ -z $1 ]; then
		# PROG
			runflag="";
		elif [[ $1 == "-a" ]]; then
		# PROG -a;
		# PROG -a -n;
			runflag="$2"
		else
		# PROG -n
			runflag="$1"
		fi

		data=$(get_all_sites_json);
		gen_func="gen_many_sites";
	fi

	case $runflag in
		"-n")
			runmode="$MODEDRY"; ;;
		*)
			runmode="$MODELIVE"; ;;
	esac

	"${gen_func}" "$runmode" "$data";
}

gen_many_sites() {
	runmode=$1;
	sites=$2;

	for site in ${sites[@]}; do
		gen_one_site "$runmode" $site
	done;
}

gen_one_site() {
	runmode="$1";
	site="$2";

	name=$(get_name_json "$site");
	url=$(access_field_json "$site" "url");
	src=$(access_field_json "$site" "src");
	dist=$(access_field_json "$site" "dist");

	src=$(echo $src | tr -d '"');
	dist=$(echo $dist | tr -d '"');

	if [[ $runmode == $MODELIVE ]]; then
		if simyn "Generate distribution (HTML) files for $name?"; then
			[ ! -d $dist ] && mkdir -p $dist;
			"$ssg_cmd" "$src" "$dist" "$name" "$url"\
				&&simyn "Minify $dist with minify.py?"\
					&& ./minify.py "$dist";
		fi
	fi


	echo "[$PROG] Site $name ($name $url)"
	echo "[$PROG] $src -> $dist"
}

main $1 $2;
