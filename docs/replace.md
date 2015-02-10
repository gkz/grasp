---
layout: doc-page
title: Replacement
permalink: /docs/replace/
base_url: ../..
---

You can use the `-R, --replace replacement::String` flag to replace each matched node with the `replacement` text you specify instead of printing out the matches. In Grasp, positional arguments can be anywhere, not just at the end - this means that you can do `grasp selector --replace replacement file.js`, if that reads better for you.

For a bunch of examples, check out [Refactoring your JavaScript code with Grasp]({{ page.base_url }}/blog/2014/01/07/refactoring-javascript-with-grasp/).

{% raw %}

There are a couple of special cases in the replacement text. First, the text `{{}}` will be replaced with the source of the matched node.

For instance, the replacement text `f({{}})` would result in each match being replaced with a call to the function `f` with the match as its argument.

    $ cat file.js
    if (y < 2) {
      window.x = y + z;
    }
    $ grasp '[left=#y]' --replace 'f({{}})' file.js
    if (f(y < 2)) {
      window.x = f(y + z);
    }

Second, the text `{{selector}}` will be replaced with the first result of querying the matched node with the specified selector. The query engine used to process the selector will be the same as you used for searching, eg. if you used equery to search for matches (with the `-e, --equery` flag), then the replacement selector will also use equery.

An example:

    $ cat file.js
    if (y < 2) {
      window.x = y + z;
    }
    $ grasp if --replace 'while ({{.test}}) {\n  f(++{{assign bi.left}});\n}' file.js
    while (y < 2) {
      f(++y);
    }

If a node has any named matches (currently only a feature of equery, eg. `$name` or `_$items`), you can access this named submatch by simply using the name instead of a selector, eg. `{{name}}`, `{{items}}`.

