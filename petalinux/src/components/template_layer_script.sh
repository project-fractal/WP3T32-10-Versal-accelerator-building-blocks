#!/bin/bash

#
# Copyright 2022 IKERLAN S.COOP.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

NAME=template

SCRIPTNAME=${0##*/}

import() {
    local ext_src_dir=$1
    local proj_dir=$2

    # =========================================================
    # Fill recipe for importing layer
    # =========================================================

    return 0
}

config() {
    local ext_src_dir=$1
    local proj_dir=$2

    # =========================================================
    # Fill recipe for configuring layer
    # =========================================================

    return 0
}

clean() {
    local ext_src_dir=$1
    local proj_dir=$2

    # =========================================================
    # Fill recipe for cleaning layer configuration
    # =========================================================

    return 0
}

help() {
    cat >&2 <<EOL
Import, configure, or clean $NAME in a PetaLinux project.
Usage:
$SCRIPTNAME command [options?]...
commands:
    --help|-h               Display this information
    --clean                 Clean all changes
    --import|-i [options?]  Import the source code
    --config|-c [options?]  Configure the project

options:
    --external_src|-s   Directory to import sources
                        (default is current directory)
    --project|-p        Project directory
EOL
}

print() {
    case "$1" in
    WAIT)
        PREFIX="\n[..]"
        ;;
    OK | INFO | ERROR)
        PREFIX="[$1]"
        ;;
    *)
        error "Unknown print type: $1"
        ;;
    esac
    shift
    echo -e ${PREFIX} $@
}

error() {
    print "ERROR" "$@"
    exit 1
}

append_if_missing() {
    local line="$1"
    local filename="$2"

    if [[ "$line" == "" || "$filename" == "" ]]; then
        error "append_if_missing: missing arguments"
    fi

    print "INFO" "Appending $line to $filename"

    grep -Fxq "$line" "$filename" || echo $line >>$filename
}

activate_config() {
    local config="$1"
    local filename="$2"
    local before="$3"
    local extra_txt=""

    if [[ "$config" == "" || "$filename" == "" ]]; then
        error "activate_config: missing arguments"
    fi
    if [[ "$config" != "CONFIG_*" ]]; then
        config="CONFIG_$config"
    fi
    if [[ "$before" != "" && "$before" != "CONFIG_*" ]]; then
        before="CONFIG_$before"
        extra_txt=" after $before"
    fi

    print "INFO" "Activating $1 in $2$extra_txt"

    set_var "$filename" "$config" "$config=y" "$before"
}

deactivate_config() {
    local config="$1"
    local filename="$2"
    local before="$3"
    local extra_txt=""

    if [[ "$config" == "" || "$filename" == "" ]]; then
        error "deactivate_config: missing arguments"
    fi
    if [[ "$config" != "CONFIG_*" ]]; then
        config="CONFIG_$config"
    fi
    if [[ "$before" != "" && "$before" != "CONFIG_*" ]]; then
        before="CONFIG_$before"
        extra_txt=" after $before"
    fi

    print "INFO" "Deactivating $1 in $2$extra_txt"

    set_var "$filename" "$config" "# $config is not set" "$before"
}

undef_config() {
    local config=$1
    local filename=$2

    if [[ "$config" == "" || "$filename" == "" ]]; then
        error "undef_config: missing arguments"
    fi
    if [[ "$config" != "CONFIG_*" ]]; then
        config="CONFIG_$config"
    fi

    print "INFO" "Undefining $1 in $2"

    undef_var "$filename" "$config"
}

txt_append() {
    local anchor="$1"
    local insert="$2"
    local infile="$3"
    local tmpfile="$infile.swp"

    # sed append cmd: 'a\' + newline + text + newline
    cmd="$(printf "a\\%b$insert" "\n")"

    sed -e "/$anchor/$cmd" "$infile" >"$tmpfile"
    # replace original file with the edited one
    mv "$tmpfile" "$infile"
}

txt_subst() {
    local before="$1"
    local after="$2"
    local infile="$3"
    local tmpfile="$infile.swp"

    sed -e "s:$before:$after:" "$infile" >"$tmpfile"
    # replace original file with the edited one
    mv "$tmpfile" "$infile"
}

txt_delete() {
    local text="$1"
    local infile="$2"
    local tmpfile="$infile.swp"

    sed -e ":$text:d" "$infile" >"$tmpfile"
    # replace original file with the edited one
    mv "$tmpfile" "$infile"
}

set_var() {
    local filename=$1
    local name=$2
    local new=$3
    local before=$4

    name_re="^($name=|# $name is not set)"
    before_re="^($before=|# $before is not set)"
    if test -n "$before" && grep -Eq "$before_re" "$filename"; then
        txt_append "^$before=" "$new" "$filename"
        txt_append "^# $before is not set" "$new" "$filename"
    elif grep -Eq "$name_re" "$filename"; then
        txt_subst "^$name=.*" "$new" "$filename"
        txt_subst "^# $name is not set" "$new" "$filename"
    else
        echo "$new" >>"$filename"
    fi
}

undef_var() {
    local filename=$1
    local name=$2

    txt_delete "^$name=" "$filename"
    txt_delete "^# $name is not set" "$filename"
}

get_external_src() {
    if [[ "$1" != "" && "$1" != -* ]]; then
        EXT_SRC=$1
        print "INFO" "External sources directory: ${EXT_SRC}"
        return 0
    fi
}

get_proj() {
    if [[ "$1" != "" && "$1" != -* ]]; then
        PROJ=$1
        print "INFO" "Project directory: ${PROJ}"
        return 0
    fi
}

DO_CLEAN=false
DO_IMPORT=false
DO_CONFIG=false
EXT_SRC="."
PROJ=""

while [ "$1" != "" ]; do
    ARG="$1"
    shift
    case "$ARG" in
    --help | -h)
        help
        ;;
    --clean)
        DO_CLEAN=true
        ;;
    --import | -i)
        DO_IMPORT=true
        ;;
    --config | -c)
        DO_CONFIG=true
        ;;
    --external_src | -s)
        get_external_src $1
        shift
        ;;
    --project | -p)
        get_proj $1
        shift
        ;;
    *)
        help
        error "Unrecognized argument" ${ARG}
        ;;
    esac
done

if [[ ${DO_CLEAN} == false && ${DO_IMPORT} == false && ${DO_CONFIG} == false ]]; then
    help
    error "No action specified"
fi

if [[ ${EXT_SRC} == "." ]]; then
    print "INFO" "Missing destination directory, using default: ${EXT_SRC}"
fi

if [[ -z ${PROJ} && (${DO_CLEAN} == true || ${DO_CONFIG} == true) ]]; then
    error "Missing project directory"
fi

if [[ ${DO_CLEAN} == true ]]; then
    print "WAIT" "Cleaning ${NAME}"

    if [[ -z ${PROJ} ]]; then
        error "Missing project directory"
    fi

    clean ${EXT_SRC} ${PROJ}

    print "OK" "Successfully cleaned ${NAME}"
fi

if [[ ${DO_IMPORT} == true ]]; then
    print "WAIT" "Importing ${NAME}"

    import ${EXT_SRC} ${PROJ}

    print "OK" "Successfully imported ${NAME} at:\n${EXT_SRC}"
fi

if [[ ${DO_CONFIG} == true ]]; then
    print "WAIT" "Configuring ${NAME}"

    if [[ -z ${PROJ} ]]; then
        error "Missing project directory"
    fi

    config ${EXT_SRC} ${PROJ}

    print "OK" "Successfully configured ${NAME} at:\n${PROJ}"
fi

exit 0
