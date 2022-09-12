#!/usr/bin/env bash
# linkweb-jq.sh is a wtjq replacement for linkweb.sh.

PROG=${0#'./'}
MODELIVE="live-gen"
MODEDRY="dry-run"

# Source jq wrapper functions
. init-jq.sh

# Test if we have ssg installed
if command -v ssg; then
	ssg_cmd="ssg";
else
	get_ssg;
	ssg_cmd="bin/ssg";
fi

main() {
	if [ -z $2 ] || [[ $1 == "-*" ]]; then
	# PROG
	# PROG -n
	# PROG -a;
	# PROG -a -n;
		echo "[$PROG] all sites mode"
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
	else
	# PROG sitename;
	# PROG sitename -n;
		sitekey="$1";
		runflag="$2";
		gen_func="gen_one_site";
		data=$(get_site_from_file_json "${sitekey}");
		[ -z $data ]\
			&& echo "[$PROG] no sitekey $sitekey found"\
			&& exit 1
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
		simyn "Generate distribution (HTML) files for $name?"\
		&& "$ssg_cmd" "$src" "$dist" "$name" "$url"\
		|| return;
	fi

	echo "[$PROG] Site $name ($name $url)"
	echo "[$PROG] $src -> $dist"
}

main $1 $2;
