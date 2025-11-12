#!/bin/bash

# Standard DDEV add-on setup code taken from official DDEV add-ons.
setup() {
  set -eu -o pipefail
  export GITHUB_REPO=Metadrop/ddev-aljibe
  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  # shellcheck disable=SC2155
  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  # shellcheck disable=SC2155
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"

  mkdir -p ~/tmp
  # shellcheck disable=SC2155
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true

  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

check_installed () {
  # backstop is installed and can show its version
  echo "Checking backstopjs version with $(ddev backstopjs local version)" >&3
  ddev backstopjs local version | grep 'Command "version" successfully executed' >&3
}

check_backstopjs () {
  # Create reference bitmaps
  echo "Creating backstopjs references with $(ddev backstopjs local reference)" >&3
  ddev backstopjs local reference >&3
  # Test should pass because there is a reference bitmaps
  echo "Testing backstopjs references with $(ddev backstopjs local test)" >&3
  ddev backstopjs local test >&3
}

@test "Install latest commit" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  echo "Installed add-on from directory, restarting ddev" >&3
  ddev restart
  echo "Testing backstopjs" >&3
  check_installed
  check_backstopjs
}


#@test "Install latest release version" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "Aljibe already have the release version, running tests now"
#  echo "Testing backstopjs" >&3
#  check_installed
#  check_backstopjs
#}
