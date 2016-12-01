#!/bin/bash

# Copyright (C) 2016  Andy "atze danjo" Jacobsen
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

set -e -o pipefail                                      # see https://sipb.mit.edu/doc/safe-shell/

VERSION="v0.0.3"
RELEASED=false

# various constants

INSTALL_PATH="/usr/local/bin"
INSTALL_NAME="block_tracker"
EXECUTABLE_NAME=${INSTALL_NAME/_/-}                     # executable has hypen instead of underscore !!!
GITHUB_URL="github.com"
GITHUB_RAW_URL="raw.githubusercontent.com"
GITHUB_BRANCH="master"
GITHUB_REPO="ajacobsen/block-tracker"
GIT_REPO_URL="https://$GITHUB_URL/$GITHUB_REPO"
if [ ${RELEASED} == true ]; then
    GIT_INSTALL_URL="https://$GITHUB_RAW_URL/$GITHUB_REPO/${VERSION}/${INSTALL_NAME}.sh"
else
    GIT_INSTALL_URL="https://$GITHUB_RAW_URL/$GITHUB_REPO/${GITHUB_BRANCH}/${INSTALL_NAME}.sh"
fi
ETC_HOSTS_D_DIR="/etc/hosts.d"
ETC_HOSTS="/etc/hosts"
FILTER_CONFIG_FILE="/etc/block-tracker.filter"

# runtime messages

MSG_CNT=0
MSG_DOWNLOAD_FAILED=$((MSG_CNT++))
MSG_EN[$MSG_DOWNLOAD_FAILED]="WARNING! Failed to download %b!"
MSG_DE[$MSG_DOWNLOAD_FAILED]="WARNUNG! Download von %b fehlgeschlagen!"
MSG_NOT_ROOT=$((MSG_CNT++))
MSG_EN[$MSG_NOT_ROOT]="You have to be root!"
MSG_DE[$MSG_NOT_ROOT]="Du musst root sein!"
MSG_README_HINT=$((MSG_CNT++))
MSG_EN[$MSG_README_HINT]="Please read the instructions at ${GIT_REPO_URL}"
MSG_DE[$MSG_README_HINT]="Bitte lese die Anweisungen auf ${GIT_REPO_URL}"
MSG_DISABLED_SUCCESS=$((MSG_CNT++))
MSG_EN[$MSG_DISABLED_SUCCESS]="${EXECUTABLE_NAME} is now disabled"
MSG_DE[$MSG_DISABLED_SUCCESS]="${EXECUTABLE_NAME} ist nun ausgeschaltet"
MSG_ENABLED_SUCCESS=$((MSG_CNT++))
MSG_EN[$MSG_ENABLED_SUCCESS]="${EXECUTABLE_NAME} is now enabled"
MSG_DE[$MSG_ENABLED_SUCCESS]="${EXECUTABLE_NAME} ist nun eingeschaltet"
MSG_PROCESSING_URL=$((MSG_CNT++))
MSG_EN[$MSG_PROCESSING_URL]="Downloading and processing %b"
MSG_DE[$MSG_PROCESSING_URL]="%b wird runtergeladen und bearbeitet"
MSG_APPLIED_FILTER=$((MSG_CNT++))
MSG_EN[$MSG_APPLIED_FILTER]="Filter %b removes %b lines"
MSG_DE[$MSG_APPLIED_FILTER]="Filter %b entfernt %b Zeilen"
MSG_FILTER_FAILURE=$((MSG_CNT++))
MSG_EN[$MSG_FILTER_FAILURE]="Error applying filter %b. rc: %b"
MSG_DE[$MSG_FILTER_FAILURE]="Fehler beim Anwenden des Filters aus %b. rc: %b"
MSG_FILTER_RESULT=$((MSG_CNT++))
MSG_EN[$MSG_FILTER_RESULT]="Filter %b will remove %b lines\n--- List of filtered lines ---"
MSG_DE[$MSG_FILTER_RESULT]="Filter %b würde %b Zeilen entfernen\n--- Liste der gefilterten Zeilen ---"
MSG_FILTER_NOT_FOUND=$((MSG_CNT++))
MSG_EN[$MSG_FILTER_NOT_FOUND]="Filter %b not found"
MSG_DE[$MSG_FILTER_NOT_FOUND]="Filter %b nicht gefunden"
MSG_STATUS_ENABLED=$((MSG_CNT++))
MSG_EN[$MSG_STATUS_ENABLED]="${EXECUTABLE_NAME} is enabled"
MSG_DE[$MSG_STATUS_ENABLED]="${EXECUTABLE_NAME} ist aktiviert"
MSG_STATUS_DISABLED=$((MSG_CNT++))
MSG_EN[$MSG_STATUS_DISABLED]="${EXECUTABLE_NAME} is disabled"
MSG_DE[$MSG_STATUS_DISABLED]="${EXECUTABLE_NAME} is deaktiviert"
MSG_CURRENT_VERSION=$((MSG_CNT++))
MSG_EN[$MSG_CURRENT_VERSION]="%b version installed: %b"
MSG_DE[$MSG_CURRENT_VERSION]="Installierte Version von %b: %b"
MSG_LATEST_VERSION=$((MSG_CNT++))
MSG_EN[$MSG_LATEST_VERSION]="%b latest stable version: %b"
MSG_DE[$MSG_LATEST_VERSION]="Neueste stabile Version von %b: %b"

