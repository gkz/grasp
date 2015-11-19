require! {
  path
  acorn
  'grasp-squery': squery
  'grasp-equery': equery
  async
}
{min, sort-with, lines, chars, split, join,  map, Obj} = require 'prelude-ls'
{format-result, format-name, format-count}:format = require './format'
{replace} = require './replace'
{parse: parse-options,  generate-help, generate-help-for-option} = require './options'
help = require './help'
_console = console

version = '0.4.0-beta1'

run = ({
  args
  error = -> throw new Error it
  callback = ->
  exit = ->
  data = false
  stdin
  fs = require 'fs'
  text-format = require 'cli-color'
  input
  console = _console
} = {}) ->
  unless args?
    error 'Error: Must specify arguments.'
    exit 2
    return

  try
    {_:positional, debug}:options = parse-options args
  catch
    error e.message
    exit 2
    return

  if debug
    console.time 'everything'
    console.log 'options:'
    console.log options

  if options.version
    version-string = "grasp v#version"
    callback version-string
    exit 0, version-string
    return

  get-help = (positional = []) ->
    help generate-help, generate-help-for-option, positional, {version}

  if options.help
    help-string = get-help positional
    callback help-string
    exit 0, help-string
    return

  query-engine = if options.engine?
    require options.engine
  else if options.squery
    squery
  else if options.equery
    equery
  else
    squery

  [parser, parser-options] = switch options.parser.0
                             | 'acorn'   => [acorn, options.parser.1]
                             | otherwise => [require options.parser.0; options.parser.1]

  options.context ?= options.NUM ? 0
  options.before-context ?= options.context
  options.after-context ?= options.context

  if options.file?
    try
      selector = fs.read-file-sync that, 'utf8'
    catch
      error "Error: No such file '#{options.file}'."
      exit 2
      return
    targets = positional
  else
    selector = positional.0
    targets = positional[1 to]

  targets = (if options.recursive then ['.'] else ['-']) unless targets.length
  targets-len = targets.length

  if options.replace?
    replacement = that
  if options.replace-func
    replacement = that
  else if options.replace-file
    try
      replacement = fs.read-file-sync that, 'utf8' .replace /([\s\S]*)\n$/ '$1'
    catch
      error "Error: No such file '#{options.replace-file}'."
      exit 2
      return

  unless selector?
    error 'Error: No selector specified.'
    help-string = get-help!
    callback help-string
    exit 2, help-string
    return

  if options.filename?
    options.display-filename = that
  else if targets-len > 1
    options.display-filename = true
  else
    try
      is-dir = if targets.0 is '-' then false else fs.lstat-sync targets.0 .is-directory!
      if is-dir and not options.recursive
        console.warn "'#{targets.0}' is a directory. Use '-r, --recursive' to recursively search directories."
      options.display-filename = is-dir
    catch
      error "Error: No such file or directory '#{targets.0}'."
      exit 2
      return

  color = Obj.map (-> if options.color then it else (-> "#it")), text-format{green, cyan, magenta, red}
  bold = if options.bold then text-format.bold else (-> "#it")
  text-format-funcs = {color, bold}

  results-data = []
  results-format = 'default'
  call-callback = not options.quiet and not options.json and not options.to and not options.in-place
  out = !->
    results-data.push it
    callback it if call-callback

  console.time 'parse-selector' if debug
  parsed-selector = query-engine.parse selector
  if debug
    console.time-end 'parse-selector'
    console.log 'parsed-selector:'
    console.log JSON.stringify parsed-selector

  results-sort-func = (a, b) ->
    a-start = a.loc.start
    b-start = b.loc.start
    line-diff = a-start.line - b-start.line
    if line-diff is 0 then a-start.column - b-start.column else line-diff

  search = (name, input) !->
    console.time "search-total:#name" if debug

    clean-input = input.replace /^#!.*\n/ ''
    try
      console.time "parse-input:#name" if debug
      parsed-input = parser.parse clean-input, parser-options
      console.time-end "parse-input:#name" if debug
    catch
      throw new Error "Error: Could not parse JavaScript from '#name'. #{e.message}"

    console.time "query:#name" if debug
    results = query-engine.query-parsed parsed-selector, parsed-input
    console.time-end "query:#name" if debug

    results-len = results.length

    count = if options.max-count? then min that, results-len else results-len

    sorted-results = sort-with results-sort-func, results
    sliced-results = sorted-results[til count]

    if replacement?
      try
        replaced = replace replacement, clean-input, sliced-results, query-engine
        if options.to or options.in-place
          results-format := 'pairs'
          out [name, replaced]
        else
          out replaced
      catch
        console.error "#name: Error during replacement. #{e.message}."
    else if options.count
      if options.display-filename
        if options.json or data
          results-format := 'pairs'
          out [name, count]
        else
          out format-count color, count, name
      else
        out if options.json or data then count else format-count color, count
    else if options.files-without-match or options.files-with-matches
      if options.files-with-matches and count or options.files-without-match and not count
        out if options.json or data then name else format-name color, name
    else
      if options.json or data
        if options.display-filename
          results-format := 'pairs'
          out [name, sliced-results]
        else
          results-format := 'lists'
          out sliced-results
      else
        input-lines = lines clean-input
        input-lines-length = clean-input.length

        for result in sliced-results
          out format-result name, input-lines, input-lines-length, text-format-funcs, options, result

    console.time-end "search-total:#name" if debug

  process-results = ->
    if results-data.length
      if results-format is 'pairs'
        Obj.pairs-to-obj results-data
      else if results-format is 'lists'
        if targets-len is 1 then results-data.0 else results-data
      else
        results-data
    else
      []

  get-to-map = (input-paths) ->
    if options.in-place
      Obj.lists-to-obj input-paths, input-paths
    else if typeof! options.to is 'Object'
      options.to
    else # typeof! options.to is 'String'
      mapping = {}
      for input-path in input-paths
        mapping[input-path] = options.to.replace /%/, path.basename input-path, (path.extname input-path)
      mapping

  end = (input-paths) ->
    exit-code = if results-data.length then 0 else 1
    processed-results = process-results!
    if replacement and options.to or options.in-place
      to-map = get-to-map input-paths
      for input-path, contents of processed-results
        target-path = to-map[input-path]
        if target-path is '-'
          callback contents
        else
          fs.write-file-sync target-path, contents if target-path
    else if options.json
      json-string = JSON.stringify processed-results
      callback json-string
    console.time-end 'everything' if debug
    exit exit-code, (if options.json then json-string else processed-results)

  exts = options.extensions
  test-ext = if exts.length is 0 or exts.length is 1 and exts.0 is '.'
    -> true
  else
    (.match //\.(?:#{ exts.join '|' })$//)

  target-paths = []
  search-target = (base-path, up-path) ->
    (target, done) !->
      try
        if target is '-'
          throw new Error 'Error: stdin not defined.' unless stdin
          target-paths.push '-'
          output = ''
          stdin.set-encoding 'utf-8'
          stdin.on 'data' (output +=)
          stdin.on 'end' ->
            try
              search '(standard input)', output
            catch
              console.error e.message
            done!
          stdin.resume!
        else
          target-path = path.resolve up-path, target
          stat = fs.lstat-sync target-path
          if stat.is-directory! and options.recursive
            async.each-series (fs.readdir-sync target-path), (search-target base-path, target-path), ->
              async.setImmediate ->
                done!
          else if stat.is-file! and test-ext target
            file-contents = fs.read-file-sync target-path, 'utf8'
            display-path = path.relative base-path, target-path
            target-paths.push display-path
            search display-path, file-contents
            done!
          else
            done!
      catch
        console.error e.message
        done!

  if input
    search '(input)', input
    end ['-'] # as if stdin for replacement
  else
    cwd = process.cwd!
    async.each-series targets, (search-target cwd, cwd), -> end target-paths
    void

get-query-engine = -> {squery: 'grasp-squery', equery: 'grasp-equery'}[it] or it
run <<<
  VERSION: version
  search: (engine, selector, input) -->
    run do
      args: {_: [selector], engine: get-query-engine engine}
      input: input
      data: true
      exit: (, results) -> results
  replace: (engine, selector, replacement, input) -->
    args =
      _: [selector]
      engine: (get-query-engine engine)

    if typeof! replacement is 'Function'
      args.replace-func = replacement
    else
      args.replace = replacement

    run {args, input, exit: (, results) -> results.0}

module.exports = run
