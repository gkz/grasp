{lines, unlines} = require 'prelude-ls'

get-raw = (input, node) ->
  return that if node.raw
  input.slice node.start, node.end

replacer = (input, node, query-engine) ->
  (, selector) ->
    results = query-engine.query selector, node
    if results.0
      get-raw input, that
    else
      ''
process-replacement = (replacement, input, node, query-engine) ->
  replacement
    .replace /\\n/g, '\n'
    .replace /{{}}/g, get-raw input, node
    .replace /{{((?:[^}]|}[^}])+)}}/g, replacer input, node, query-engine

replace = (replacement, input, nodes, query-engine) ->
  input-lines = lines input
  col-offset = 0
  line-offset = 0
  last-line = null
  prev-node = end: 0

  for node in nodes
    continue if node.start < prev-node.end
    {start, end} = node.loc

    start-line-num = start.line - 1 + line-offset
    end-line-num = end.line - 1 + line-offset
    number-of-lines = end-line-num - start-line-num + 1

    col-offset := if last-line is start-line-num then col-offset else 0

    start-col = start.column + col-offset
    end-col = end.column + if start-line-num is end-line-num then col-offset else 0

    replace-lines = lines process-replacement replacement, input, node, query-engine
    start-line = input-lines[start-line-num]
    end-line = input-lines[end-line-num]

    start-context = start-line.slice 0, start-col
    end-context = end-line.slice end-col

    replace-lines.0 = "#start-context#{replace-lines.0}"
    replace-last = replace-lines[*-1]

    end-len = replace-last.length
    replace-lines[*-1] = "#replace-last#end-context"
    input-lines.splice start-line-num, number-of-lines, ...replace-lines

    line-offset += replace-lines.length - number-of-lines
    col-offset := end-len - end-col
    last-line := end-line-num + line-offset
    prev-node := node

  unlines input-lines .replace /\n$/, ''

module.exports = {replace}