# Messages for installer

MSG_CNT=100
MSG_CONFIRM_UNINSTALL=$((MSG_CNT++))
MSG_EN[$MSG_CONFIRM_UNINSTALL]="Restoring ${ETC_HOSTS} and deleting ${ETC_HOSTS_D_DIR}? [%b] "
MSG_DE[$MSG_CONFIRM_UNINSTALL]="Stelle ${ETC_HOSTS} wieder her und lösche ${ETC_HOSTS_D_DIR}? [%b] "
MSG_PROCESSING_UNINSTALL=$((MSG_CNT++))
MSG_EN[$MSG_PROCESSING_UNINSTALL]="Uninstalling %b ..."
MSG_DE[$MSG_PROCESSING_UNINSTALL]="Deinstalliere %b ..."
MSG_UNINSTALL_SUCCESS=$((MSG_CNT++))
MSG_EN[$MSG_UNINSTALL_SUCCESS]="Uninstallation of %b finished"
MSG_DE[$MSG_UNINSTALL_SUCCESS]="Deinstallation von %b beendet"
MSG_PROCESSING_INSTALL=$((MSG_CNT++))
MSG_EN[$MSG_PROCESSING_INSTALL]="Installing %b ..."
MSG_DE[$MSG_PROCESSING_INSTALL]="Installiere %b ..."
MSG_INSTALL_SUCCESS=$((MSG_CNT++))
MSG_EN[$MSG_INSTALL_SUCCESS]="Installation of %b in %b finished"
MSG_DE[$MSG_INSTALL_SUCCESS]="Installation von %b in %b beendet"
MSG_YES_NO=$((MSG_CNT++))
MSG_EN[$MSG_YES_NO]="y/N"
MSG_DE[$MSG_YES_NO]="j/N"
MSG_NOT_INSTALLED=$((MSG_CNT++))
MSG_EN[$MSG_NOT_INSTALLED]="%b is not installed"
MSG_DE[$MSG_NOT_INSTALLED]="%b ist nicht installiert"
MSG_ALREADY_INSTALLED=$((MSG_CNT++))
MSG_EN[$MSG_ALREADY_INSTALLED]="%b is already installed"
MSG_DE[$MSG_ALREADY_INSTALLED]="%b ist schon installiert"
MSG_REINSTALL=$((MSG_CNT++))
MSG_EN[$MSG_REINSTALL]="reinstall %b? [%b] "
MSG_DE[$MSG_REINSTALL]="%b erneut installieren? [%b] "
MSG_UPGRADE="$((MSG_CNT++))"
MSG_EN[$MSG_UPGRADE]="Upgrade %b to version %b? [%b]"
MSG_DE[$MSG_UPGRADE]="%b auf Version %b aktualisieren? [%b]"

