{id, compact, unlines, min, max} = require 'prelude-ls'

module.exports = {format-result, format-name, format-count}

function format-result name, input-lines, input-lines-length, {color, bold}, options, node
  res-start-line = node.loc.start.line - 1
  start-line = max res-start-line - options.before-context, 0

  res-end-line = node.loc.end.line - 1
  end-line = min res-end-line + options.after-context, input-lines-length - 1

  start-col = node.loc.start.column
  end-col = node.loc.end.column

  highlight = bold >> color.red
  only-match = options.only-matching

  output-lines = for line-num from start-line to end-line
    line = input-lines[line-num]

    if line-num < res-start-line
    or line-num > res-end-line
      if only-match then '' else line
    else if line-num is res-start-line is res-end-line
      start = if only-match then '' else line.slice 0, start-col
      middle = line.slice start-col, end-col
      end = if only-match then '' else line.slice end-col
      "#start#{highlight middle}#end"
    else if res-start-line < line-num < res-end-line
      highlight line
    else if line-num is res-start-line
      start = if only-match then '' else line.slice 0, start-col
      rest = line.slice start-col
      "#start#{highlight rest}"
    else # line-num is res-end-line
      end = if only-match then '' else line.slice end-col
      rest = line.slice 0, end-col
      "#{highlight rest}#end"

  clean-lines = (if only-match then compact else id) output-lines
  multiline = clean-lines.length > 1
  output-string = unlines clean-lines

  display-start-line = node.loc.start.line
  display-end-line = node.loc.end.line
  location-string = if options.col-number
    "#{ color.green "#{ if options.line-number then "#display-start-line," else '' }
                     #{ start-col }" }
     #{ color.cyan '-' }
     #{ color.green "#{ if options.line-number then "#display-end-line," else '' }
                     #{ end-col - 1 }" }"
  else if options.line-number
    if multiline
      if display-start-line is display-end-line
        color.green display-start-line
      else
        "#{ color.green display-start-line }
         #{ color.green '-' }
         #{ color.green display-end-line }"
    else
      color.green display-start-line
  else
    ''

  separator-string =
    "#{ if multiline and options.multiline-separator then color.cyan "#{ if location-string.length then ':' else ''}(multiline)" else ''}
     #{ if location-string.length or multiline and options.multiline-separator then color.cyan ':' else '' }
     #{ if multiline and (location-string.length or options.multiline-separator) then '\n' else ''}"

  name-string = if options.display-filename then "#{ format-name color, name }#{ color.cyan ':' }" else ''

  "#name-string
   #location-string
   #separator-string
   #output-string"

function format-name color, name
  color.magenta name

function format-count color, count, name
  "#{if name then "#{format-name color, name}#{color.cyan ':'}" else ''}#count"
