---
layout: doc-page
permalink: /squery/
title: squery
---

Squery stands for "Selector Query" and uses CSS style selectors to query a abstract syntax tree (AST). It is the default query engine for grasp, the other being [equery](../equery). If for some reason your query engine is set to equery, you can set it back to squery with `-s, --squery`.


## Selectors

There are several types of selectors:

`*` - the wildcard - matches any node.

`:root` - matches the root node - in most cases this will match the `Program` node at the root of JavaScript ASTs.

### Node Type

`node-type` - node type - eg. `if` or `IfStatement` - matches a node of the specified type

You can see all available node types on the [JavaScript syntax page](../syntax-js).

If for some reason the node type cannot be the first thing in a compound statement, you can also use the alternate syntax: `::node-type`.

### Identifiers

`#name` - identifier - eg. `#window` - matches an identifier with the specified name

`#/re/` matches an identifier whose name passes the specified regex. For example `#/^f/` matches `foo`.

`ident` or `Identifier` matches all identifiers in general.

### Literals

`2`, `'hi'`, `/re/g`, `true`, `null`, etc. - matches the specified literal.

`num` or `Number` matches all number literals.

`str` or `String` matches all string literals.

`bool` or `Boolean` matches as boolean literals.

`regex` or `RegExp` matches all regex literals.

`null` matches all null literals.

`literal` or `Literal` matches all literals in general.

### Attributes

You can see all available attributes on the [JavaScript syntax page](../syntax-js). There are three types of attributes, those which contain other nodes, those which contain arrays of other nodes, and those which contain primitive values (literals such as `true`, `34`, etc.). We call attributes which contain either nodes, or arrays of nodes "complex attributes", and those which contain primitive values "primitive attributes".

For instance, the update expression node has a primitive attribute called `prefix`, which contains a boolean specifying if the operator is prefix or postfix. Its `argument` attribute however is a complex one, as it consists of another node.

`[...]` style attributes match nodes who pass these attribute selectors, not the value of the attributes themselves.

`@attr` matches the attribute itself - it matches any node which exists in the specified attribute. For example, `@left` matches `2` in `2 + 3`.

`[attr]` matches a node which has the attribute `attr` eg. `[left]` matches `2 + 3` in the code `2 + 3`.

`[attr=value]` - eg. `[left=2]` - matches a node which which has the attribute `attr` with the value `value`.

You can specify sub attributes: eg. `[left.value]`, `[left.value=foo]`.

You can specify either complex or primitive attributes when using the attribute selector, eg. `[prefix=true]` will match for `++x`, and `[left=true]` will match for `true && false`. Some attributes such as `value` can be either complex (when part of a property) or primitive (when part of a literal). In this case either will work.

If you want to only match primitive attributes, you can add a `&` before your attribute name, eg. `[&value=2]`.

You can use either the `=` equals or `!=` not equals operators when searching for complex attributes.

For primitive attributes, you can use either of those, or the `<` less than, `>` greater than, `<=` less than or equal to, `>=` greater to or equal to, or `~=` regex test operators.

For example, `[value<2]` matches the literals `1` and `0`. `[value~=/^hi/]` matches the literal `"hi there"`.

There is also the `type` operator, that checks a primitive attribute's type. For example, `[value=type(Number)]` matches the literals `2` and `8.2`, but not `true`, or `"hi"`. The types you can use are the same as those specified in the [literals section](#literals).

You can specify whatever selectors you want when searching complex attributes. For example, `[object=arr #x]` will match `[y, x].length`.

### Compound

To match node which pass multiple selectors, you put them together without a space.

For example: `if[test=bi][else]` matches as if statement whose test is a binary expression and has an `else`.

### Matches

If you want to match one selector or another, you can use `:matches(selectors...)`. For example, `:matches(bi, call)` matches either a binary expression or a call expression.

You don't need the `:matches` part actually, you can simply use `(bi, call)` instead.

At the top level, you don't even need the parentheses, you can simply do `ident, if.test`.