# common messages

MSG_CNT=200
MSG_UNKNOWN_OPTION=$((MSG_CNT++))
MSG_EN[$MSG_UNKNOWN_OPTION]="Unknown option %b"
MSG_DE[$MSG_UNKNOWN_OPTION]="Unbekannte Option %b"
MSG_UNDEFINED=$((MSG_CNT++))
MSG_EN[$MSG_UNDEFINED]="Undefined message number %b. Please report this error."
MSG_DE[$MSG_UNDEFINED]="Unbekannte Meldungsnummer %b. Bitte melde diesen Fehler."
MSG_NOT_IMPLEMENTED=$((MSG_CNT++))
MSG_EN[$MSG_NOT_IMPLEMENTED]="Function %b not implemented right now. Feel free to implement this function in $GIT_REPO_URL"
MSG_DE[$MSG_NOT_IMPLEMENTED]="Funktion %b noch nicht implementiert. Implementiere sie einfach in $GIT_REPO_URL"
MSG_ABORTED=$((MSG_CNT++))
MSG_EN[$MSG_ABORTED]="Program aborted"
MSG_DE[$MSG_ABORTED]="Programm fehlerhaft beendet"
MSG_NOT_ROOT=$((MSG_CNT++))
MSG_FILTER_INVALID=$((MSG_CNT++))
MSG_DE[$MSG_FILTER_INVALID]="Filter option not allowed with option %b"
MSG_EN[$MSG_FILTER_INVALID]="Filter Option nicht erlaubt mit Option %b"
MSG_EN[$MSG_NOT_ROOT]="You have to be root!"
MSG_DE[$MSG_NOT_ROOT]="Du musst root sein!"
MSG_CONFIG_FILE_NOT_FOUND=$((MSG_CNT++))
MSG_EN[$MSG_CONFIG_FILE_NOT_FOUND]="Filter file '%b' not found"
MSG_DE[$MSG_CONFIG_FILE_NOT_FOUND]="Filter Datei '%b' nicht gefunden"
MSG_MISSING_CONFIG=$((MSG_CNT++))
MSG_EN[$MSG_MISSING_CONFIG]="Missing filter file"
MSG_DE[$MSG_MISSING_CONFIG]="Filterdatei nicht angegeben "
MSG_OPTION_ERROR=$((MSG_CNT++))
MSG_EN[$MSG_OPTION_ERROR]="Invalid combination of options"
MSG_DE[$MSG_OPTION_ERROR]="Ungültige Optionskombination"
MSG_HELP=$((MSG_CNT++))
MSG_EN[$MSG_HELP]="${EXECUTABLE_NAME}, Version ${VERSION}
Usage:
${EXECUTABLE_NAME} -c FILE
${EXECUTABLE_NAME} -d
${EXECUTABLE_NAME} -e [-f]
${EXECUTABLE_NAME} -F
${EXECUTABLE_NAME} -i
${EXECUTABLE_NAME} -r [-f]
${EXECUTABLE_NAME} -s
${EXECUTABLE_NAME} -u
${EXECUTABLE_NAME} -U

  -c, --config file   Use special filter file. Deafult is $FILTER_CONFIG_FILE
  -d, --disable       Disable all blacklists
  -e, --enable        Enable ${EXECUTABLE_NAME} without downloading blacklists
  -f, --filter        Enable the filter configured in ${FILTER_CONFIG_FILE}
                      A different filter file can be specified with -c or --config.
                      This option is only valid in combination with -e or -r
  -F, --filter-test   Test the configuration of the filter and display lines filtered
  -i, --install       Install block-tracker to ${INSTALL_PATH}/${EXECUTABLE_NAME}
  -r, --run           Download and enable blacklists
  -s, --status        Show the current status of block-tracker (enabled/disabled)
  -u, --uninstall     Delete ${INSTALL_PATH}/${EXECUTABLE_NAME} and ${ETC_HOSTS_D_DIR}
                      and disable ${EXECUTABLE_NAME} (See -d|--disable)
  -U, --update        Upgrade to latest stable release

