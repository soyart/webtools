#!/usr/bin/env bash

# Initializes environment for webtools scripts

announce() {
	echo "[$0] $@"
}

die() {
	echo "[$0] $@" >&2
	exit 1
}

# Read manifest.json to MANIFEST
[ -f "manifest.json" ] || die "init-wt.sh" "manifest.json is not a file";
MANIFEST=$(< ./manifest.json);

PROG=${0#'./'}

set -o pipefail

# Get non-webtools dependencies, e.g. ssg, yn.sh, and lb.sh
. netget.sh;
get_shtools;
. bin/yn.sh;
. bin/lb.sh;

# Source helper functions from wtutils
. wtutils.sh
