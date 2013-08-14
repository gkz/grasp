---
layout: doc-page
permalink: /equery/
title: equery
---

Equery stands for "Example Query" and uses JavaScript code examples with wildcards and some other special syntax to query the abstract syntax tree (AST). It is the second query engine for grasp, the default being [squery](../squery). You must use the `-e, --equery` flags to enable equery.

Equery is less powerful than squery, but may be simpler and easier to use in some cases.

For the query, you simply write out JavaScript code. Equery then parses the code you wrote, and the input code, and walks down the input abstract syntax tree (AST) and tries to find a portion of code that looks like your input code.

Even without anything special, this is already more powerful than simply text based search as it compares the underlying abstract syntax, not the textual representation of the code - formatting differences are irrelevant.

For example the selector `if(x){f(x);}` matches the code:

    if (x) {
      f(x);
    }

because they have the same underlying meaning, even if they have different formatting.

But we can make equery much more interesting than that - and we can do so with a bit of special syntax:

First, the wildcard `__` (a double underscore), which can be placed anywhere an expression, statement, or identifier can be placed. It will match anything.

For example, modifying our previous selector, we could do `if(__){ __ }` which matches any if statement with any test, and one statement in its body.

Other examples include: `function __(__) { __ }` which matches a function with any name, one paramter of any identifier, and a body with one statement.

As you've noticed, this only matches *one* thing, what if we want more?

You can use `_$`, which matches zero or more elements. Modifying our previous example, `function __(_$) { _$ }` matches a function with any name, any amount of parameters, and any amount of statements.

The `_$` can be used in conjunction with other elements - for instance `[1, _$]` matches an array literal where the first element is the literal `1`, and has zero or more other elements. `[_$, 9]` matches an array literal where the last element is the literal `9`, and has zero of more elements before that.

You can match a node type as well, simply prepend an underscore to the type, and replace any dashes with underscores. For instance, to match a for in statement, use `_for_in`.

You can also match types of literals, also by prepending an underscore. For instance `_num` to find any number literal. Other possibilities: `_str`, `_regexp`, `_bool`.

After a wildcard `__`, node type or literal type, you can append an attribute selector as well:

`__[right]` matches any node that has a `right` attribute.

`__[right=2]` matches any node that has a `right` attribute with the value `2`. Use `!=` for not equals.

You can do several attributes down, for example `__[left.object={x: 2}]`.

To match more than one attribute, simply place them together: `__[left=2][right=x]` matches `2 + x`.

You can see all available node types and their attributes on the [JavaScript syntax page](../syntax-js).
