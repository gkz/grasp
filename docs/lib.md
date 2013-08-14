---
layout: doc-page
title: Using as a Library
permalink: /lib/
---

Grasp is actually a library. The grasp executable uses the grasp library as such:

{% highlight javascript %}
grasp({
  args: process.argv,
  exit: process.exit,
  stdin: process.stdin,
  callback: console.log,
  error: console.error
});
{% endhighlight %}

You can also use grasp as a library. First, add grasp to your `package.json`:

{% highlight javascript %}
  "dependencies": {
    "grasp": "~{{ site.version }}",
    ...
  }
{% endhighlight %}


and then require grasp:

{% highlight javascript %}
var grasp = require('grasp');
{% endhighlight %}

You get the function `grasp`, which is called with an object. The options are:

* `args`: The arguments as either an array of strings (the first two items sliced away), an object, or a string. Required.
* `error`: A function called with a string error message when there is an error halting the program.
* `callback`: A function called whenever there is output ready, with that output.
* `exit`: A function called when grasp has done running. It is called with two arguments, the first is an exit code (`0` - all ok, `1` - no results, `2` - error), and potentially a final value.
* `stdin`: The stdin object - must have the same interface as `process.stdin`. Required if you want to use stdin.
* `fs`: The file system object - must have the same interface as `require('fs')`. Defaults to `require('fs')`.
* `console`: An object with `log`, `warn`, `error`, `time`, and `timeEnd` functions. Must have the same interface as `console`. Defaults to `console`.
