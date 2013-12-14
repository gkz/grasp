{lines, unlines, filter} = require 'prelude-ls'

get-raw = (input, node) ->
  raw = if node.raw
    that
  else if node.start?
    input.slice node.start, node.end
  else if node.key? and node.value? # property
    input.slice node.key.start, node.value.end
  else
    ''
  "#{ node.raw-prepend or '' }#raw#{ node.raw-append or '' }"

args-regex = //
               '((?:\\'|[^'])*)'
             | "((?:\\"|[^"])*)"
             | (\\.)
             | (\S+)
             //g

filter-regex = //
               \s+\|\s+
               ([-a-zA-Z]+)
               ((?:\s+(?:'(?:\\'|[^'])*'|"(?:\\"|[^"])*"|[^\|\s]+))*)
               //

replacer = (input, node, query-engine) ->
  (, replacement-arg) ->
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

      while filters.length
        filter-name = filters.shift!
        args-str = filters.shift!.trim!
        args-str += filters.shift! # extra
        args = []
        if args-str
          while args-regex.exec args-str
            args.push (filter (-> it?), that).1.replace /\\(.)/g '$1'
          args-regex.last-index = 0
        if filter-name in <[ prepend before after prepend append wrap nth nth-last slice each ]> and not args.length
          throw new Error "No arguments supplied for '#filter-name' filter"

        switch filter-name
        | 'join' =>
          join := if args.length then args.0 else ''
        | 'before' =>
          raw-prepend := "#{args.0}#raw-prepend"
        | 'after' =>
          raw-append += args.0
        | 'wrap' =>
          [pre, post] = if args.length is 1 then [args.0, args.0] else args
          raw-prepend := "#pre#raw-prepend"
          raw-append += post
        | 'prepend' =>
          for arg in args then results.unshift type: 'Raw', raw: arg
        | 'append' =>
          for arg in args then results.push type: 'Raw', raw: arg
        | 'each' =>
          throw new Error "No arguments supplied for 'each #{args.0}'" if args.length < 2
          switch args.0
          | 'before' =>
            for result in results
              result.raw-prepend = "#{args.1}#{ result.raw-prepend or ''}"
          | 'after' =>
            for result in results
              result.raw-append = "#{ result.raw-append or ''}#{args.1}"
          | 'wrap' =>
            [pre, post] = if args.length is 2 then [args.1, args.1] else [args.1, args.2]
            for result in results
              result.raw-prepend = "#{pre}#{ result.raw-prepend or ''}"
              result.raw-append = "#{ result.raw-append or ''}#{post}"
          | otherwise =>
            throw new Error "'#{args.0}' is not supported by 'each'"
        | 'nth' =>
          n = +args.0
          results := results.slice n, (n + 1)
        | 'nth-last' =>
          n = results.length - +args.0 - 1
          results := results.slice n, (n + 1)
        | 'first', 'head' =>
          results := results.slice 0, 1
        | 'tail' =>
          results := results.slice 1
        | 'last' =>
          len = results.length
          results := results.slice (len - 1), len
        | 'initial' =>
          results := results.slice 0, (results.length - 1)
        | 'slice' =>
          results := [].slice.apply results, args
        | 'reverse' =>
          results.reverse!
        | otherwise =>
          throw new Error "Invalid filter: #filter-name#{ if args-str then " #args-str" else ''}"
      raw-results = [get-raw input, result for result in results]
      "#raw-prepend#{ if join? then raw-results.join join else raw-results.0 }#raw-append"
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
