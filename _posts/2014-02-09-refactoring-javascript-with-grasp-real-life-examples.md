---
layout: post
title: Refactoring JavaScript with Grasp - a real life example
base_url: ../../../../..
---

Islam Sharabash recently read my blog post about how to [refactor his JavaScript code with Grasp]({{ page.base_url }}/blog/2014/01/07/refactoring-javascript-with-grasp), a command line utility like `grep` or `sed` that allows him to search and replace his JavaScript code based on its structure, rather than simply its text. Using the tool, he wanted to refactor some code to change `x.y.last()` to `last(x.y)`, for a [pull request he was making](https://github.com/aredridel/html5/pull/103) on [aredridel/html5](https://github.com/aredridel/html5).

<p class="note">
Install Grasp with <code>npm install -g grasp</code> (<a href="{{ page.base_url }}/docs/install">more info</a>)
</p>

Previously, the project had added a `last` property to the Array prototype, which when called returned the last item of the array. Modifying the prototype of a native object is a bad idea however, as it can create conflicts with other libraries. Thus, any use of `last` as a property had to be turned into a function call to `last`.

This:

{% highlight javascript %}
parser.js:2395:                       if (tree.open_elements.last() != node) {
parser.js:2650:               var currentNode = this.tree.open_elements.last() || null;
...
tokenizer.js:236:			current_token.data.last().nodeValue += entity;
tokenizer.js:903:        if (attributes.last().nodeName == attributes[k].nodeName) {
...
treebuilder.js:118: this.open_elements.last().appendChild(element);
treebuilder.js:281:   if(element == this.activeFormattingElements.last()) break;
{% endhighlight %}

had to be changed to this:

{% highlight javascript %}
parser.js:2395:                       if (last(tree.open_elements) != node) {
parser.js:2650:               var currentNode = last(this.tree.open_elements) || null;
...
tokenizer.js:236:			last(current_token.data).nodeValue += entity;
tokenizer.js:903:        if (last(attributes).nodeName == attributes[k].nodeName) {
...
treebuilder.js:281:   if(element == last(this.activeFormattingElements)) break;
treebuilder.js:118: last(this.open_elements).appendChild(element);
{% endhighlight %}

**How could this be accomplished automatically with Grasp?**

Steps:
1. Find a way to search and find every node we want to change
2. Create a replacement pattern that replaces each match with what we want

### Matching the nodes we want to replace

Let's use the [Equery]({{ page.base_url }}/docs/equery) selector engine for our purposes, with the `--equery` or `-e` flags. With it, we simply need to type out an example of the JavaScript we want to match.

Starting off with the very basics, how can we match the identifier `last`? Well, with simply:

`grasp -e 'last' file.js`

That's a start, but what we want to do is not just match `last`, but the entire call: eg. `tree.open_elements.last()`.

What happens when we do:

`grasp -e 'last()' file.js`

That doesn't seem to match anything! Why is that?

Textually, `last()` does match the last portion of `open_elements.last()`, but Grasp doesn't look at code textually, it looks at its underlying structure. What is the structure of `open_elements.last()`? The entire thing is a call. Calls have a `callee`, the thing that we are calling, and a list of `arguments` (in this case, none). The callee in this case may seem to be `last`, but in fact it is `open_elements.last`. Think of `open_elements.last()` as `(open_elements.last)()` and
things may make more sense. Here is what it looks like when it is parsed:

{% highlight javascript %}
{
  "type": "CallExpression",
  "callee": {
    "type": "MemberExpression",
    "object": {
      "type": "Identifier",
      "name": "open_elements"
    },
    "property": {
      "type": "Identifier",
      "name": "last"
    },
    "computed": false
  },
  "arguments": []
}
{% endhighlight %}

Thus, if we want to match the structure we can do `__.last()`, `__` being a wildcard which will match anything.

The entire command: `grasp -e '__.last()' file.js`

So a match has been made, but what do we replace it with?

### Replacement

{% raw %}
We don't want to just find nodes, we want to make an appropriate replacement. In this case, we want to replace `*anything*.last()` with `last(*anything*)`. We can match "anything", and save it for use in the replacement, with `$name`, where `name` is whatever we want. We can then access it in the replacement pattern with `{{name}}`.{% endraw %} You can read more about replacement in the [documentation]({{ page.base_url }}/docs/replace).

{% raw %}
Thus, we use `$x.last()` to match the nodes we want, and replace them with `last({{x}})`. The `--replace` or `-R` option is used to specify the replacement text.
{% endraw %}

{% raw %}
The entire command: `grasp -e '$x.last()' -R 'last({{x}})' file.js`
{% endraw %}

<p class="note">
By default, the output is simply printed out - to overwrite the input files with the replacement, use <code>--in-place</code> or <code>-i</code>
</p>

### Success!

Armed with his new knowledge on Grasp, Mr. Sharabash was able to successfully refactor the code with ease. He sent in a pull request, and it was accepted!

<p class="note">
This blog post was based off of a GitHub <a href="https://github.com/gkz/grasp/issues/18">issue</a> and <a href="https://github.com/aredridel/html5/pull/103">pull request</a>
</p>
