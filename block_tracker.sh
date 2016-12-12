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
#
# *Credits*
# I acknowledge and I'm grateful to framp (framp at linux-tips-and-tricks dot de)
# for his contribution to block_tracker.

set -e -o pipefail -o errtrace                          # see https://sipb.mit.edu/doc/safe-shell/

VERSION="v0.0.4"
RELEASED=false

# various constants

INSTALL_PATH="/usr/local/bin"
INSTALL_NAME="block_tracker"
EXECUTABLE_NAME=${INSTALL_NAME/_/-}                     # executable has hypen instead of underscore !!!
GITHUB_URL="github.com"
GITHUB_RAW_URL="raw.githubusercontent.com"
GITHUB_BRANCH="master"
GITHUB_REPO_OWNER="${GITHUB_REPO_OWNER:-ajacobsen}"
GITHUB_REPO="${GITHUB_REPO_OWNER}/${EXECUTABLE_NAME}"

ETC_HOSTS_D_DIR="/etc/hosts.d"
ETC_HOSTS="/etc/hosts"

# various dependent constants

GIT_REPO_URL="https://$GITHUB_URL/$GITHUB_REPO"
GITHUB_ISSUES_URL="https://$GITHUB_URL/$GITHUB_REPO/issues"
GITHUB_LATEST_RELEASE_URL="https://api.${GITHUB_URL}/repos/${GITHUB_REPO}/releases/latest"
GITHUB_TRACKER_URLs="${EXECUTABLE_NAME}.urls"
GITHUB_TRACKER_URLs_DOWNLOAD_URL="https://$GITHUB_RAW_URL/$GITHUB_REPO/${GITHUB_BRANCH}/${GITHUB_TRACKER_URLs}"
if [ ${RELEASED} == true ]; then
    GIT_INSTALL_URL="https://$GITHUB_RAW_URL/$GITHUB_REPO/${VERSION}/${INSTALL_NAME}.sh"
else
    GIT_INSTALL_URL="https://$GITHUB_RAW_URL/$GITHUB_REPO/${GITHUB_BRANCH}/${INSTALL_NAME}.sh"
fi

FILTER_CONFIG_FILE="/etc/${EXECUTABLE_NAME}.filter"
ETC_HOSTS_TRACKER_FILTER="${ETC_HOSTS_D_DIR}/[123456789]0-*"

# runtime messages

MSG_CNT=0
MSG_DOWNLOAD_FAILED=$((MSG_CNT++))
MSG_EN[$MSG_DOWNLOAD_FAILED]="WARNING! Failed to download %b"
MSG_DE[$MSG_DOWNLOAD_FAILED]="WARNUNG! Download von %b fehlgeschlagen"
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
MSG_DOWNLOADING_URL=$((MSG_CNT++))
MSG_EN[$MSG_DOWNLOADING_URL]="Downloading %b"
MSG_DE[$MSG_DOWNLOADING_URL]="%b wird runtergeladen"
MSG_PROCESSING_URL=$((MSG_CNT++))
MSG_EN[$MSG_PROCESSING_URL]="Downloading and processing tracker file %b"
MSG_DE[$MSG_PROCESSING_URL]="Tracker Datei %b wird runtergeladen und bearbeitet"
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
MSG_TRACKER_FILE_UPTODATE="$((MSG_CNT++))"
MSG_EN[$MSG_TRACKER_FILE_UPTODATE]="File %b is up-to-date, skipping"
MSG_DE[$MSG_TRACKER_FILE_UPTODATE]="Datei %b ist aktuell, überspringe"

# common messages

