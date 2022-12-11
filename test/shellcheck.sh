#!/bin/sh

find . -iname "*.sh" -exec shellcheck {} \;
