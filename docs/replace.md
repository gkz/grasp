---
layout: doc-page
permalink: /replace/
title: Replacement
---

{% raw %}
You can use the `-R, --replace replacement::String` flag to replace each matched node with the `replacement` text you specify instead of printing out the matches. In grasp, positional arguments can be anywhere, not just at the end - this means that you can do `grasp selector --replace replacement file.js`, if that reads better for you.

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


The replacement text you specify replaces the entire text of the matched node in the source - if you poorly form your replacement, then the result will be poorly formed as well.
{% endraw %}

By default, the results of using `--replace` will be printed out. If you wish to write new file(s), check out the [`--to` option](../options#to), or if you wish edit the input file(s) in place, check out the [`--in-place` option](../options#in-place).
