#!/bin/sh

COLOR_CYAN='\033[0;36m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_UNSET='\033[0m'

INCLUDE=""
EXCLUDE=""
DESTRUCTIVE=0
TEST_MODE=0
DEBUG_MODE=0
OUTPUT=""
PATTERN=""
MANIFEST=0
MANIFEST_FILE_NAME=".manifest"
MANIFEST_FILE=""

FIND_OPTS="-type f ! -name '.*' ! -path '*/.*'"
FIND_REGEX_OPT="-regex"
PRUNE_WIDGET=""

debug()
{
    [ "$DEBUG_MODE" -ne 0 ] && echo "$COLOR_CYAN" "[debug]" "$COLOR_UNSET\c" && "$@"
}

info()
{
    echo "$COLOR_GREEN" "[ info]" "$COLOR_UNSET\c" && "$@"
}

warn()
{
    echo "$COLOR_YELLOW" "[ warn]" "$COLOR_UNSET\c" && "$@"
}

error()
{
    echo "$COLOR_RED" "[error]" "$COLOR_UNSET\c" && "$@"
}

usage() 
{
    cat << EOF
usage: $0 -i <include_dirs> -o <output_file> -p <pattern> [-dtvhm] [-e <exclude_dirs>...]
package files into a tar.gz file

arguments:
  -i <include_dirs>       directories to include (required)
  -o <output_file>        path for output of tar.gz (required)
  -p <pattern>            pattern for identifying files of interest (required)
  -d                      destructive mode, delete included files after successful packaging
  -t                      test mode, enables debug messages and does NOT package or delete files
  -v                      print debug messages
  -h                      print this help message
  -m                      create a manifest
  -e <exclude_dirs>       directories to exclude
EOF
    exit 1
}

check_settings()
{
    debug echo "checking settings"

    FAIL=0

    [ -z "$INCLUDE" ] && error echo "include_dirs are required" && FAIL=1;
    [ -z "$OUTPUT" ] && error echo "output_file is required" && FAIL=1;
    [ -z "$PATTERN" ] && error echo "pattern is required"&& FAIL=1;

    [ "$FAIL" -ne 0 ] && error echo "invalid settings\n" && usage;
}

show_settings()
{
    echo "settings"
    echo "INCLUDE=$INCLUDE"
    echo "EXCLUDE=$EXCLUDE"
    echo "DESTRUCTIVE=$DESTRUCTIVE"
    echo "TEST_MODE=$TEST_MODE"
    echo "DEBUG_MODE=$DEBUG_MODE"
    echo "OUTPUT=$OUTPUT"
    echo "PATTERN=$PATTERN"
}

locate_files()
{
    debug echo "locating files"

    FIND_CMD="find $INCLUDE $FIND_OPTS $FIND_REGEX_OPT '$PATTERN' $PRUNE_WIDGET"

    debug echo "find command\n$FIND_CMD"

    FILES_RAW=$(eval "$FIND_CMD")
    FILES=$(echo "$FILES_RAW" | xargs echo)
    FILE_COUNT="$(echo "$FILES_RAW" | grep -v -c ^$)"

    if [ "$FILE_COUNT" -gt 0 ]
    then
        debug echo "files\n$FILES_RAW"
        info echo "found $FILE_COUNT files"
    else
        error echo "no files found"
        exit 1
    fi
}

pack_files()
{
    debug echo "packing files"

    TAR_CMD="tar czfP '$OUTPUT' $FILES"

    [ "$MANIFEST" -ne 0 ] && TAR_CMD="$TAR_CMD $MANIFEST_FILE --transform='s|$MANIFEST_FILE|$MANIFEST_FILE_NAME|'"

    debug echo "tar command\n$TAR_CMD"

    [ "$TEST_MODE" -eq 0 ] && { eval "$TAR_CMD" || { error echo "failed to tar files"; exit 1; } }
}

build_manifest()
{
    debug echo "building manifest"

    MANIFEST_FILE=$(mktemp /tmp/manifest.XXXXXX.tmp)
    trap 'rm "$MANIFEST_FILE"' EXIT

    MANIFEST_CMD="md5sum $FILES > $MANIFEST_FILE"

    debug echo "manifest command\n$MANIFEST_CMD"

    [ "$TEST_MODE" -eq 0 ] && { eval "$MANIFEST_CMD"; debug echo "manifest file"; cat "$MANIFEST_FILE"; }
}

destroy_files()
{
    debug echo "destroying files"

    RM_CMD="rm $FILES"

    debug echo "rm command\n$RM_CMD"

    [ "$TEST_MODE" -eq 0 ] && { eval "$RM_CMD" || { error echo "failed to destroy files"; exit 1; } }
}

while getopts ":dtvhmi:e:o:p:" ARG; do
    case "$ARG" in
        i) 
            INCLUDE="$OPTARG $INCLUDE"
            ;;
        e)
            if [ -n "$PRUNE_WIDGET" ]
            then
                # multiple prunes, requires or
                PRUNE_WIDGET="$PRUNE_WIDGET "
            fi
            PRUNE_WIDGET="$PRUNE_WIDGET ! -path '$OPTARG*'"

            EXCLUDE="$OPTARG $EXCLUDE"
            ;;
        d) 
            DESTRUCTIVE=1
            warn echo "destructive mode enabled"
            ;;
        t) 
            TEST_MODE=1
            DEBUG_MODE=1
            debug echo "testmode enabled, debugging enabled"
            ;;
        v) 
            DEBUG_MODE=1
            debug echo "debugging enabled"
            ;;
        m) 
            MANIFEST=1
            ;;
        o) 
            [ -n "$OUTPUT" ] && error echo "only one output file can be specified\n" && usage
            OUTPUT="$OPTARG"
            ;;
        p) 
            [ -n "$PATTERN" ] && error echo "only one pattern can be specified\n" && usage
            PATTERN="$OPTARG"
            ;;
        h)
            usage
            ;;
        :) 
            error echo "no value given for option: -$OPTARG\n"
            usage
            ;;
        \?) 
            error echo "invalid argument: -$OPTARG\n"
            usage
            ;;
    esac
done

debug show_settings

check_settings
locate_files

[ "$MANIFEST" -ne 0 ] && build_manifest

pack_files

[ "$DESTRUCTIVE" -ne 0 ] && destroy_files
