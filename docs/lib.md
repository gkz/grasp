---
layout: doc-page
title: Using as a Library
permalink: /docs/lib/
base_url: ../..
---

Grasp is actually a library. The Grasp executable uses the Grasp library as such:

{% highlight javascript %}
grasp({
  args: process.argv,
  exit: process.exit,
  stdin: process.stdin,
  callback: console.log,
  error: console.error
});
{% endhighlight %}

You can also use Grasp as a library. First, add Grasp to your `package.json`:

{% highlight javascript %}
  "dependencies": {
    "grasp": "~{{ site.version }}",
    ...
  }
{% endhighlight %}


and then require Grasp:

{% highlight javascript %}
var grasp = require('grasp');
{% endhighlight %}

You get the function `grasp`, which is called with an object. The options are:

* `args`: The arguments as either an array of strings (the first two items sliced away), an object, or a string. Required.
* `error`: A function called with a string error message when there is an error halting the program.
* `callback`: A function called whenever there is output ready, with that output.
* `exit`: A function called when Grasp has done running. It is called with two arguments, the first is an exit code (`0` - all ok, `1` - no results, `2` - error), and potentially a final value.
* `stdin`: The stdin object - must have the same interface as `process.stdin`. Required if you want to use stdin.
* `fs`: The file system object - must have the same interface as `require('fs')`. Defaults to `require('fs')`.
* `textFormat`: Text format functions object - must specify `green`, `cyan`, `magenta`, `red`, and `bold` functions ala [cli-color](https://github.com/medikoo/cli-color) (which is the default if nothing is specified).
* `console`: An object with `log`, `warn`, `error`, `time`, and `timeEnd` functions. Must have the same interface as `console`, which is the default.
* `input`: A string with the input which to search or replace. Use this instead of specifying `stdin` or `fs` if more convenient.

You can also use two helper functions. They are accessible as properties of `grasp`: `grasp.search` and `grasp.replace`.

`search` takes a string choosing a query engine (`squery` or `equery`), a string selector, and a string input, and produces an array of nodes. Eg.

{% highlight javascript %}
var nodes = grasp.search('squery', 'if', code);
{% endhighlight %}

`replace` takes a string choosing a query engine (`squery` or `equery`), a string selector, a string replacement, and a string input, and produces a string of the processed code. Eg.

{% highlight javascript %}
var processedCode = grasp.replace('squery', 'if.test', '!({% raw %}{{}}{% endraw %})', code);
{% endhighlight %}

Both are curried functions, which means if you call them with less than their required arguments, they will return a partially applied function. For example, you could do:

{% highlight javascript %}
var equerySearch = grasp.search('equery');
var nodes = equerySearch('__ + __', code);
{% endhighlight %}

or

{% highlight javascript %}
var replacer = grasp.replace('equery', '__ + __', '{% raw %}{{.l}} - {{.r}}{% endraw %}');
var processedCode = replacer(code);
{% endhighlight %}