MSG_CNT=200
MSG_UNKNOWN_OPTION=$((MSG_CNT++))
MSG_EN[$MSG_UNKNOWN_OPTION]="Unknown option %b"
MSG_DE[$MSG_UNKNOWN_OPTION]="Unbekannte Option %b"
MSG_VERSION=$((MSG_CNT++))
MSG_EN[$MSG_VERSION]="$EXECUTABLE_NAME - $VERSION"
MSG_DE[$MSG_VERSION]="$EXECUTABLE_NAME - $VERSION"
MSG_UNEXPECTED_ERROR=$((MSG_CNT++))
MSG_EN[$MSG_UNEXPECTED_ERROR]="Unexpected error occured in version %b. Please report following stacktrace on ${GITHUB_ISSUES_URL}"
MSG_DE[$MSG_UNEXPECTED_ERROR]="Ein nicht erwarteter Fehler trat in version %b auf. Bitte berichte diesen Stacktrace auf ${GITHUB_ISSUES_URL}"
MSG_CLEANING_UP_TRACKER_FILES=$((MSG_CNT++))
MSG_EN[$MSG_CLEANING_UP_TRACKER_FILES]="Cleaning up %b old tracker files"
MSG_DE[$MSG_CLEANING_UP_TRACKER_FILES]="%b alte Tracker Dateien werden gelöscht"
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
${EXECUTABLE_NAME} -d
${EXECUTABLE_NAME} -e [-f [FILE]]
${EXECUTABLE_NAME} -F [FILE]
${EXECUTABLE_NAME} -i
${EXECUTABLE_NAME} -r [-f [FILE]]
${EXECUTABLE_NAME} -s
${EXECUTABLE_NAME} -u
${EXECUTABLE_NAME} -U

  -d, --disable                 Disable all blacklists
  -e, --enable                  Enable ${EXECUTABLE_NAME} without downloading blacklists
  -f, --filter [FILE]           Enable the filter configured in FILE.
                                If FILE is omitted it defaults to ${FILTER_CONFIG_FILE}
                                This option is only valid in combination with -e or -r
  -F, --filter-test [FILE]      Test the configuration of the filter and display lines filtered
  -i, --install                 Install block-tracker to ${INSTALL_PATH}/${EXECUTABLE_NAME}
  -r, --run                     Download and enable blacklists
  -s, --status                  Show the current status of block-tracker (enabled/disabled)
  -u, --uninstall               Delete ${INSTALL_PATH}/${EXECUTABLE_NAME} and ${ETC_HOSTS_D_DIR}
                                and disable ${EXECUTABLE_NAME} (See -d|--disable)
  -U, --update                  Upgrade to latest stable release

The complete documentation is available on https://ajacobsen.github.io/block-tracker/."
MSG_DE[$MSG_HELP]="${EXECUTABLE_NAME}, Version ${VERSION}

Aufruf:
${EXECUTABLE_NAME} -d
${EXECUTABLE_NAME} -e [-f [DATEI]]
${EXECUTABLE_NAME} -F [DATEI]
${EXECUTABLE_NAME} -i
${EXECUTABLE_NAME} -r [-f [DATEI]]
${EXECUTABLE_NAME} -s
${EXECUTABLE_NAME} -u
${EXECUTABLE_NAME} -U

  -d, --disable                 Deaktiviere alle blacklists
  -e, --enable                  Aktiviere "${EXECUTABLE_NAME}" ohne blacklists runterzuladen
  -f, --filter [DATEI]          Aktiviere den Filter DATEI, wenn DATEI ausgelassen wird,
                                wird "${FILTER_CONFIG_FILE}" verwendet.
                                Alternativ kann mit -c oder --config eine andere Filterdatei
                                angegeben werden.
                                Diese Option ist nur gültig in Kombination mit -e or -r
  -F, --filter-test [DATEI]     Teste die Konfiguration des Filters und liste welche Zeilen gefiltert
  -i, --install                 Installiere block-tracker nach ${INSTALL_PATH}/${EXECUTABLE_NAME}
  -r, --run                     Lade und aktiviere blacklists werden
  -s, --status                  Zeige den aktuellen Status von ${EXECUTABLE_NAME} (aktiviert/deaktiviert)
  -u, --uninstall               Lösche ${INSTALL_PATH}/${EXECUTABLE_NAME} und ${ETC_HOSTS_D_DIR}
                                und deaktiviere ${EXECUTABLE_NAME} (Siehe -d|--disable)
  -U, --update                  Aktualisiere auf neueste stabile Version

Die vollständige Dokumentation ist unter https://ajacobsen.github.io/block-tracker/ verfügbar."

MSGVAR="MSG_$(tr '[:lower:]' '[:upper:]' <<< ${LANG:0:2})"

function abort() {
    write_to_console "${MSG_ABORTED}"
    exit 42
}

function askYesNo() { # messageid message_parameters
    local response
    local yesno=$(get_message "$MSG_YES_NO")
    ask_from_console "$1" "${@:2}" "${yesno}"
    yesno=${yesno,,}
    local yes="${yesno:0:1}"
    read -sn 1 response
    response=${response,,}
    echo

    if [[ ${response} == ${yes} ]]; then
        return 0
    else
        return 1
    fi
}

