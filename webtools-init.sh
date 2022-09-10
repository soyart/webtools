#!/usr/bin/env bash

# This file is sourced everytime webtools.conf is sourced.

# Get non-webtools dependencies, e.g. ssg, yn.sh, and lb.sh
. netget.sh;
get_unix;
. yn.sh;
. lb.sh;

# Source other local variables.
# It is recommended that the 3 directories should be defined in the file $extras points to
extras="./extra_vars.sh";
test -f $extras && . "${extras}"\
	|| printf "did not source %s\n" "${extras}";

