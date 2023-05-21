# csv2json
Command-line tool to convert csv to json, written in Swift.

### How to use:   

```zsh 
git clone https://github.com/hadig/csv2json.git
```
```zsh 
swift run csv2json -i input.csv -o output.json 
```
#### Details:
```
USAGE: csv2json --input <input> --output <output> [--delimiter <delimiter>] [--minify] [--verbose] [--clean]

OPTIONS:
  -i, --input <input>
  -o, --output <output>
  -d, --delimiter <delimiter> (default: ;)
  
  -m, --minify            Do not make output pretty.
  -v, --verbose           Print output.
  -c, --clean             Drop incomplete lines.
  -h, --help              Show help information.

