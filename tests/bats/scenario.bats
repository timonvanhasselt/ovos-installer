#!/usr/bin/env bats

function setup() {
    load "$HOME/shell-testing/test_helper/bats-support/load"
    load "$HOME/shell-testing/test_helper/bats-assert/load"
    load ../../utils/constants.sh
    load ../../utils/common.sh
    LOG_FILE=/tmp/ovos-installer.log
    SCENARIO_ALLOWED_OPTIONS=(features channel share_telemetry profile method uninstall rapsberry_pi_tuning)
    SCENARIO_ALLOWED_FEATURES=(skills gui)
}

@test "function_download_yq_file_removal" {
    run touch /tmp/yq
    function uname() {
        if [ "$1" == "-m" ]; then
            echo "x86_64"
        elif [ "$1" == "-s" ]; then
            echo "Linux"
        fi
    }
    function curl() {
        exit 0
    }
    export -f uname curl
    run download_yq
    assert_success
    unset uname curl
}

@test "function_download_yq_download_linux_amd64" {
    function uname() {
        if [ "$1" == "-m" ]; then
            echo "x86_64"
        elif [ "$1" == "-s" ]; then
            echo "Linux"
        fi
    }
    function curl() {
        exit 0
    }
    export -f uname curl
    run download_yq
    assert_success
    unset uname curl
}

@test "function_download_yq_download_linux_arm64" {
    function uname() {
        if [ "$1" == "-m" ]; then
            echo "aarch64"
        elif [ "$1" == "-s" ]; then
            echo "Linux"
        fi
    }
    function curl() {
        exit 0
    }
    export -f uname curl
    run download_yq
    assert_success
    unset uname curl
}

@test "function_download_yq_download_linux_arm65" {
    function uname() {
        if [ "$1" == "-m" ]; then
            echo "arm65"
        elif [ "$1" == "-s" ]; then
            echo "Linux"
        fi
    }
    function curl() {
        exit 1
    }
    export -f uname curl
    run download_yq
    assert_failure
    unset uname curl
}

@test "function_detect_scenario_directory_found" {
    SCENARIO_PATH=/tmp/ovos-installer
    detect_scenario
    assert_equal "$SCENARIO_FOUND" "false"
}

@test "function_detect_scenario_directory_not_found" {
    detect_scenario
    assert_equal "$SCENARIO_FOUND" "false"
}

@test "function_detect_scenario_found" {
    RUN_AS_HOME=/home/$USER
    ARCH="x86_64"
    run mkdir -p $RUN_AS_HOME/.config/ovos-installer
    run touch $RUN_AS_HOME/.config/ovos-installer/$SCENARIO_NAME
    detect_scenario
    assert_equal "$SCENARIO_FOUND" "true"
}

@test "function_detect_scenario_valid" {
    RUN_AS_HOME=/home/$USER
    cat <<EOF >$RUN_AS_HOME/.config/ovos-installer/$SCENARIO_NAME
---
uninstall: false
method: containers
channel: development
profile: ovos
features:
  skills: true
  gui: true
rapsberry_pi_tuning: true
share_telemetry: true
EOF
    run detect_scenario
    assert_success
}

@test "function_in_array_found" {
    run in_array SCENARIO_ALLOWED_OPTIONS uninstall
    assert_success
}

@test "function_in_array_not_found" {
    run in_array SCENARIO_ALLOWED_OPTIONS dukenukem
    assert_failure
}

function teardown() {
    rm -f "$LOG_FILE" /tmp/yq
    rm -rf "$SCENARIO_PATH"
}
