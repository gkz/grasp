{lines, unlines, filter, fold, capitalize, camelize, dasherize} = require 'prelude-ls'
levn = require 'levn'
filter = require './filter'

get-raw = (input, node) ->
  raw = if node.raw
    that
  else if node.start?
    input.slice node.start, node.end
  else if node.key? and node.value? # property
    input.slice node.key.start, node.value.end
  else
    ''
  node.raw = raw
  "#{ node.raw-prepend or '' }#raw#{ node.raw-append or '' }"

filter-regex = //
               \s+\|\s+
               ([-a-zA-Z]+)
               ((?:\s+(?:'(?:\\'|[^'])*'|"(?:\\"|[^"])*"|[^\|\s]+))*)
               //

replacer = (input, node, query-engine) ->
  (, replacement-arg) ->
    if /^\s*\|\s+/.test replacement-arg
      orig-results = [node]
      [, ...filters] = " #{ replacement-arg.trim! }".split filter-regex # prepend space so regex works
    else
      [selector, ...filters] = replacement-arg.trim!.split filter-regex
      if node._named?[selector]
        orig-results = [].concat that
      else
        try
          orig-results = query-engine.query selector, node
        catch
          orig-results = query-engine.query replacement-arg, node
          filters := []
    if orig-results.length
      results = orig-results
      raw-prepend = ''
      raw-append = ''
      join = null
      text-operations = []

      while filters.length
        filter-name = filters.shift!
        args-str = filters.shift!.trim!
        args-str += filters.shift! # extra
        args = levn.parse 'Array', args-str
        filter filter-name, args, {raw-prepend, raw-prepend, results, text-operations}

      raw-results = [get-raw input, result for result in results]
      output-string = "#raw-prepend#{ if join? then raw-results.join join else raw-results.0 }#raw-append"
      if text-operations.length
        fold (|>), output-string, text-operations
      else
        output-string
    else
      ''

get-replacement-func = (replacement, input, query-engine) ->
  if typeof! replacement is 'Function'
    (node) ->
      replacement do
        -> get-raw input, it
        node
        -> query-engine.query it, node
        node._named
  else
    replacement-prime = replacement.replace /\\n/g, '\n'
    (node) ->
      replacement-prime
      .replace /{{}}/g, -> get-raw input, node # func b/c don't want to call get-raw unless we need to
      .replace /{{((?:[^}]|}[^}])+)}}/g, replacer input, node, query-engine

replace = (replacement, input, nodes, query-engine) ->
  input-lines = lines input
  col-offset = 0
  line-offset = 0
  last-line = null
  prev-node = end: 0
  replace-node = get-replacement-func replacement, input, query-engine

  for node in nodes
    continue if node.start < prev-node.end
    {start, end} = node.loc

    start-line-num = start.line - 1 + line-offset
    end-line-num = end.line - 1 + line-offset
    number-of-lines = end-line-num - start-line-num + 1

    col-offset := if last-line is start-line-num then col-offset else 0

    start-col = start.column + col-offset
    end-col = end.column + if start-line-num is end-line-num then col-offset else 0

    replace-lines = lines replace-node node
    start-line = input-lines[start-line-num]
    end-line = input-lines[end-line-num]

    start-context = start-line.slice 0, start-col
    end-context = end-line.slice end-col

    replace-lines.0 = "#start-context#{replace-lines.0 ? ''}"
    replace-last = replace-lines[*-1]

    end-len = replace-last.length
    replace-lines[*-1] = "#replace-last#end-context"
    input-lines.splice start-line-num, number-of-lines, ...replace-lines

    line-offset += replace-lines.length - number-of-lines
    col-offset += end-len - end-col
    last-line := end-line-num + line-offset
    prev-node := node

  unlines input-lines

module.exports = {replace}