If more than one match is found, the first match is used. If you would like to print out more than one match, you can use the `join` [filter](#filters).

The replacement text you specify replaces the entire text of the matched node in the source - if you poorly form your replacement, then the result will be poorly formed as well.

{% endraw %}

By default, the results of using `--replace` will be printed out. If you wish to write new file(s), check out the [`--to` option]({{ page.base_url }}/docs/options#to), or if you wish edit the input file(s) in place, check out the [`--in-place` option]({{ page.base_url}}/docs/options#in-place).

### Filters

{% raw %}

You can append a variety of filters to your selector in the `{{selector}}` syntax. Each filter starts off with a spaced pipe, eg. `{{ selector | filter1 | filter2 }}`.

If the `selector` is left out (eg. `{{ | filter | filter2 }}`), the filters are applied to the whole matched node.

Filters may have zero of more arguments. Arguments are listed after the filter name and are separated by a comma. `{{ selector | filter arg0, arg1 }}`.

The available filters are (the code `[1, 2, 3, 4];` will be used for the examples):

#### join
`join [separator]` - Takes the list of matches and joins them with the optional separator argument. If no separator is specified, they are joined with an empty string.

  Eg. `grasp arr --replace '[{{.elements | join "," }}]'` &rarr; `[1,2,3,4];`

#### prepend
`prepend args...` - Prepends (aka unshifts) its arguments to the list of matches.

  Eg. `grasp arr --replace '[{{.elements | prepend 0 | join "," }}]'` &rarr; `[0,1,2,3,4];`

#### append
`append args...` - Appends (aka pushes) its arguments to the list of matches.

  Eg. `grasp arr --replace '[{{.elements | append 5 | join "," }}]'` &rarr; `[1,2,3,4,5];`

#### before
`before arg` - Prepends its text argument to the entire result. Equivalent to `arg{{}}`. More useful with `each`.

  Eg. `grasp arr --replace '{{ 1 | before "0." }}'` &rarr; `0.1;`

#### after
`after arg` - Appends its text argument to the entire result. Equivalent to `{{}}arg`. More useful with `each`.

  Eg. `grasp arr --replace '{{ 1 | after 0 }}'` &rarr; `10;`

#### wrap
`wrap arg, [arg]` - Wraps its text arguments around the entire result. If only one argument is supplied, it uses that for both before and after. If two arguments are supplied, the first argument is prepended, and the second is appended. Equivalent to `arg{{}}arg`. Again, this is more useful with `each`.

Eg. `grasp arr --replace '{{ 1 | wrap \" }}'` &rarr; `"1";`

Eg. `grasp arr --replace '{{ 1 | wrap [ ] }}'` &rarr; `[1];`

#### each
`each filter, [args...]` - Takes a filter (either `before`, `after`, or `wrap`) and applies it to each matched node.

Eg. `grasp arr --replace '[{{.elements | each before 1 | join "," }}]'` &rarr; `[11,12,13,14];`

Eg. `grasp arr --replace '[{{.elements | each after 0 | join "," }}]'` &rarr; `[10,20,30,40];`

Eg. `grasp arr --replace '[{{.elements | each wrap ( ) | join "," }}]'` &rarr; `[(1),(2),(3),(4)];`

#### nth
`nth num` - Takes the nth node of the matched results. Zero based indexing.

Eg. `grasp arr --replace '{{.elements | nth 0 }}'` &rarr; `1;`

#### nth-last
`nth-last num` - Takes the nth last node of the matched results. Zero based indexing.

Eg. `grasp arr --replace '{{.elements | nth-last 0 }}'` &rarr; `4;`

#### first
`first` - Takes the first node of the matched results. Equivalent to `nth 0`.

Eg. `grasp arr --replace '{{.elements | first }}'` &rarr; `1;`

#### tail
`tail` - Takes all but the first node of the matched results.

Eg. `grasp arr --replace '[{{.elements | tail | join "," }}]'` &rarr; `[2,3,4];`

#### last
`last` - Takes the last node of the matched results. Equivalent to `nth-last 0`.

Eg. `grasp arr --replace '{{.elements | last | join "," }}'` &rarr; `4;`

#### initial
`initial` - Takes all but the last node of the matched results.

Eg. `grasp arr --replace '[{{.elements | initial | join "," }}]'` &rarr; `[1,2,3];`

#### slice
`slice num, [num]` - Acts like JavaScript's `slice` on the matched results.

Eg. `grasp arr --replace '[{{.elements | slice 2 | join "," }}]'` &rarr; `[3,4];`

Eg. `grasp arr --replace '[{{.elements | slice 2 3 | join "," }}]'` &rarr; `[3];`

#### reverse
`reverse` - Reverses the list of matched results.

Eg. `grasp arr --replace '[{{.elements | reverse | join "," }}]'` &rarr; `[4,3,2,1];`

#### replace
`replace regex-pattern, replacement` - String replacement of matched result, just like JavaScript's `"String".replace(pattern, replacement)` function.

#### lowercase

`lowercase` - Lowercases string result of matched output, just like JavaScript's `"String".toLowerCase()`

#### uppercase

`uppercase` - Uppercases string result of matched output, just like JavaScript's `"String".toUpperCase()`

#### trim

`trim` - Trims string result of matched output, just like JavaScript's `"String".trim()`

#### capitalize

`capitalize` - Capitalizes the string result of matched output.

#### uncapitalize

`uncapitalize` - Uncapitalizes the string result of matched output.

#### camelize

`camelize` - Camelizes the string result of matched output.

#### dasherize

`dasherize` - Dasherizes the string result of matched output.

#### substring

`substring startIndex, [endIndex]` - Gets substring of string result of matched output, just like JavaScript's `"String".substring(startIndex, endIndex)`

#### substr

`substring startIndex, [length]` - Gets substring of string result of matched output, just like JavaScript's `"String".substr(startIndex, length)`

#### str-slice

`str-slice startIndex, [endIndex]` - Gets substring of string result of matched output, just like JavaScript's `"String".slice(startIndex, endIndex)`

{% endraw %}