function uninstall() {
    if [[ ! -f "${INSTALL_PATH}/${EXECUTABLE_NAME}" ]]; then
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        help
        exit 1
    fi

    ! if ! askYesNo "${MSG_CONFIRM_UNINSTALL}"; then
        exit 1
    fi

    write_to_console "${MSG_PROCESSING_UNINSTALL}" "${EXECUTABLE_NAME}"
    cp ${ETC_HOSTS_D_DIR}/00-hosts ${ETC_HOSTS}
    rm -r ${ETC_HOSTS_D_DIR}
    rm "${INSTALL_PATH}/${EXECUTABLE_NAME}"
    write_to_console "${MSG_UNINSTALL_SUCCESS}" "${INSTALL_PATH}/${EXECUTABLE_NAME}"
}

function install() {
    if [[ -f "${INSTALL_PATH}/${EXECUTABLE_NAME}" ]]; then
        ! if ! askYesNo "${MSG_REINSTALL}" "${EXECUTABLE_NAME}"; then
            exit 0
        fi
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
    # Check if /etc/hosts.d and /etc/hosts.d/00-hosts exist
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

    if [[ $(ls -1 ${ETC_HOSTS_TRACKER_FILTER} | wc -l 2>/dev/null) == "0" ]]; then
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
            etcLines=$(wc -l ${test_etc} | cut -d ' ' -f 1)
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

function nop() {
	:			# just display version number
}

function invalid_option() {
    write_to_console $MSG_OPTION_ERROR
    write_to_console $MSG_HELP
    exit 1
}

function get_latest_version() {
    if [[ -f "${INSTALL_PATH}/${EXECUTABLE_NAME}" ]]; then
        ! local latest_version=$(curl -s ${GITHUB_LATEST_RELEASE_URL} | grep 'tag_name' | cut -f 2 -d ':' | sed 's/[", ]//g')
        write_to_console "${MSG_CURRENT_VERSION}" "${EXECUTABLE_NAME}" "${VERSION}"
        write_to_console "${MSG_LATEST_VERSION}" "${EXECUTABLE_NAME}" "${latest_version}"
        local url="https://$GITHUB_RAW_URL/$GITHUB_REPO/${latest_version}/${INSTALL_NAME}.sh"
        ! if ! askYesNo "${MSG_UPGRADE}" "${EXECUTABLE_NAME}" "${latest_version}"; then
            exit 0
        fi
    else
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        exit 0
    fi

    doInstall "${url}"
}

function help() {
    write_to_console "${MSG_HELP}"
}

<<<<<<< HEAD
function get_latest_update { # url
    local last_update
=======
function retrieveTrackerUrls() {

	local url regex
	local tmpfile=$(mktemp)

	write_to_console ${MSG_DOWNLOADING_URL} "${GITHUB_TRACKER_URLs_DOWNLOAD_URL}"
	if ! wget -qO ${tmpfile} ${GITHUB_TRACKER_URLs_DOWNLOAD_URL}; then
		write_to_console "${MSG_DOWNLOAD_FAILED}" "${GITHUB_TRACKER_URLs_DOWNLOAD_URL}"
		abort
	fi

	while IFS=$'\t' read -r url regex; do
		[[ $url =~ ^# ]] && continue			# skip comments
		TRACKER_URLs[${url}]="$regex"
	done < ${tmpfile}
	rm ${tmpfile}
>>>>>>> d7f64a65fa3d7b913b4e994c2d42acc3de462867

    last_update=$(curl -sI "${1}" |sed -n 's/Last-Modified: //p')
    last_update=$(date '+%s' -d "${last_update}")
    echo ${last_update}
}

<<<<<<< HEAD
function downloadTrackerFiles() {
    local name url regex
    local urlfile=$(mktemp)
    local tmpfile=$(mktemp)
=======
function downloadTrackerFiles () {

	retrieveTrackerUrls

    # Download der hosts Dateien
    # Entfernen von carriage returns
    # Entfernen von localhost und broadcast Adressen
    # Entfernen von allen Kommentaren
    # Entfernen aller Zeilen, die nicht mit 0.0.0.0 beginnen
    # Entfernen von Leerzeilen

    local url regex src

	# remove old configs
	! oldFilesCount=$(ls -1 ${ETC_HOSTS_TRACKER_FILTER} 2>/dev/null | wc -l)
	if (( oldFilesCount > 0 )); then
		write_to_console "${MSG_CLEANING_UP_TRACKER_FILES}" "$oldFilesCount"
    	for file in $(ls -1 $ETC_HOSTS_TRACKER_FILTER 2>/dev/null); do
			rm $file &>/dev/null
		done
	fi

	local cnt=10
	local tmpfile=$(mktemp)

    for url in "${!TRACKER_URLs[@]}"; do
		regex="${TRACKER_URLs[$url]}"
		write_to_console "${MSG_PROCESSING_URL}" "$url"
		if ! wget -qO "${tmpfile}" "$url"; then
			write_to_console "${MSG_DOWNLOAD_FAILED}" "$url"
			abort
		fi
		printf "%b" "${regex}" | sed -f - ${tmpfile} > "${ETC_HOSTS_D_DIR}/${cnt}-blocklist"
		: $(( cnt++ ))
	done
	rm $tmpfile
>>>>>>> d7f64a65fa3d7b913b4e994c2d42acc3de462867

    write_to_console ${MSG_DOWNLOADING_URL} "${GITHUB_TRACKER_URLs_DOWNLOAD_URL}"
    if ! wget -qO ${urlfile} ${GITHUB_TRACKER_URLs_DOWNLOAD_URL}; then
        write_to_console "${MSG_DOWNLOAD_FAILED}" "${GITHUB_TRACKER_URLs_DOWNLOAD_URL}"
        abort
    fi

    while IFS=$'\t' read -r name url regex; do
        [[ $name =~ ^# ]] && continue # skip comments
        write_to_console "${MSG_PROCESSING_URL}" "$url"
        if [[ ! -f ${ETC_HOSTS_D_DIR}/${name} || $(get_latest_update "${url}") > $(stat -c %Z ${ETC_HOSTS_D_DIR}/${name}) ]]; then
            if ! wget -qO "${tmpfile}" "$url"; then
                write_to_console "${MSG_DOWNLOAD_FAILED}" "$url"
                abort
            fi
            printf "%b" "${regex}" | sed -f - ${tmpfile} > "${ETC_HOSTS_D_DIR}/${name}"
        else
            write_to_console "${MSG_TRACKER_FILE_UPTODATE}" "${name}"
        fi
    done < ${urlfile}
    rm ${urlfile}
    rm ${tmpfile}
}

function execute () {
    if [[ ! -d "${ETC_HOSTS_D_DIR}" ]]; then
        write_to_console "${MSG_NOT_INSTALLED}" "${EXECUTABLE_NAME}"
        help
        exit 1
    fi

    downloadTrackerFiles
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

function handleErrorTrap() {
    write_to_console "${MSG_UNEXPECTED_ERROR}" "$VERSION"
    logStack
}

function logStack () {
    local l=0
    local frames=${#BASH_LINENO[@]}
    for ((l=frames-2; l>=0; l--)); do
        echo '  File' \"${BASH_SOURCE[l+1]}\", line ${BASH_LINENO[l]}, in ${FUNCNAME[l+1]}
#        sed -En "${BASH_LINENO[l]}{s/^([ \t]*)/: /;p}" "${BASH_SOURCE[l+1]}"
    done
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

trap handleErrorTrap ERR

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
                if [[ -n "${2}" && "${2:0:1}" != "-"  ]]; then
                    FILTER_CONFIG_FILE="${2}"
                    shift
                fi
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
            --version|-v)
                cmd="nop"
                : $(( basic_cmd_cnt++ ))
                filter_option_allowed=0
                shift ;;

            # options
            --filter|-f)
                use_filter=true;
                if [[ -n "${2}" && "${2:0:1}" != "-"  ]]; then
                    FILTER_CONFIG_FILE="${2}"
                    shift
                fi
                shift ;;
            *)
                write_to_console $MSG_UNKNOWN_OPTION "$1"
                help
                exit 1
                ;;
        esac
    done
fi

if [[ -z "${cmd}" ]]; then
    help
    exit 1
fi

if (( basic_cmd_cnt > 1 )); then
    invalid_option
fi

if (( ! filter_option_allowed )) &&  [ $use_filter == true ]; then
    invalid_option
fi

write_to_console $MSG_VERSION

$cmd
