---
layout: doc-page
title: Using as a Library
permalink: /docs/lib/
base_url: ../..
---

Grasp is actually a library. You can skip to its <a href="#helper-functions">helper functions</a>, or you can read about the full power `grasp` function below.

The Grasp executable uses the Grasp library as such:

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

### Helper Functions

You can also use two helper functions. They are accessible as properties of `grasp`: `grasp.search` and `grasp.replace`.

Both are curried functions, which means if you call them with less than their required arguments, they will return a partially applied function. For example, you could do:

{% highlight javascript %}
var grasp = require('grasp');
var equerySearch = grasp.search('equery');
var nodes = equerySearch('__ + __', code);
{% endhighlight %}

or

{% highlight javascript %}
var grasp = require('grasp');
var replacer = grasp.replace('equery', '__ + __', '{% raw %}{{.l}} - {{.r}}{% endraw %}');
var processedCode = replacer(code);
{% endhighlight %}

#### Search

`search` takes a string choosing a query engine (`squery` or `equery`), a string selector, and a string input, and produces an array of nodes. Eg.

{% highlight javascript %}
var grasp = require('grasp');
var nodes = grasp.search('squery', 'if', code);
{% endhighlight %}

#### Replace

`replace` takes a string choosing a query engine (`squery` or `equery`), a string selector, a string replacement, and a string input, and produces a string of the processed code. Eg.

{% highlight javascript %}
var grasp = require('grasp');
var processedCode = grasp.replace('squery', 'if.test', '!({% raw %}{{}}{% endraw %})', code);
{% endhighlight %}

Instead of providing a replacement pattern as a string, you can pass in a function which produces a string, and this string will be used as the replacement.

The function signature:

`(getRaw::(Node -> String), node::Node, query::(String -> [Node]), named::Object) -> String`

The function has 4 optional parameters:

- `getRaw`: a function which takes a node object and produces a string
- `node`: the node that was matched (and is being replaced)
- `query`: a function which queries using the same query engine as the original search, and using the matched node as the root
- `named`: an object containing any named matches

You can call any code that you want, but you must return a string, and this string will be used as the replacement for the matched node.

An example:

{% highlight javascript %}
var processedCode = grasp.replace('squery', 'call[callee=#require]', function(getRaw, node, query) {
    var req = query(".args")[0];
    return "import " + camelize(path.basename(req.value, ".js")) + " from " + getRaw(req);
}, code);
{% endhighlight %}
