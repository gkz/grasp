---
layout: doc-page
title: Concepts
permalink: /concepts/
---

### Textual versus structural

Most code search and replace programs are based on matching the textual representation of your code against some sort of pattern (a regular expression for instance). Grasp is different, rather than just looking at your code as if it were a string of characters, it looks at the underlying structure that text represents.

What is this structure? Where does it come from? Compilers, interpreters, and other tools which use your code need some sort of useful representation of it. Simply looking at it as a blob of text isn't very useful. That is why they take your code and turn it into an abstract syntax tree.

This tree represents the syntactic structure of your code without details irrelevant to the meaning of the code - for instance if you put your braces on their own line or not. Each node represents a construct occurring in your source code. Thus a parser transforms your code from a blob of text into a tree of objects with attributes.

The following two pieces of code have the same representation in the abstract syntax tree:

{% highlight javascript %}
if (x < 2) {
  f(x);
}
{% endhighlight %}

and

{% highlight javascript %}
if (x < 2) { f(x); }
{% endhighlight %}

Textually, they are different, but their underlying syntactic structure is the same. They are both if statements. Both of their `test` attributes are `x < 2`. Their `consequent` attributes are both blocks with one line, `f(x);`.

For more details about how JavaScript code is transformed into a abstract syntax tree, take a look at our [JavaScript syntax page](../syntax-js).

### How grasp uses the abtract syntax tree

Grasp parses your code into such a tree, and then uses special patterns you supply to search the code.

Why is this more powerful than text based search?

Let's take a simple example - you want to search and find where the variable `error` is used in your code:

    var error = new Error("There was an error attempting to parse the input.");

First, let's attempt to accomplish that with `grep`:

<pre><code>$ grep error file.js
1:var <span class="bold red">error</span> = new Error("There was an <span class="bold red">error</span> attempting to parse the input.");
</code></pre>

Well, it found the variable we were looking for, but it also matched `error` in our error message string. That's unfortunate.

We could complicate our search pattern and try to exclude text found in quotes, or we could just use a program that understands the structure of our code instead. We tell grasp to look for identifiers, whose name is "error":

<pre><code>$ grasp 'ident[name=error]' file.js
1:var <span class="bold red">error</span> = new Error("There was an error attempting to parse the input.");
</code></pre>

Yay! It matched only what we were looking for. Searching for identifiers is a common enough that there is a nice shorthand:

<pre><code>$ grasp '#error' file.js
1:var <span class="bold red">error</span> = new Error("There was an error attempting to parse the input.");
</code></pre>

### Different types of patterns

Grasp comes with two different "query engines" which allow for two different types of patterns:

The default is [squery](../squery) - or "selector query" - which uses CSS style selectors. Just as you can use CSS selectors to query the DOM, you can use squery to query the abstract syntax tree of your program.

The other is [equery](../equery) - or "example query" - which allows you to use JavaScript code examples with wildcards and more.
