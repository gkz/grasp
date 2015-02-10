{map, keys, unlines} = require 'prelude-ls'
{syntax, syntax-flat, attr-map-inverse, matches-map, matches-alias-map} = require 'grasp-syntax-javascript'
{out, star-to-em, to-md} = require './common'

out '''
---
layout: doc-page
title: JavaScript Syntax
permalink: /docs/syntax-js/
base_url: ../..
---

<p>A node can have three different types of attributes. An attribute containing another node, an attribute containing an array of other nodes, or an attribute containing a primitive value such as a boolean, string, or number.

<p>Use <code>grasp --help syntax</code> for an overview of the syntax, and <code>grasp --help node-type</code> (eg. <code>grasp --help if</code>) for more about information about a node type.

<p>Skip to <a href="#statements">statements</a>, <a href="#expressions">expressions</a>, <a href="#declarations">declarations</a>, <a href="#clauses">clauses</a>, or <a href="#categories">categories of node types</a>.

<p>Based on the <a href="https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API">Mozilla SpiderMonkey AST format</a>.
'''

field-type-map = nodes: 'node', node-arrays: 'node array', primitives: 'primitive'

process-attr-name = ->
  if attr-map-inverse[it]
    "#it (#{ that.join ", "})"
  else
    it

for category, nodes-in-cat of syntax
  out "<h2 id='#{ category.to-lower-case! }'>#category</h2>"

  for node-name, {alias, syntax: syntax-desc, example, nodes, node-arrays, primitives, note}:node of nodes-in-cat
    out "<h3 id='#alias'>#alias (#node-name)</h3>"

    has-dl = nodes or node-arrays or primitives or syntax-desc or example

    out '<dl class="grasp-syntax-info dl-horizontal">' if has-dl

    for type, children of {nodes, node-arrays, primitives} when children
      out """
          <dt>#{field-type-map[type]} attributes:</dt>
          <dd>#{ (map process-attr-name, children).join ',&nbsp;&nbsp;'}</dd>
          """

    out '</dl>' if has-dl

    out """
        <h4 class='grasp-syntax-subheading'>syntax:</h4>
        <pre>#{ star-to-em that }</pre>
        """ if syntax-desc

    if example
      examples = [].concat example
      out """
          <h4 class='grasp-syntax-subheading'>example#{ if examples.length > 1 then 's' else ''}:</h4>
          {% highlight javascript %}\n#{ unlines examples }\n{% endhighlight %}
          """

    if note
      out '<h4 class="grasp-syntax-subheading">note:</h4>'
      out "<p>#note"

out '<h2 id="categories">Categories</h2>'
out '<p>Categories of node types - use <code>grasp --help categories</code> for an overview, and <code>grasp --help category-name</code> for further information about a specific category.'

for alias, category of matches-alias-map
  out "<h3 id='#alias'>#alias (#category)</h3>"
  full-node-names = matches-map[category]
  names = map (-> syntax-flat[it].alias), full-node-names
  out '<ul>'
  for name in names
    out "<li>#name</li>"
  out '</ul>'
