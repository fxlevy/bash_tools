#!/usr/bin/env bash

# Credits
# https://github.com/DevelopersToolbox/bash-spinner

# -------------------------------------------------------------------------------- #
# Draw Spinner                                                                     #
# -------------------------------------------------------------------------------- #

function bt_draw_spinner() {
    local -a marks=('/' '-' '\' '|')
    local i=0

    bt_spinner_delay=${bt_spinner_delay:-0.10}
    bt_spinner_message=${1:-}

    while :; do
        printf '%s\r' "${marks[i++ % ${#marks[@]}]} $bt_spinner_message"
        sleep "${bt_spinner_delay}"
    done
}

function bt_draw_spinner_eval() {
    local -a marks=('/' '-' '\' '|')
    local i=0

    delay=${SPINNER_DELAY:-0.25}
    message=${1:-}

    while :; do
        message=$(eval "$1")
        printf '%s\r' "${marks[i++ % ${#marks[@]}]} $message"
        sleep "${delay}"
        printf '\033[2K'
    done
}

# -------------------------------------------------------------------------------- #
# Start Spinner                                                                    #
# -------------------------------------------------------------------------------- #

function bt_start_spinner() {
    if [ -z ${2+x} ]; then
        bt_color=$bt_color_reset
    else
        bt_color=$2
    fi
    printf ${bt_color}

    bt_spinner_message=${1:-}
    bt_draw_spinner "${bt_spinner_message}" &
    bt_spinner_pid=$!
    declare -g bt_spinner_pid
    trap bt_stop_spinner $(seq 0 15)
}

function bt_start_spinner_eval() {
    bt_spinner_command=${1}
    if [[ -z "${bt_spinner_command}" ]]; then
        echo "You MUST supply a command"
        exit
    fi

    bt_draw_spinner_eval "${bt_spinner_command}" &
    bt_spinner_pid=$!
    declare -g bt_spinner_pid
    trap bt_stop_spinner $(seq 0 15)
}

# -------------------------------------------------------------------------------- #
# Stop Spinner                                                                     #
# -------------------------------------------------------------------------------- #

function bt_stop_spinner() {
    if [[ "${bt_spinner_pid}" -gt 0 ]]; then
        kill -9 $bt_spinner_pid >/dev/null 2>&1
    fi
    bt_spinner_pid=0
    printf '\033[2K'
    printf ${bt_color_reset}
}
