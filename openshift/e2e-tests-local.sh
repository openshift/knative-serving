#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$0")/e2e-common.sh"

set -x

env

failed=0

(( !failed )) && prepare_knative_serving_tests || failed=1
(( !failed )) && run_e2e_tests "$TEST" || failed=2
(( failed )) && dump_cluster_state
(( failed )) && exit $failed

success
