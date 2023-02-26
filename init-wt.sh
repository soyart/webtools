#!/usr/bin/env bash

# This file provides frequently used jq wrappers for webtools scripts.

MANIFEST="./manifest.json"
PROG=${0#'./'}

set -o pipefail

# Get non-webtools dependencies, e.g. ssg, yn.sh, and lb.sh
. netget.sh;
get_unix;
. bin/yn.sh;
. bin/lb.sh;

# Source helper functions from wtutils
. wtutils.sh
