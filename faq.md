---
layout: default
title: FAQ
permalink: /faq/
base_url: ..
---

## What does the name mean?
"grasp" could stand for (depending on your mood) Great/Good/Goddamn/Green Replace And Search Program.

The word "grasp", when used as a verb can mean:

> get mental hold of; comprehend fully

This seems apt for a program which lets you search using the more meaningful structure behind your code, rather than simply its textual representation.

## I found a bug, where can I report it?
The [GitHub issues section for grasp](https://github.com/gkz/grasp/issues).

## What languages does grasp support?
Currently, the only language supported is JavaScript, however grasp was written with the idea of supporting multiple languages in mind. The option `-l, --language` is reserved for this purpose.

In order for grasp to support a language, that language needs to have a parser written in JavaScript, and that parser needs to produce location information which maps the produced AST nodes to their origin in the source.

Some languages which could be included in a future version of grasp, depending on the availability of an appropriate parser, include:

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
Post in the [GitHub issues section for grasp](https://github.com/gkz/grasp/issues) with the title "question: &lt;your question here&gt;".
