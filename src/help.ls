{map, flatten, join, lines, unlines, chars, unchars} = require 'prelude-ls'
{syntax, syntax-flat, alias-map, attr-map-inverse, matches-map, matches-alias-map} = require 'grasp-syntax-javascript'
{pad} = require './text'
{options} = require './options'

generate-syntax-help = ->
  max-name-len = 0

  syntax-info = for category, nodes-in-cat of syntax
    for node-name, {alias, nodes = [], node-arrays = [], primitives = []} of nodes-in-cat
      get-field-strings = (type, fields) ->
        map (-> if attr-map-inverse[it] then "#type#it (#type#{ that.join ", #type"})" else "#type#it"), fields

      field-strings = (get-field-strings '', nodes) ++ (get-field-strings '%', node-arrays) ++ (get-field-strings '&', primitives)

      name-string = "#alias (#node-name)"
      name-string-len = name-string.length
      if name-string-len > max-name-len
        max-name-len := name-string-len

      [name-string, field-strings.join ', ']

  syntax-info-strings = for nodes-info in syntax-info
    node-strings = map (-> "#{ pad it.0, max-name-len }  #{ it.1 }"), nodes-info
    "\n#{ unlines node-strings}"

  prepend = '''
            JavaScript abstract syntax help:
            a list of possible node types, and their fields
            `--help node-name` for more information about a node
            `--help categories` for information about categories of nodes

            node-name (FullOfficialName)   field1, field2 (alias), field3...
            field  - this field contains another node
            %field - this field contains an array of other nodes
            &field - this field contains a primitive value, such as a boolean or a string
            -----------------------------
            '''
  append = 'Based on the Mozilla Parser API <https://developer.mozilla.org/docs/SpiderMonkey/Parser_API>'
  "#prepend#{ unlines syntax-info-strings }\n\n#append"

generate-syntax-help-for-node = (node-name) ->
  {alias, nodes, node-arrays, primitives, syntax, example, note} = syntax-flat[node-name]
  name-str = "#alias (#node-name)"

  strs = for [type, fields] in [['node',nodes],['node array',node-arrays],['primitive',primitives]] when fields
    "\n#type fields: #{
      map (-> if attr-map-inverse[it] then "#it (alias: #{ that.join ', ' })" else it), fields .join ', '}"

  syntax-str = if syntax then "\nsyntax:\n#{ unlines map (-> "  #it"), lines syntax}" else ''

  example-str = if example
    examples = for ex in [].concat example
                 unlines <| for line in lines ex
                   "  #line"
    "\nexample#{ if examples.length > 1 then 's' else ''}:\n#{ unlines examples }"
  else
    ''

  note-str = if note then "\nnote: #note" else ''

  "#name-str\n#{ '=' * name-str.length }#{ unchars strs }#syntax-str#example-str#note-str"

generate-category-help = ->
  categories = for alias, category of matches-alias-map
    full-node-names = matches-map[category]
    names = map (-> syntax-flat[it].alias), full-node-names
    "#alias (#category): #{ names.join ', '}"
  prepend = 'Categories of node types:'
  append = '''
           `--help syntax` for node information.
           `--help category-name` for further information about a category.
           '''
  "#prepend\n\n#{ unlines categories }\n\n#append"

generate-help-for-category = (name) ->
  inverted-aliases = {[value, key] for key, value of matches-alias-map}
  alias = inverted-aliases[name]

  full-node-names = matches-map[name]
  names = map (-> "#{ syntax-flat[it].alias } (#it)"), full-node-names

  name-str = "#alias (#name)"
  """
  A node type category.

  #name-str
  #{ '=' * name-str.length }
  #{ unlines names }
  """

module.exports = (generate-help, generate-help-for-option, positional) ->
  if positional.length
    help-strings = for arg in positional
      if arg is 'advanced'
        generate-help {+show-hidden}
      else if /^(--?)(\S+)/.exec arg
        [,dashes,option-name] = that
        if dashes.length is 2
          generate-help-for-option option-name
        else
          [generate-help-for-option o for o in chars option-name]
      else if arg is 'more'
        generate-help-for-option 'help'
      else if arg is 'verbose'
        for item in options
          if item.heading
            sep = '#' * (that.length + 4)
            "#sep\n# #that #\n#sep"
          else
            generate-help-for-option item.option
      else if arg is 'syntax'
        generate-syntax-help!
      else if arg is 'categories'
        generate-category-help!
      else
        if alias-map[arg] or syntax-flat[arg]
          name = alias-map[arg] or arg
          generate-syntax-help-for-node name
        else if matches-map[arg] or matches-alias-map[arg]
          name = matches-alias-map[arg] or arg
          generate-help-for-category name
        else
          "No such help option: #arg."
    help-strings |> flatten |> join '\n\n'
  else
    generate-help!
