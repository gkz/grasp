{partition, map} = require 'prelude-ls'
items = require 'grasp/lib/options' .options
{out, to-md} = require './common'

# figure out code reuse between this and optionator/help

name-to-raw = -> if it.length is 1 or it is 'NUM' then "-#it" else "--#it"

get-names = ({option: main-name, alias = []}) ->
  aliases = [].concat alias
  [short-names, long-names] = partition (.length is 1), aliases
  names = if main-name.length is 1
    [main-name] ++ short-names ++ long-names
  else
    short-names ++ [main-name] ++ long-names
  map name-to-raw, names .join ', '

sentencize = (str) ->
  first = str.char-at 0 .to-upper-case!
  rest = str.slice 1
  period = if /[\.!\?]$/.test str then '' else '.'
  "#first#rest#period"

out '''
---
layout: doc-page
title: Options
permalink: /options/
base_url: ../..
---

<p>This information is available in shortened form with <code>grasp --help</code>, or in full verbose form with <code>grasp --help verbose</code>. You can see an individual option's verbose help with <code>grasp --option-name</code>.

'''

for item in items
  if item.heading
    out "<h2>#that</h2>"
  else
    type = if item.enum
      "One of: #{ map (-> "`#it`"), item.enum .join ', '}"
    else if item.type is 'Boolean'
      ''
    else
      item.type

    out "<h3 id='#{item.option}' class='grasp-option-header'><code>
          #{ get-names item }#{ if type then (if item.option is 'NUM' then '::' else ' ') else ''}#type
        </code></h3>"

    rest-positional-string = if item.rest-positional then 'Everything after this option is considered a positional argument, even if it looks like an option.' else ''
    description = item.long-description or item.description and sentencize item.description
    full-description = if description and rest-positional-string
      "#description #rest-positional-string"
    else if description or rest-positional-string
      that
    else
      ''
    out "{% capture description %}#{ to-md full-description }{% endcapture %}"
    out '{{ description | markdownify }}'

    has-dl = item.default or item.example

    out '<dl class="grasp-option-info dl-horizontal">' if has-dl
    out "<dt>default:</dt><dd><code>#that</code></dd>" if item.default

    if item.example
      examples = [].concat that
      out "<dt>example#{ if examples.length > 1 then 's' else ''}:</dt>"

      out '<dd><ul class="list-unstyled">'
      for example in examples
        out "<li><code>#example</code>"
      out '</ul></dd>'

    out '</dl>' if has-dl
