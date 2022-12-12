# packager

a tool for gathering files

## usage

```
usage: ./packager.sh -i <include_dirs> -o <output_file> -p <pattern> [-dtvhm] [-e <exclude_dirs>...]
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
```

### include directories

directories to search for files matching a given pattern in naming. multiple can be defined, however, at least one is required

### output file

name of the tar.gz file to output to. this field is required

### pattern

search pattern for files, accepts a regex that is directly passed to the find command

### destructive mode

delete files after they are gathered successfully

### test mode

print the planned commands but do not execute any that would cause modifications. will also set verbose mode

### verbose mode

print debug messages

### help

show the usage dialog

### manifest mode

generate a manifest of md5 checksums for all selected files. this will be placed in a .manifest file a the root of the output file

### exclude directories

directories to disallow when searching for files

## todo

- [ ] add testing for destructive mode
- [ ] add support and testing for directories using `../`
- [ ] add support and testing for multiple patterns