The complete documentation is available on ${GIT_REPO_URL}."
MSG_DE[$MSG_HELP]="${EXECUTABLE_NAME}, Version ${VERSION}
Aufruf:
${EXECUTABLE_NAME} -c DATEI
${EXECUTABLE_NAME} -d
${EXECUTABLE_NAME} -e [-f]
${EXECUTABLE_NAME} -F
${EXECUTABLE_NAME} -i
${EXECUTABLE_NAME} -r [-f]
${EXECUTABLE_NAME} -s
${EXECUTABLE_NAME} -u
${EXECUTABLE_NAME} -U

  -c, --config Datei  Benutze spezielle Filterdatei. Standard ist $FILTER_CONFIG_FILE.
  -d, --disable       Deaktiviere alle blacklists
  -e, --enable        Aktiviere ${EXECUTABLE_NAME} ohne blacklists runterzuladen
  -f, --filter        Aktiviere den Filter. Standarddatei ist $FILTER_CONFIG_FILE.
                      Alternativ kann mit -c oder --config eine andere Filterdatei
                      angegeben werden.
                      Diese Option ist nur gültig in Kombination mit -e or -r
  -F, --filter-test   Teste die Konfiguration des Filters und liste welche Zeilen gefiltert
  -i, --install       Installiere block-tracker nach ${INSTALL_PATH}/${EXECUTABLE_NAME}
  -r, --run           Lade und aktiviere blacklists
                      werden
  -s, --status        Zeige den aktuellen Status von ${EXECUTABLE_NAME} (aktiviert/deaktiviert)
  -u, --uninstall     Lösche ${INSTALL_PATH}/${EXECUTABLE_NAME} und ${ETC_HOSTS_D_DIR}
                      und deaktiviere ${EXECUTABLE_NAME} (Siehe -d|--disable)
  -U, --update        Aktualisiere auf neueste stabile Version

Die vollständige Dokumentation ist unter ${GIT_REPO_URL} verfügbar."
MSG_MISSING_DEP=$((MSG_CNT++))
MSG_EN[$MSG_MISSING_DEP]="You need %b to use this feature"
MSG_DE[$MSG_MISSING_DEP]="Für diese Funktion wird %b benötigt"

MSGVAR="MSG_$(tr '[:lower:]' '[:upper:]' <<< ${LANG:0:2})"

function abort() {
    write_to_console "${MSG_ABORTED}"
    exit 42
}

function askYesNo() { # messageid message_parameters
    local response
    local yesno=$(get_message "$MSG_YES_NO")
    ask_from_console "$1" ${@:2} ${yesno}
    yesno=${yesno,,}
    local yes="${yesno:0:1}"
    read -sn 1 response
    response=${response,,}
    echo

    if [[ ${response} == ${yes} ]]; then
        return 1
    else
        return 0
    fi
}

function uninstall() {
    if [[ ! -f "${INSTALL_PATH}/${EXECUTABLE_NAME}" ]]; then
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        help
        exit 1
    fi

    set +e              # TBD: hack
    askYesNo ${MSG_CONFIRM_UNINSTALL}
    if (( ! $? )); then
        exit 1
    fi
    set -e

    write_to_console "${MSG_PROCESSING_UNINSTALL}" "${EXECUTABLE_NAME}"
    cp ${ETC_HOSTS_D_DIR}/00-hosts ${ETC_HOSTS}
    rm -r ${ETC_HOSTS_D_DIR}
    rm "${INSTALL_PATH}/${EXECUTABLE_NAME}"
    write_to_console "${MSG_UNINSTALL_SUCCESS}" "${INSTALL_PATH}/${EXECUTABLE_NAME}"
}

function install() {
    if [[ -f "${INSTALL_PATH}/${EXECUTABLE_NAME}" ]]; then
        set +e          # TBD: hack
        askYesNo "${MSG_REINSTALL}" "${EXECUTABLE_NAME}"
        if (( ! $? )); then
            exit 0
        fi
        set -e
    fi

    doInstall "${GIT_INSTALL_URL}"
}