Newlines are like commas, so if you are getting your selector from a file, you will match either the first line, or the second, or the third, etc.

For example, if this was your selector file:

    literal
    bi[op=+]

The one line equivalent would be `(literal, bi[op=+])`.

### Complex

There are several types of complex selectors.

The descendant selector: `ancestor descendant` matches any node that falls anywhere underneath the `ancestor` node that matches the `descendant` selector.

The child selector: `parent > child` matches any direct child of the `parent` which matches the `child` selector.

The sibling selector: `before ~ sibling` matches any node which has the same parent as `before`  and appears after `before`, that matches the `sibling` selector.

The adjacent selector: `before + adjacent` matches any node that has the same parent as `before`, and appears directly after `before`, which matches the `sibling` selector.

Nodes can have both attributes which are other nodes, or attributes which contain arrays of other nodes. The previous selectors treat a node which is in an array of other nodes as a direct child of that node. For instance, an array expression contains the attribute `elements` which is an array of its elements. For the code `[1, 2, 3]` the selector `arr > 1` will match `1`.

The property selector: `node.attribute` matches the node contained in the specified attribute, or if the attribute is an array containing multiple nodes, will match all the nodes in the array.

If you leave out the left hand side of any of these selectors, `:root` is assumed. If you leave out the right hand side of any of these selectors, `*` wildcard is assumed.

You have several tools at your disposal when you access an array of nodes using the property selector. For the following examples, the code `[1, 2, 3, 4]` will be used:

`:first` or `:head` matches the first element - eg. `arr.elements:first` matches `1`.

`:tail` matches all but the first element - eg. `arr.elements:tail` matches `2`, `3`, and `4`.

`:last` matches the last element - eg. `arr.elements:last` matches `4`.

`:initial` matches all the elements but the last - eg. `arr.elements:initial` matches `1` and `2`.

`:nth(Int)` matches the nth element, using zero based indexing - eg. `arr.elements:nth(2)` matches `3`.

`:nth-last(Int)` matches the nth last element, using zero based indexing - eg. `arr.elements:nth-last(2)` matches `2`.

Finally, `:slice(Int, Maybe Int)` matches the elements in the slice (same behavior as JavaScript's slice array method) - eg. `arr.elements:slice(1, 3)` matches `2` and `3`.

### Pseudo

There are several pseudo selectors.

`:first-child` matches a node which is the first child of some parent node.

`:nth-child(Int)` (zero based indexing) matches the nth node of some parent node.

`:last-child` matches the last node of some parent node.

`:last-nth-child` (zero based indexing) matches the nth last node of some parent node.

### Subject

By default, the last element in your selector is the subject, and will be matched. You can change this by appending a `!` bang to part of your selector.

For example:

`if! #x` matches all if statements that have the idenfitier `x` as a descendant.

You could be more specific and do `if!.test #x`, which matches all if statements that have the identifier `x` in their `test` attribute.

You can have multiple subjects, and each subject you specify will be matched.

For example, `if! #x!` will match both if statements that have the identifier `x` as a descendant, and identifiers `x` who are descendants of if statements.

### Not

To negate some portion of a query, use `:not(selector)`.

It can take multiple arguments, eg. `:not(ident, call)`.

For example `while[test=:not(bi)]` matches while statements whose tests are not binary expressions.

## Example

Putting a couple things we have learned together, here is the selector for an [immediately-invoked function expression](http://en.wikipedia.org/wiki/Immediately-invoked_function_expression).

These can take for form of:

    (function(){ ... })();
    (function(){ ... }).call(...);
    (function(){ ... }).apply(...);

The selector we use to match these is:

    call[callee=(func-exp, member[obj=func-exp][prop=(#call, #apply)])]

At the top level, in all cases we are matching a call. The callee (the function being called) of the call is either a function expression in the first case, or a member expression in the second and third cases. In those cases, the object that is being accessed is a function expression, and the property is either the identifier `call` in the second case, or `apply` in the third case.

As this is a common pattern, you can simply use `iife` to match it instead.
