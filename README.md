# packager

a tool for gathering files

## usage

```
usage: ./packager.sh -i <include_dirs> -o <output_file> -p <pattern> [-dtvhm] [-e <exclude_dirs>...]
package files into a tar.gz
arguments:
  -i <include_dirs>       directories to include (required)
  -o <output_file>        path for output of tar.gz (required)
  -d                      destructive mode, delete included files after successful packaging
  -p <pattern>            pattern for identifying files of interest (required)
  -t                      test mode, enables debug messages and does NOT package or delete files
  -v                      print debug messages
  -h                      print this help message
  -m                      create a manifest
  -e <exclude_dirs>       directories to exclude
```

## todo

- [ ] add testing for destructive mode
- [ ] add support and testing for directories using `../`
- [ ] add support and testing for multiple patterns