function doInstall() { # install_url
    local url="${1}"
    write_to_console "${MSG_PROCESSING_INSTALL}" "${EXECUTABLE_NAME}"
    mkdir ${ETC_HOSTS_D_DIR} 2>/dev/null && cp ${ETC_HOSTS} ${ETC_HOSTS_D_DIR}/00-hosts
    wget -qO "${INSTALL_PATH}/${EXECUTABLE_NAME}" "${url}" || \
        ( write_to_console "${MSG_DOWNLOAD_FAILED}" "${url}"; abort )
    chmod +x "${INSTALL_PATH}/${EXECUTABLE_NAME}"
    write_to_console "${MSG_INSTALL_SUCCESS}" "${EXECUTABLE_NAME}" "${INSTALL_PATH}"
}

function disable() {
    # Prüfe ob /etc/hosts.d und /etc/hosts.d/00-hosts existieren
    if ([ ! -d ${ETC_HOSTS_D_DIR} ] || [ ! -f ${ETC_HOSTS_D_DIR}/00-hosts ]); then
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        help
        exit 1
    fi

    cp ${ETC_HOSTS_D_DIR}/00-hosts ${ETC_HOSTS}
    write_to_console "${MSG_DISABLED_SUCCESS}" "${EXECUTABLE_NAME}"
}

