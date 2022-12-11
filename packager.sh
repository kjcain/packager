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

FIND_OPTS="-type f ! -name '.*' ! -path '*/.*'"
FIND_REGEX_OPT="-regex"
PRUNE_WIDGET=""

debug()
{
    [ "$DEBUG_MODE" -eq 1 ] && echo -n "$COLOR_CYAN[debug] $COLOR_UNSET" && "$@"
}

info()
{
    echo -n "$COLOR_GREEN[ info] $COLOR_UNSET" && $@
}

warn()
{
    echo -n "$COLOR_YELLOW[ warn] $COLOR_UNSET" && $@
}

error()
{
    echo -n "$COLOR_RED[error] $COLOR_UNSET" && $@
}

usage() 
{
    echo "usage: $0 -i [<include_dirs>] [-e [<exclude_dirs>]] [-dtEFPv] -o <output_file> -p <pattern>" &>&2
    echo "package files into a tar.gz" &>&2
    echo "\n" &>&2
    echo "arguments:" &>&2
    echo "  -i <include_dirs>       directories to include (required)" &>&2
    echo "  -e <exclude_dirs>       directories to exclude" &>&2
    echo "  -d                      destructive mode, delete included files after successful packaging" &>&2
    echo "  -t                      test mode, enables debug messages and does NOT package or delete files" &>&2
    echo "  -v                      print debug messages" &>&2
    echo "  -o <output_file>        path for output of tar.gz (required)" &>&2
    echo "  -p <pattern>            pattern for identifying files of interest (required)" &>&2
    exit 1
}

check_settings()
{
    debug echo "checking settings"

    FAIL=0

    [ -z "$INCLUDE" ] && error echo "include_dirs are required" && FAIL=1;
    [ -z "$OUTPUT" ] && error echo "output_file is required" && FAIL=1;
    [ -z "$PATTERN" ] && error echo "pattern is required"&& FAIL=1;

    [ "$FAIL" -eq 1 ] && error echo "invalid settings\n" && usage;
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

while getopts ":dtEFPvi:e:o:p:" ARG; do
    case "$ARG" in
        i) 
            INCLUDE="$OPTARG $INCLUDE"
            ;;
        e)
            if [ ! -z "$PRUNE_WIDGET" ]
            then
                # multiple prunes, requires or
                PRUNE_WIDGET="$PRUNE_WIDGET -o "
            fi
            PRUNE_WIDGET="-path '$OPTARG' -prune"

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
        o) 
            [ ! -z "$OUTPUT" ] && error echo "only one output file can be specified\n" && usage
            OUTPUT="$OPTARG"
            ;;
        p) 
            [ ! -z "$PATTERN" ] && error echo "only one pattern can be specified\n" && usage
            PATTERN="$OPTARG"
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

FIND_CMD="find $INCLUDE $FIND_OPTS $FIND_REGEX_OPT '$PATTERN' $PRUNE_WIDGET"

debug echo "find command: $FIND_CMD"

FILES=$(eval "$FIND_CMD")
FILE_COUNT="$(echo "$FILES" | grep -v ^$ | wc -l)"

debug echo "files: \n$FILES"

info echo "found $FILE_COUNT files"

#todo: tar.gz files
#todo: destroy files
