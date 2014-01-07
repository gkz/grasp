---
layout: default
title: FAQ
permalink: /faq/
base_url: ..
---

## What are some use cases?

Any time you would use `grep` or `sed` to search or replace your JavaScript code, you can use Grasp instead.

The replace function is great for easily refactoring your code - see the blog post [Refactoring your JavaScript code with Grasp]({{ page.base_url }}/blog/2014/01/07/refactoring-javascript-with-grasp/).

In general Grasp allows you to search in ways you didn't even think were possible. For instance, say you wanted to find a specific function in your codebase, but couldn't remember where it was. All you remember was that it was part of an object literal, and it called the function `isEven` somewhere in the body. ie. this code lies somewhere in your codebase:

    var obj = {
      toEven: function(x) {
        if (isEven(x)) {
          return x;
        } else {
          return x + 1;
        }
      }
    };

You could simply search for `isEven` with grep, but that would find all cases of its use, which not what you want. Furthermore, grep won't even limit itself to finding identifiers named `isEven`, it will find the text `isEven` in strings or comments as well.

Or, you can use Grasp to find exactly what you want:

<pre><code>
$ grasp -r 'obj.props func! #isEven' .
file.js:2-8:(multiline):
  toEven: <span class="bold red">function(x) {
    if (isEven(x)) {
      return x;
    } else {
      return x + 1;
    }
  }</span>
</code></pre>

There are many other possibilities - check out the [documentation](../docs).

## What does the name mean?
"grasp" could stand for (depending on your mood) Great/Good/Goddamn/Green Replace And Search Program.

The word "grasp", when used as a verb can mean:

> get mental hold of; comprehend fully

This seems apt for a program which lets you search using the more meaningful structure behind your code, rather than simply its textual representation.

## I found a bug, where can I report it?
The [GitHub issues section for Grasp](https://github.com/gkz/grasp/issues).

## Is ES6 supported?
Grasp uses [acorn](https://github.com/marijnh/acorn) to parse JavaScript. Acorn does not currently support ES6, but once it does Grasp will be updated to support it as well.

## Does Grasp do any scope analysis?
Not yet, but it's something I'm looking into for future versions!

## What languages does Grasp support?
Currently, the only language supported is JavaScript, however Grasp was written with the idea of supporting multiple languages in mind. The option `-l, --language` is reserved for this purpose.

In order for Grasp to support a language, that language needs to have a parser written in JavaScript, and that parser needs to produce location information which maps the produced AST nodes to their origin in the source.

Some languages which could be included in a future version of Grasp, depending on the availability of an appropriate parser, include:

* CoffeeScript
* [LiveScript](http://livescript.net)
* HTML
* etc.

## How can I set default options?
Simply alias `grasp` to include the options you want to use by default. For example:

    alias grasp='grasp --context 1 --equery'

sets the default output context to one line, and the default query engine to equery.

You can overwrite your defaults easily as well: simply include the option again with your new value - if an option is defined multiple times, its last definition is used. For instance, if you had used the above alias, you could change the context to `3` instead of `1` by simply doing `grasp --context 3 selector file.js`.

Remember that prepending a `--no-` to a boolean flag negates it. With the above alias, you could switch back to using the default squery engine by doing `grasp --no-equery selector file.js`. As a shortcut we've included the `-s, --squery` flag, which if given will always choose the squery engine - eg. `grasp -s selector file.js`.

## What is the license?
The code is [licensed under the MIT license](https://github.com/gkz/grasp/blob/master/LICENSE).

## What is the current version?
Version `{{ site.version }}`.

## I have a question not answered here, where can I ask it?
Join `#graspjs` on Freenode and ask `gkz` or post in the [GitHub issues section for Grasp](https://github.com/gkz/grasp/issues) with the title "question: &lt;your question here&gt;".
