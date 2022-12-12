# packager

a tool for gathering files

## usage

```
usage: ./packager.sh -i [<include_dirs>] [-e [<exclude_dirs>]] [-dtEFPv] -o <output_file> -p <pattern>
package files into a tar.gz
arguments:
  -i <include_dirs>       directories to include (required)
  -d                      destructive mode, delete included files after successful packaging
  -e <exclude_dirs>       directories to exclude
  -t                      test mode, enables debug messages and does NOT package or delete files
  -v                      print debug messages
  -h                      print this help message
  -m                      create a manifest
  -o <output_file>        path for output of tar.gz (required)
  -p <pattern>            pattern for identifying files of interest (required)
```
