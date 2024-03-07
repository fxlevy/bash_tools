#!/usr/bin/env bash

# -------------------------------------------------------------------------------- #
# Parameters inititalization.                                                      #
# -------------------------------------------------------------------------------- #

bt_tools_path=$(readlink -m $(dirname "${BASH_SOURCE[0]}"))

if ! [ ${bt_term_width+x} ]; then
    bt_term_width=$(tput cols)
fi

# -------------------------------------------------------------------------------- #
# Load Bash Tools dependency files.                                                #
# -------------------------------------------------------------------------------- #

source "${bt_tools_path}/bt_colors.sh"
source "${bt_tools_path}/bt_language.sh"
source "${bt_tools_path}/bt_spinner.sh"

# -------------------------------------------------------------------------------- #
# Functions to display a message in the terminal.                                  #
# -------------------------------------------------------------------------------- #

function bt_print_framed_border() {
    if [ -z ${1+x} ]; then
        bt_color=$bt_color_reset
    else
        bt_color=$1
    fi
    bt_border=$2
    printf "${bt_color}+${bt_border}$(printf -- '-%.0s' $(seq $((${bt_term_width} - ${#bt_border} - 2))))+${bt_color_reset}\n"
}

function bt_print_framed_message() {
    bt_message=$1
    if [ -z ${2+x} ]; then
        bt_color=$bt_color_reset
    else
        bt_color=$2
    fi
    bt_len=${#bt_message}
    bt_len=$((${bt_term_width} - bt_len - 3))
    bt_end="|$(printf -- ' %.0s' $(seq $((${bt_term_width} - 2))))|"
    bt_end=${bt_end: -$bt_len}
    printf "${bt_color}| ${bt_message} ${bt_end}${bt_color_reset}\n"
}

function bt_print_framed_title() {
    bt_message="$1"
    if [ -z ${2+x} ]; then
        bt_color=$bt_color_reset
    else
        bt_color=$2
    fi
    bt_print_framed_border $bt_color
    bt_print_framed_message "$bt_message" $bt_color
    bt_print_framed_border $bt_color
}

function bt_print_message() {
    bt_message=$1
    if [ -z ${2+x} ]; then
        bt_color=$bt_color_reset
    else
        bt_color=$2
    fi
    printf "${bt_color}#${bt_color_reset}\n"
    printf "${bt_color}# ${bt_message}${bt_color_reset}\n"
    printf "${bt_color}#${bt_color_reset}\n"
}

# -------------------------------------------------------------------------------- #
# Function to cancel the procedure.                                                #
# -------------------------------------------------------------------------------- #

function bt_script_cancel() {
    clear -x
    printf "${bt_color_reset}\n"
    bt_print_framed_border $bt_color_red
    bt_print_framed_message "$bt_ln_cancel" $bt_color_red
    bt_print_framed_border $bt_color_red
    bt_print_framed_message "$bt_ln_stop" $bt_color_red
    bt_print_framed_border $bt_color_red
    exit 1
}

# -------------------------------------------------------------------------------- #
# Function to exit the procedure due to a script execution error.                  #
# -------------------------------------------------------------------------------- #

function bt_script_error() {
    #    clear -x
    printf "${bt_Reset}\n"
    bt_print_framed_border $bt_color_red
    bt_print_framed_message "$bt_ln_script_error" $bt_color_red
    bt_print_framed_message "$1" $bt_color_red
    bt_print_framed_border $bt_color_red
    bt_print_framed_message "$bt_ln_stop" $bt_color_red
    bt_print_framed_border $bt_color_red
    exit 1
}

# -------------------------------------------------------------------------------- #
# Function to get 'sudo' password.                                                 #
# -------------------------------------------------------------------------------- #

function bt_get_sudo_password() {

    # Check if script was executed with elevated privilege
    if [[ $EUID = 0 ]]; then
        return
    fi

    # Check if the sudo password is already set
    if ! [ -z ${bt_sudo_password+x} ]; then
        return
    fi

    bt_try=3
    while [[ $bt_try > 0 ]]; do
        bt_wh_choice=$(whiptail --title "$bt_wt_password" --passwordbox "\n$bt_wm_password" --ok-button "$bt_wh_OK" --cancel-button "$bt_wh_cancel" \
            12 70 \
            "welcome" \
            3>&1 1>&2 2>&3)
        [ $? != 0 ] && bt_script_cancel
        clear -x
        bt_sudo_password=$bt_wh_choice
        sudo -k # make sure to ask for password on next sudo
        if ! $(echo ${bt_sudo_password} | sudo -S true 2>/dev/null); then
            whiptail --title "$bt_wh_error" --msgbox "$bt_ln_wrong_password" 12 60
            bt_try=$(($bt_try - 1))
        else
            clear -x
            return
        fi
    done
    clear -x
    bt_script_error "$bt_ln_wrong_password"

}

# -------------------------------------------------------------------------------- #
# Check if a package exists and install it if is missing.                          #
# -------------------------------------------------------------------------------- #

function bt_check_package() {
    bt_packages_list=$1
    dpkg -s $bt_packages_list >/dev/null 2>&1
    if [ $? != 0 ]; then
        bt_get_sudo_password
        clear -x
        bt_print_framed_title "${bt_ln_install_package}" $bt_color_yellow
        sudo apt install -qq $bt_packages_list -y
        sleep 1
    fi
}

# -------------------------------------------------------------------------------- #
# Display a banner                                                                 #
# -------------------------------------------------------------------------------- #

function bt_display_banner() {
    if [ -z ${2+x} ]; then
        bt_color=$bt_color_reset
    else
        bt_color=$2
    fi

    tput civis
    printf $bt_color
    clear -x

    IFS=',' read -r -a bt_banner_texts <<<"$1"
    tput cup $(($(tput lines) / 2 - $((${#bt_banner_texts[@]} * 4))))
    for bt_banner_text in "${bt_banner_texts[@]}"; do
        figlet -t -f big -c $bt_banner_text
    done

    sleep 2
    printf $bt_color_reset
    tput cnorm
    clear -x
}

# -------------------------------------------------------------------------------- #
# Wait for key to be pressed to continue.                                          #
# -------------------------------------------------------------------------------- #

function bt_press_any_key_to_continue() {
    if [ -z ${1+x} ]; then
        bt_color=$bt_color_reset
    else
        bt_color=$1
    fi

    printf $bt_color
    read -n 1 -s -r -p "$bt_ln_press_any_key"
    printf $bt_color_reset
    printf "\n"
}

# -------------------------------------------------------------------------------- #
# Get latest software release number using Git API.                                #
# -------------------------------------------------------------------------------- #

function bt_get_latest_software_version_from_git() {

    [[ $1 = "" ]] && bt_script_error "$bt_param_missing"
    [[ $2 = "" ]] && bt_script_error "$bt_param_missing"

    bt_git_site="https://api.github.com"
    bt_git_user=$1
    bt_git_repo=$2

    bt_git_url="${bt_git_site}/repos/${bt_git_user}/${bt_git_repo}/releases/latest"
    bt_start_spinner "$bt_ln_latest_get_git_version '${bt_git_user}/${bt_git_repo}'"
    bt_git_page=$(wget -q -O - $bt_git_url)
    bt_stop_spinner
    bt_git_version=$(echo $bt_git_page | jq .tag_name | tr -d '"')
    if [[ $bt_git_version = "" ]]; then
        bt_script_error "$bt_ln_latest_error '${bt_git_user}/${bt_git_repo}'"
    fi
}

# -------------------------------------------------------------------------------- #
# Download zip source from Git.                                                    #
# -------------------------------------------------------------------------------- #

function bt_download_zip_source_from_git() {

    [[ $1 = "" ]] && bt_script_error "$bt_param_missing"
    [[ $2 = "" ]] && bt_script_error "$bt_param_missing"
    [[ $3 = "" ]] && bt_script_error "$bt_param_missing"
    [[ $4 = "" ]] && bt_script_error "$bt_param_missing"

    bt_git_site="https://github.com"
    bt_git_user=$1
    bt_git_repo=$2
    bt_git_version=$3
    bt_download_folder=$4

    bt_url="${bt_git_site}/${bt_git_user}/${bt_git_repo}/archive/refs/tags/${bt_git_version}.zip"
    bt_start_spinner "$bt_ln_download_url '${bt_git_user}/${bt_git_repo}' version '${bt_git_version}'"
    bt_url=$(curl -s --url $bt_url --head | grep 'location:' | awk '{print $2}' | sed 's/[[:space:]]//g')
    bt_stop_spinner
    bt_start_spinner "$bt_ln_download_zip_name '${bt_git_user}/${bt_git_repo}' version '${bt_git_version}'"
    bt_zip_name=$(curl -s --url $bt_url --head | grep 'filename=' | awk '{print $3}')
    bt_stop_spinner
    bt_zip_name=${bt_zip_name:9}
    bt_zip_name=${bt_zip_name::-5}
    bt_download_file="${bt_download_folder}/${bt_zip_name}.zip"

    mkdir -p $bt_download_folder
    bt_start_spinner "$bt_ln_download_zip '${bt_url}'"
    curl -s -L $bt_url -o $bt_download_file
    bt_stop_spinner

}

# -------------------------------------------------------------------------------- #
# Unzip file.                                                                      #
# -------------------------------------------------------------------------------- #

function bt_unzip_file() {

    [[ $1 = "" ]] && bt_script_error "$bt_param_missing"
    [[ $2 = "" ]] && bt_script_error "$bt_param_missing"
    [[ $3 = "" ]] && bt_script_error "$bt_param_missing"

    bt_zip_name=$1
    bt_zip_file=$2
    bt_destination_folder=$3

    [ -d "${bt_destination_folder}/${bt_zip_name}" ] && rm -rf "${bt_destination_folder}/${bt_zip_name}"

    bt_start_spinner "$bt_ln_unzip '${bt_zip_file}'"
    7z x $bt_zip_file -bd -o$bt_destination_folder -y >/dev/null 2>&1
    bt_stop_spinner

}

# -------------------------------------------------------------------------------- #
# Set Bash Tools language if required and load texts.                              #
# -------------------------------------------------------------------------------- #

function bt_set_language() {
    if ! [[ $bt_language = "EN" || $bt_language = "FR" ]]; then
        bt_load_language "EN"
        bt_select_language
    else
        bt_load_language $bt_language
    fi
}

# -------------------------------------------------------------------------------- #
# Miscellaneous tools.                                                             #
# -------------------------------------------------------------------------------- #

bt_set_environment_variable() { # Make an environment variable persistent
    local KEY=$(echo $1 | awk -F '=' '{print $1}')
    local VALUE=$(echo $1 | awk -F '=' '{print $2}')
    grep -q $KEY= /etc/environment && sudo sed -i "s/$KEY=.*$/$KEY=$VALUE/g" /etc/environment || echo "$KEY=$VALUE" | sudo tee -a /etc/environment
}

# -------------------------------------------------------------------------------- #
# Set language and install required packages.                                      #
# --------------------------------------------3----------------------------------- #

bt_set_language
bt_check_package "figlet jq git curl p7zip-full"