function process_etc() { # resultfile

    if ([ ! -d ${ETC_HOSTS_D_DIR} ] || [ ! -f ${ETC_HOSTS_D_DIR}/00-hosts ]); then
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        help
        exit 1
    fi

    if [[ $(ls -1 ${ETC_HOSTS_D_DIR}/[01234]0-* | wc -l) != "5" ]]; then
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        help
        exit 1
    fi

    local result_file="$1"

    # Insert comment
    # Concatenate files
    # Remove comments
    # Remove leading and trailing spaces
    # Eliminate duplicates
    printf "# DO NOT EDIT THIS FILE\\n# It is automaticly generated by block-tracker from the files in /etc/hosts.d/\\n# Your original hosts file can be found at ${ETC_HOSTS_D_DIR}/00-hosts you should make any changes there\n" > ${result_file}
    cat ${ETC_HOSTS_D_DIR}/* | sed -e '/^#.*$/d' -e 's/^\s\+//g' -e 's/\s\+$//g'| sort -u >> ${result_file}
}

function enable() {

    process_etc "${ETC_HOSTS}"

    if [ ${use_filter} == true ]; then
        if [ -f ${FILTER_CONFIG_FILE} ]; then
            local tmpfile=$(mktemp)
            set +e
            cut -d " " -f 2 "${ETC_HOSTS}" | grep -xEf ${FILTER_CONFIG_FILE} | grep -vf - ${ETC_HOSTS} > "${tmpfile}"
            local rc=$?
            if (( $rc )); then
                write_to_console "${MSG_FILTER_FAILURE}" "${FILTER_CONFIG_FILE}" "${rc}"
            else
                local etcLines finalLines
                etcLines=$(wc -l ${ETC_HOSTS} | cut -d ' ' -f 1)
                finalLines=$(wc -l ${tmpfile} | cut -d ' ' -f 1)
                write_to_console "${MSG_APPLIED_FILTER}" "${FILTER_CONFIG_FILE}" "$(( etcLines - finalLines ))"
                cp "${tmpfile}" "${ETC_HOSTS}"
            fi
            set -e
            rm "${tmpfile}"
        else
            write_to_console "${MSG_FILTER_NOT_FOUND}" "${FILTER_CONFIG_FILE}"
        fi
    fi
    write_to_console "${MSG_ENABLED_SUCCESS}"

}

function filtertest() {

    if [ -f ${FILTER_CONFIG_FILE} ]; then
        local test_etc=$(mktemp)
        process_etc "${test_etc}"

        local tmpfile=$(mktemp)
        # Remove comments and blank lins
        local filter_regex=$(mktemp)
        sed -e '/^#.*$/d' -e '/^\s*$/d' ${FILTER_CONFIG_FILE} > ${filter_regex}
        set +e
        cut -d " " -f 2 "${test_etc}" | grep -xEf ${filter_regex} | grep -vf - ${test_etc} > "${tmpfile}"
        set -e
        local rc=$?
        if [[ $rc != 0 ]]; then
            write_to_console "${MSG_FILTER_FAILURE}" "${FILTER_CONFIG_FILE}" "${rc}"
        else
            local etcLines finalLines
            etcLines=$(wc -l ${ETC_HOSTS} | cut -d ' ' -f 1)
            finalLines=$(wc -l ${tmpfile} | cut -d ' ' -f 1)
            write_to_console "${MSG_FILTER_RESULT}" "${FILTER_CONFIG_FILE}" "$(( etcLines - finalLines ))"
            cut -d " " -f 2 "${test_etc}" | grep -xEf ${FILTER_CONFIG_FILE}
        fi
        rm "${tmpfile}"
        rm "${test_etc}"
        rm "${filter_regex}"
    else
        write_to_console "${MSG_FILTER_NOT_FOUND}" "${FILTER_CONFIG_FILE}"
        exit 1
    fi

}

function invalid_option() {
    write_to_console $MSG_OPTION_ERROR
    write_to_console $MSG_HELP
    exit 1
}

function get_latest_version() {
    if which jq > /dev/null 2>&1; then
        if [[ -f "${INSTALL_PATH}/${EXECUTABLE_NAME}" ]]; then
            local latest_version=$(curl -s https://api.github.com/repos/ajacobsen/block-tracker/releases/latest |jq -r ".tag_name")
            write_to_console "${MSG_CURRENT_VERSION}" "${EXECUTABLE_NAME}" "${VERSION}"
            write_to_console "${MSG_LATEST_VERSION}" "${EXECUTABLE_NAME}" "${latest_version}"
            local url="https://$GITHUB_RAW_URL/$GITHUB_REPO/${latest_version}/${INSTALL_NAME}.sh"
            set +e          # TBD: hack
            askYesNo "${MSG_UPGRADE}" "${EXECUTABLE_NAME}" "${latest_version}"
            if (( ! $? )); then
                exit 0
            fi
            set -e
        else
            write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
            exit 0
        fi

        doInstall "${url}"
    else
        write_to_console "${MSG_MISSING_DEP}" "jq"
    fi
}

function help() {
    write_to_console "${MSG_HELP}"                          # TBD
}

function download () {
    # Download der hosts Dateien
    # Entfernen von carriage returns
    # Entfernen von localhost und broadcast Adressen
    # Entfernen von allen Kommentaren
    # Entfernen aller Zeilen, die nicht mit 0.0.0.0 beginnen
    # Entfernen von Leerzeilen
    write_to_console "${MSG_PROCESSING_URL}" "http://winhelp2002.mvps.org"
    wget -qO - "http://winhelp2002.mvps.org/hosts.txt"| \
    sed -e 's/\r//' -e '/^0/!d' -e 's/#.*$//'> "${ETC_HOSTS_D_DIR}/10-mvpblocklist" || \
    ( write_to_console "${MSG_DOWNLOAD_FAILED}" "http://winhelp2002.mvps.org/hosts.txt"; abort )

    write_to_console "${MSG_PROCESSING_URL}" "http://someonewhocares.org"
    wget -qO - "http://someonewhocares.org/hosts/zero/hosts"| \
    sed -e '/^0/!d' -e 's/#.*$//' > "${ETC_HOSTS_D_DIR}/20-some1whocaresblocklist" || \
    ( write_to_console "${MSG_DOWNLOAD_FAILED}" "http://someonewhocares.org/hosts/zero/hosts"; abort )

    write_to_console "${MSG_PROCESSING_URL}" "http://sysctl.org"
    wget -qO - "http://sysctl.org/cameleon/hosts"| \
    sed -e '/^127.0.0.1.*localhost$/d' -e 's/^127.0.0.1/0.0.0.0/' -e 's/[\t]//g' -e '/^0/!d' > "${ETC_HOSTS_D_DIR}/30-sysctlblocklist" || \
    ( write_to_console "${MSG_DOWNLOAD_FAILED}" "http://sysctl.org/cameleon/hosts"; abort )

    write_to_console "${MSG_PROCESSING_URL}" "http://pgl.yoyo.org"
    wget -qO - "http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&useip=0.0.0.0&mimetype=plaintext"| \
    sed -e '/^0/!d' > "${ETC_HOSTS_D_DIR}/40-yoyo.orgblocklist" || \
    ( write_to_console "${MSG_DOWNLOAD_FAILED}" "http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&useip=0.0.0.0&mimetype=plaintext"; abort )

}

function execute () {
    if [[ ! -d "${ETC_HOSTS_D_DIR}" ]]; then
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        help
        exit 1
    fi

    download
    enable

}

function get_message() { #messagenumber
    local msgv msg msgn
    msgn=$1
    [ -z "${msgn}" ] && msgn=${MSG_UNDEFINED}
    msgv="$MSGVAR[$msgn]"
    msg=${!msgv}
    if [ -z "${msg}" ]; then
        msg="${MSG_EN[$msgn]}"
    fi
    echo "$msg"
}

function write_to_console() { #messagenumber parm1 ... parmn
    local msgv msg msgn
    msgn=$1
    msg=$(get_message "$msgn")
    [ -z "${msg}" ] && msg=$(get_message "$MSG_UNDEFINED")
    printf "${msg}\n" "${@:2}"
}

function ask_from_console() { #messagenumber parm1 ... parmn
    local msgv msg msgn
    msgn=$1
    msg=$(get_message "$msgn")
    [ -z "${msg}" ] && msg=$(get_message "$MSG_UNDEFINED")
    printf "${msg}" "${@:2}"
}

function status() {
    if [ "$(head -n 1 ${ETC_HOSTS})" == "# DO NOT EDIT THIS FILE" ]; then
        write_to_console ${MSG_STATUS_ENABLED}
    else
        write_to_console ${MSG_STATUS_DISABLED}
    fi
}

if [[ " $@ " =~ " -h " || " $@ " =~ " --help " ]]; then # if any parameter asks for help
    help
    exit 0
fi

if [ $UID -ne 0 ]; then
    write_to_console "${MSG_NOT_ROOT}"
    exit 1
fi

cmd="execute"
use_filter=false
basic_cmd_cnt=0
filter_option_allowed=1
previous_token=""

if [ $# -gt 0 ]; then
    while [[ -n "$1" ]]; do
        case "$1" in
            # basic commands
            --disable|-d)
                cmd="disable"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=0
                shift ;;
            --enable|-e)
                cmd="enable"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=1
                shift ;;
            --filter-test|-F)
                cmd="filtertest"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=0
                shift ;;
            --install|-i)
                cmd="install"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=0
                shift ;;
            --run|-r)
                cmd="execute"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=1
                shift ;;
            --status|-s)
                cmd="status"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=0
                shift ;;
            --uninstall|-u)
                cmd="uninstall"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=0
                shift ;;
            --update|-U)
                cmd="get_latest_version"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=0
                shift ;;

            # options
            --filter|-f)
                if [[ $previous_token != "-e" && $previous_token != "--enable" && $previous_token != "" ]]; then
                    write_to_console $MSG_FILTER_INVALID "$previous_token"
                    exit 1
                fi
                use_filter=true;
                shift ;;
            --config|-c)
                shift
                if [[ -z "$1" || "${1:0:1}" == "-" ]]; then
                    write_to_console $MSG_MISSING_CONFIG
                    exit 1
                fi
                if [[ ! -f "$1" ]]; then
                    write_to_console $MSG_CONFIG_FILE_NOT_FOUND "$1"
                    exit 1
                fi
                FILTER_CONFIG_FILE="$1"
                shift
                ;;
            *)
                write_to_console $MSG_UNKNOWN_OPTION "$1" # TBD should write help message with all accepted options
                help
                exit 1
                ;;
        esac
        previous_token="$1"
    done
fi

if (( basic_cmd_cnt > 1 )); then
    invalid_option
fi

if (( ! filter_option_allowed )) &&  [ $use_filter == true ]; then
    invalid_option
fi

$cmd
