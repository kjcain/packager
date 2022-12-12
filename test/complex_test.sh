#!/bin/sh

COLOR_CYAN='\033[0;36m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_UNSET='\033[0m'

COUNT_PASS=0
COUNT_FAIL=0

TIME_START=$(date +%s.%N)

TMP_DIR=$(mktemp -d "/tmp/$(basename "$0").XXXXXX")

info()
{
    echo "$COLOR_CYAN" "$0 | [info]" "$COLOR_UNSET\c" && "$@"
}

pass()
{
    COUNT_PASS=$(( COUNT_PASS + 1 ))
    echo "$COLOR_GREEN" "$0 | [pass]" "$COLOR_UNSET\c" && "$@"
}

fail()
{
    COUNT_FAIL=$(( COUNT_FAIL + 1 ))
    echo "$COLOR_RED" "$0 | [fail]" "$COLOR_UNSET\c" && "$@"
}

runtime()
{
    TIME_RUN=$(echo "$(date +%s.%N) - $TIME_START" | bc -l)

    info echo "runtime: $TIME_RUN seconds"
}

results()
{
    COUNT_TOTAL=$(( COUNT_PASS + COUNT_FAIL ))

    if [ "$COUNT_TOTAL" -eq 0 ]  || [ "$COUNT_FAIL" -ne 0 ]
    then
        fail echo "$COUNT_PASS / $COUNT_FAIL tests passed"
        exit 1
    else
        info echo "$COUNT_PASS / $COUNT_FAIL tests passed"
        exit 0
    fi
}

cleanup()
{
    rm -rf "$TMP_DIR"
}

complete()
{
    cleanup
    runtime
    results
}

build_test_file_sys()
{
    info echo "standing up files system"
    mkdir -p "$TMP_DIR/a/b/c/d"
    mkdir -p "$TMP_DIR/a/b/e"
    mkdir -p "$TMP_DIR/a/f/g"
    touch "$TMP_DIR/a/b/c/d/file1.txt"
    touch "$TMP_DIR/a/b/c/d/file2.txt"
    touch "$TMP_DIR/a/b/e/file3.txt"
    touch "$TMP_DIR/a/b/e/file4.txt"
    touch "$TMP_DIR/a/f/g/file5.txt"
    touch "$TMP_DIR/a/f/g/file6.txt"

    # to test excluded dirs
    mkdir -p "$TMP_DIR/a/b/c/d/h"
    mkdir -p "$TMP_DIR/a/b/e/i"
    mkdir -p "$TMP_DIR/a/f/g/j"
    touch "$TMP_DIR/a/b/c/d/h/file7.txt"
    touch "$TMP_DIR/a/b/e/i/file8.txt"
    touch "$TMP_DIR/a/f/g/j/file9.txt"

    # to test hidden dirs
    mkdir -p "$TMP_DIR/a/b/c/d/.k"
    mkdir -p "$TMP_DIR/a/b/e/.l"
    mkdir -p "$TMP_DIR/a/f/g/j/.m"
    touch "$TMP_DIR/a/b/c/d/.k/file10.txt"
    touch "$TMP_DIR/a/b/e/.l/file11.txt"
    touch "$TMP_DIR/a/f/g/.m/file12.txt"

    # to test hidden files
    touch "$TMP_DIR/a/b/c/d/.file13.txt"
    touch "$TMP_DIR/a/b/e/.file14.txt"
    touch "$TMP_DIR/a/f/g/.file15.txt"

    tree -a "$TMP_DIR"
    info echo "test filesystem ready"
}

package()
{
    info echo "packaging"
    ./packager.sh -v -m -i "$TMP_DIR/a/b/c" -i "$TMP_DIR/a/b/e" -i "$TMP_DIR/a/f/g" -e "$TMP_DIR/a/b/c/d/h"  -e "$TMP_DIR/a/b/e/i" -e "$TMP_DIR/a/f/g/j" -o "$TMP_DIR/package.tar.gz" -p ".*\.txt"
    info echo "packaging complete"
}

validate_package()
{
    info echo "validating package"

    if [ -f "$TMP_DIR/package.tar.gz" ] 
    then
        pass echo "package created"
    else 
        fail echo "failed to create package"
    fi

    FILE_COUNT=$(tar -tzf "$TMP_DIR/package.tar.gz" 2> /dev/null | wc -l )
    
    tar -tzf "$TMP_DIR/package.tar.gz"

    if [ "$FILE_COUNT" -eq 7 ]
    then
        pass echo "correct number of files in package"
    else
        fail echo "incorrect number of files in package, found $FILE_COUNT, expected 7"
    fi
}

validate_manifest()
{
    tar -xzf "$TMP_DIR/package.tar.gz" ".manifest" && mv ".manifest" "$TMP_DIR"

    if [ -f "$TMP_DIR/.manifest" ] 
    then
        pass echo "manifest created"
    else 
        fail echo "failed to create manifest"
    fi
    
    if md5sum -c "$TMP_DIR/.manifest"
    then
        pass echo "manifest valid"
    else
        fail echo "invalid manifest"
    fi
}

trap complete EXIT

info echo "starting test"
info echo "test dir: $TMP_DIR"

build_test_file_sys
package
validate_package
validate_manifest

info echo "test complete"
