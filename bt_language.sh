#!/usr/bin/env bash

# -------------------------------------------------------------------------------- #
# Current selected language.                                                       #
# -------------------------------------------------------------------------------- #

bt_language=FR

# -------------------------------------------------------------------------------- #
# Load language texts based on selected language.                                  #
# -------------------------------------------------------------------------------- #

function bt_load_language ()
{
    source "${bt_tools_path}/bt_languages/bt_language.$1.sh"
}

# -------------------------------------------------------------------------------- #
# Language selection                                                               #
# -------------------------------------------------------------------------------- #

function bt_select_language ()
{
    bt_wh_choice=$(whiptail \
        --title "$bt_wt_language" \
        --menu \
        "\n${bt_wm_language}" \
        --ok-button "$bt_wh_OK" \
        --cancel-button "$bt_wh_cancel" \
        16 70 2 \
        "EN" "English" \
        "FR" "Français" \
        3>&1 1>&2 2>&3)
    [ $? != 0 ] && bt_script_cancel
    clear -x
    bt_language=$bt_wh_choice
    sed -i "s/^bt_language=.*/bt_language=$bt_language/" "${bt_tools_path}/bt_language.sh"
    bt_load_language $bt_language
}
