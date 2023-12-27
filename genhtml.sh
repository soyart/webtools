#!/usr/bin/env bash

# Source jq wrapper functions
. init-wt.sh

MODELIVE="live-gen"
MODEDRY="dry-run"

# Test if we have ssg installed
if command -v ssg; then
	ssg_cmd="ssg";
else
	get_ssg;
	ssg_cmd="bin/ssg";
fi

main() {
	if [ ! -z $1 ] && [ "$1" != "-"* ]; then
		# Examples
		# PROG sitename;
		# PROG sitename -n;
		announce "Single-site mode"

		local sitekey="$1";
		local runflag="$2";
		local gen_func="gen_one_site";
		local data=$(get_site_from_file_json "${sitekey}");

		[ -z $data ]\
			&& die "no sitekey $sitekey found";
	else

		# Examples:
		# PROG
		# PROG -n
		# PROG -a;
		# PROG -a -n;
		announce "All sites mode"

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
	local runmode=$1;
	local sites=$2;

	for site in ${sites[@]}; do
		gen_one_site "$runmode" $site;
	done;
}

gen_one_site() {
	local runmode="$1";
	local site="$2";

	local name=$(get_name_json "$site");
	local url=$(access_field_json "$site" "url");
	local src=$(access_field_json "$site" "src");
	local dist=$(access_field_json "$site" "dist");

	src=$(echo $src | tr -d '"');
	dist=$(echo $dist | tr -d '"');

	if [[ $runmode == $MODELIVE ]]; then
		if simyn "Generate distribution (HTML) files for $name?"; then

			# mkdir if not exists
			[ ! -d $dist ] && mkdir -p $dist;

			# Execute ssg, and then minify.py
			"$ssg_cmd" "$src" "$dist" "$name" "$url"\
				&& simyn "Minify $dist with minify-html.py?"\
				&& ./minify-html.py "$dist";

		fi;
	fi;


	announce "[$PROG] Site $name ($name $url)"
	announce "[$PROG] $src -> $dist"
}

main $@;
