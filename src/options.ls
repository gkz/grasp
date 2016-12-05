require! optionator

options =
  * heading: 'Miscellaneous'
  * option: 'help'
    alias: 'h'
    type: 'Boolean'
    description: "display this help and exit '--help more' for more help info"
    long-description: '''
                      `--help` displays help for options
                      `-h` may be used at any time in place of `--help`
                      `--help more` displays this help
                      `--help --option-name` displays further help for that option
                      for example: `--help --help` would display this information
                      `--help verbose` displays the same help as `--help --option-name`, but for all options
                      `--help syntax` displays information about JavaScript's syntax
                      `--help node-name` displays further information about a JavaScript node
                      for example: `--help if` displays more information about an if statement
                      `--help categories` displays information about node type categories
                      `--help category-name` displays further information about a node type category
                      `--help advanced` displays help for all options, including those hidden by default
                      '''
    example: ['--help', '--help --replace', '--help -R', '--help syntax']
    rest-positional: true
  * option: 'version'
    alias: 'v'
    type: 'Boolean'
    description: 'print version information and exit'
  * option: 'debug'
    alias: 'd'
    type: 'Boolean'
    description: 'output debug information'
  * option: 'jsx'
    type: 'Boolean'
    description: 'Enable JSX support'
  * option: 'extensions'
    alias: 'x'
    type: '[String]'
    description: 'comma separated list of acceptable file extensions'
    long-description: "A comma separated list of acceptable file extensions. Use a dot `.` for any extension."
    example: ['--extensions js,json', '--extensions .']
    default: 'js'
  * option: 'recursive'
    alias: 'r'
    type: 'Boolean'
    description: 'recursively search directories'
    long-description: "Recursively search directories. If files or paths are left out, then `.` is assumed."
  * option: 'exclude'
    type: '[String]'
    description: 'comma separated list of exclude patterns'
    long-description: "When recursively searching directories, exclude files matching any of this patterns. Matching is performed using 'minimatch' module. Use --minimatch-options switch to specify custom matching options."
  * option: 'minimatch-options'
    type: 'Object'
    description: 'options for minimatch module used for processing `exclude`'
    long-description: 'Sets the options for the minimatch module. See module documentation for possible options'
    default: '{dot: true}'
  * option: 'parser'
    alias: 'p'
    type: '(path::String, options::Maybe Object)'
    description: 'require path for parser, using options when calling parse'
    long-description: 'Sets the parser and options for the parser. Argument value is a tuple, with the first item being the require path, and the second an optional object with options for the parser when calling its parse function.'
    default: "(acorn, {locations: true, ecmaVersion: 6, sourceType: 'module', allowHashBang: true})"
    hidden: true
    example: '--parser "(./path/to/esprima, {loc: true})"'

  * heading: 'Replacement'
  * option: 'replace'
    alias: 'R'
    type: 'replacement::String'
    description: "replace each match with replacement, use `--help --replace` for more info"
    long-description: '''
                      Each node that is matched will be replaced with the text that you input. There are a couple of special cases:
                      The text `{{}}` will be replaced with the source of the matched node.
                      `{{selector}}` will be replaced with the first result of querying the matched node with the selector. If you used equery to get the results, then the replacement selector will be parsed as equery.
                      Since positional arguments may appear anywhere, you can place the `--replace replacement` after the selector if you wish, eg. `selector --replace replacement file.js`.
                      By default, the result of using `--replace` will be to print out the results - if you wish to create new file(s) you can check out the `--to` option, or if you wish to edit the input file(s) in place, take a look at the `--in-place` option.
                      '''
    example:
      '--replace foo'
      "--replace 'f({{}})'"
      "--replace 'while ({{.test}}) {\\n{{.then call}};\\n}'"
  * option: 'replace-file'
    alias: 'F'
    type: 'file::String'
    description: 'replace each match with contents of file'
    example: '--replace-file path/to/file'
  * option: 'replace-func'
    type: 'Function'
    description: 'use function instead of string pattern when using as library'
    hidden: true
  * option: 'to'
    alias: 't'
    type: 'Object | String'
    description: "write replaced output to file(s), `--help --to` for more info"
    long-description: '''
    If an object, the keys are the paths to the input files, and the values are the corresponding output paths.
    If a string, then the output is written to the path specified. The special character `%` is expanded to the current input file's filename.
    '''
    example: ['--to "{input.js: output.js, path/to/input2.js: path/to/output2.js}"', '--to "output/%.js"']
  * option: 'in-place'
    alias: 'i'
    type: 'Boolean'
    description: "overwrite input files with replaced output"

  * heading: 'Selector interpretation'
  * option: 'engine'
    alias: 'g'
    type: 'path::String'
    description: 'require path for query engine'
    long-description: "The require path for the query engine. The query engine must have `parse(selector) -> parsedSelector`, `queryParsed(parsedSelector, ast) -> results`, and `query(selector, ast) -> results` functions exposed."
    hidden: true
    example: '--engine path/to/engine'
  * option: 'squery'
    alias: 's'
    type: 'Boolean'
    description: "use squery - selector query - css style selectors"
  * option: 'equery'
    alias: 'e'
    type: 'Boolean'
    description: "use equery - example query - use code example with wildcards"
    long-description: "Use equery - example query - instead of the default squery. Use by typing in an example of the code you want (formatting is irrelevant), with optional wildcards. It is less powerful, but may be easier to use for simpler tasks, than squery. For more information, use `--help equery`."
  * option: 'file'
    alias: 'f'
    type: 'file::String'
    description: 'obtain selector from file'
    example: '--file path/to/selector-file'

  * heading: 'Output control'
  * option: 'max-count'
    alias: 'm'
    type: 'n::Int'
    description: 'stop after n matches'
    example: '--max-count 2'
  * option: 'line-number'
    alias: 'n'
    type: 'Boolean'
    default: 'true'
    description: 'print line number with output lines'
  * option: 'col-number'
    alias: 'b'
    type: 'Boolean'
    description: 'print column number with output lines'
  * option: 'filename'
    alias: 'H'
    type: 'Boolean'
    description: 'print the file name for each match (opposite: `--no-filename`)'
  * option: 'only-matching'
    alias: 'o'
    type: 'Boolean'
    description: 'show only the matching part of the line(s)'
  * option: 'quiet'
    alias: ['q', 'silent']
    type: 'Boolean'
    description: 'suppress all normal output'
  * option: 'files-without-match'
    alias: 'W'
    type: 'Boolean'
    description: 'print only names of files containing no match'
  * option: 'files-with-matches'
    alias: 'w'
    type: 'Boolean'
    description: 'print only names of files containing matches'
  * option: 'count'
    alias: 'c'
    type: 'Boolean'
    description: 'print only a count of matches per file'
  * option: 'color'
    alias: ['O', 'colour']
    type: 'Boolean'
    default: 'true'
    description: 'use color to highlight matches'
  * option: 'bold'
    type: 'Boolean'
    default: 'true'
    description: 'use bold font to highlight matches'
  * option: 'json'
    alias: 'j'
    type: 'Boolean'
    description: 'JSON output for matches'
    long-description: 'Prints out JSON for the output instead of formatted results. This will print out the node data as JSON, instead of the formatted text.'
  * option: 'multiline-separator'
    type: 'Boolean'
    default: 'true'
    description: 'display \'(multiline)\' keyword for multiline matches'

  * heading: 'Context control'
  * option: 'before-context'
    alias: 'B'
    type: 'n::Int'
    description: 'print n lines of leading context'
    example: ['--before-context 3', '-B 3']
  * option: 'after-context'
    alias: 'A'
    type: 'n::Int'
    description: 'print n lines of trailing context'
    example: ['--after-context 2', '-A 2']
  * option: 'context'
    alias: 'C'
    type: 'n::Int'
    description: 'print n lines of output context'
    example: ['--context 1', '-C 1']
  * option: 'NUM'
    type: 'Int'
    description: 'same as --context NUM'
    example: '-3'

module.exports = optionator do
  prepend: '''
           Usage: grasp [option]... [selector] [file]...

           Search (or --replace) for selector in file(s) or standard input.
           For more help '--help more', '--help --option-name', '--help syntax'
           Example: grasp --context 2 'if.test bi[op="<"]' file.js file2.js
           '''
  append: """
          Version {{version}}
          <http://graspjs.com/>
          """
  mutually-exclusive: [
    <[ replace replace-file replace-func ]>
  ]
  options: options
<<< {options}
