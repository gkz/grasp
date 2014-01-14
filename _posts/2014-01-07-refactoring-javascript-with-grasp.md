---
layout: post
title: Refactoring your JavaScript code with Grasp
category: how-to
base_url: ../../../../..
---

There's more to programming than just writing code. While unlikely, it is possible to write imperfect code the first time through, or have requirements change over time. In these cases, you have to refactor the code you've already written to fix mistakes and change functionality.

You can go about refactoring your code in several ways; a small change can be done manually, but a larger change requires a tool to automate the task. Many programmers use regular expressions to modify their code - but are they the best choice? Programs such as `sed` that use regular expressions view your code as simply a blob of text - it's 2014, we can do better than that!

[Grasp]({{ page.base_url }}) is a command line utility that allows you to search and replace your JavaScript code, with one important distinctive feature: it searches the structure behind your code (the abstract syntax tree), rather than simply the text you've written. That means Grasp is smart! It knows the difference between an `if` statement and an identifier, and it knows what parts make up those nodes (eg. an `if` statement has a `test`, a `consequent`, and optionally an `alternative` - the `else`). It combines this with an easy to understand syntax for searching and replacing, making it an incredibly powerful tool for refactoring your JavaScript code.

<p class="note">
Install Grasp with <code>npm install -g grasp</code> (<a href="{{ page.base_url }}/docs/install">more info</a>)
</p>

In this guide we'll go over how to do some JavaScript refactoring tasks using Grasp:

- [Renaming an identifier](#renaming_an_identifier)
- [Multiple arguments to a single options object](#multiple_arguments_to_a_single_options_object)
- [Reducing the scope of your changes](#reducing_the_scope_of_your_changes)
- [Refactoring a function call](#refactoring_a_function_call)
- [To Yoda conditions, we change](#to_yoda_conditions_we_change)
- [Changing how you do default arguments](#changing_how_you_do_default_arguments)

First up, the simplest example:

### Renaming an identifier

This task is quite simple using Grasp! You have the following code:

{% highlight javascript %}
var remote = createConnection('remote', 'user', false);
remote.send(msg);
remote.on('receive', function (data) {
  if (data) {
    remote.send(process(data));
  } else {
    remote.end();
  }
});
{% endhighlight %}

and you've decided that `remote` is not a good name for variable you are using - you want to refactor your code and change `remote` to `remoteConnection`.

First you try using regular expressions, and do `sed 's/remote/remoteConnection/g' file.js`. At first that looks good, but then you look at the second line of your updated code:

{% highlight javascript %}
var remoteConnection = createConnection('remoteConnection', 'user', false);
{% endhighlight %}

Uh oh! The first argument to `createConnection` was changed from `'remote'` to `'remoteConnection'`, and your code is now broken! Because tools such as `sed` that use regular expressions see your code as simply text, they don't know the difference between changing `remote`, the identifier, and `remote`, the part of a string. You could create a more complex regular expression to do what you want, or you could use a program that is smart and knows all about the structure behind your JavaScript code: Grasp.

We can do this two ways in Grasp, first we can use the [squery]({{ page.base_url }}/docs/squery) query mode (which is the default) which uses a CSS style selector interface. To find all identifiers named `remote` we can use `ident[name=remote]`, or its shorthand: `#remote`.

First we can test to make sure we are finding what we want:

<pre class="term">
<span class="yellow">$</span> grasp '#remote' file.js
<span class="green">1</span><span class="cyan">:</span>var <span class="red bold">remote</span> = createConnection('remote', 'user', false);
<span class="green">2</span><span class="cyan">:</span><span class="red bold">remote</span>.send(msg);
<span class="green">3</span><span class="cyan">:</span><span class="red bold">remote</span>.on('receive', function (data) {
<span class="green">5</span><span class="cyan">:</span>    <span class="red bold">remote</span>.send(process(data));
<span class="green">7</span><span class="cyan">:</span>    <span class="red bold">remote</span>.end();
</pre>

Looks good! Now we can set a replacement using the `--replace` or `-R` options, and we get:

<pre class="term">
<span class="yellow">$</span> grasp '#remote' -R remoteConnection file.js
</pre>

<p class="note">
Windows users, you may need to use double quotes rather than single quotes to wrap your arguments, eg. <code>grasp "#remote" ...</code>
</p>

Let's look at our updated code:

{% highlight javascript %}
var remoteConnection = createConnection('remote', 'user', false);
remoteConnection.send(msg);
remoteConnection.on('receive', function (data) {
  if (data) {
    remoteConnection.send(process(data));
  } else {
    remoteConnection.end();
  }
});
{% endhighlight %}

Looks good! The identifiers are changed, but the string `'remote'` is left unchanged.

By default, doing a replacement on some code simply prints out the result. You can change your files in place using the `--in-place` or `-i` option, or if you want to do something more complex, you can look at the [to option]({{ page.base_url}}/docs/options/#to).

We can do the same replacement with the [equery]({{ page.base_url }}/docs/equery) query mode, which uses JavaScript code examples. We enabled it with the `--equery` or `-e` flag. Because we are looking for the identifier `remote`, all we need to do is type out an example of what we want: `remote`.

<pre class="term">
<span class="yellow">$</span> grasp -e remote -R remoteConnection file.js
</pre>

That was simple, but what if we want to do something a bit more complex?

### Multiple arguments to a single options object

You have the function `calc` in your code, but its signature is becoming a bit unwieldy as you've added functionality:

{% highlight javascript %}
function calc(user, target, action, amount, clear) {
  ...
}

var score = calc(getUserById(currentUserId, 'local'), getUserByName('grey-one', 'remote'), 'block', 100 + action.value, true);
{% endhighlight %}

It's becoming hard to remember the exact order of the parameters when you call the function, so you decide to refactor your code and make the function take in one argument, an object, with all the options specified by name:

{% highlight javascript %}
function calc(options) {
  var user = options.user,
      target = options.target,
      action = options.action,
      clear = options.clear;
  ...
}

var score = calc({
  user: getUserById(currentUserId, 'local'),
  target: getUserByName('grey-one', 'remote'),
  action: 'block',
  amount: 100 + action.value,
  clear: true
});
{% endhighlight %}

But how can you systematically change every single call to `calc` in your entire codebase to the new argument format?

Can we use regular expressions? No, because each call to `calc` we want to find and modify could have an arbitrarily complex expression for each argument. What we can do is use Grasp, it parses the JavaScript, queries its underlying structure, and lets us find and modify what we want.

Grasp has two query modes, squery with a CSS like syntax, and equery which uses JavaScript code patterns. The later is particularly adept for this task so we will enable it using the `--equery` or `-e` flag.

What will our pattern be? We type out an example of what we want, and use named wildcards (which start with a dollar sign `$`) to match any expression and save it to that name. Our pattern: `calc($user, $target, $action, $amount, $clear)`.

We can do a test search to make sure we're matching what we want with:

<pre class="term">
<span class="yellow">$</span> grasp -e 'calc($user, $target, $action, $amount, $clear)' file.js
</pre>

If we want to recursively search a directory, we can use the `--recursive` or `-r` flag:

<pre class="term">
<span class="yellow">$</span> grasp -r -e 'calc($user, $target, $action, $amount, $clear)' .
</pre>

{% raw %}
Now we can specify a replacement, which is done with the `--replace` or `-R` flag. Each of our matched nodes will be replaced with the text we provide. We can accessed the named portions of each match (which we specified using `$name`) with the `{{name}}` syntax.
{% endraw %}

{% raw %}
For our replacement we have: `calc({ user: {{user}}, target: {{target}}, action: {{action}}, amount: {{amount}}, clear: {{clear}} })`
{% endraw %}

For the sake of brevity, we can use shorter names for our named wildcards, and then we can put it all together:

{% raw %}
<pre class="term">
<span class="yellow">$</span> grasp -r -e 'calc($u, $t, $a, $n, $c)' -R 'calc({ user: {{u}}, target: {{t}}, action: {{a}}, amount: {{n}}, clear: {{c}} })' .
</pre>
{% endraw %}

And with that, all calls to `calc` - with whatever expressions you can think of as their arguments - are modified.

We changed

{% highlight javascript %}
var score = calc(getUserById(currentUserId, 'local'), getUserByName('grey-one', 'remote'), 'block', 100 + action.value, true);
{% endhighlight %}

to

{% highlight javascript %}
var score = calc({
  user: getUserById(currentUserId, 'local'),
  target: getUserByName('grey-one', 'remote'),
  action: 'block',
  amount: 100 + action.value,
  clear: true
});
{% endhighlight %}

automatically! Not only can we make very complex modifications, but we can can target them precisely:

### Reducing the scope of your changes

What if you want to change an identifier in a file, but don't want to change every single instance of that identifier in the entire file? How do you reduce the scope of the changes you want to make?

[Squery]({{ page.base_url }}/docs/squery) is modelled after CSS selectors. In CSS, if you want to only style certain elements that are children of another element, you use a space between the two selectors, eg.

{% highlight css %}
parent child {
  ...
}
{% endhighlight %}

You can do the same in squery. For instance, say you want to change the identifier `name` to `fullName`, but only in the function `getUserInfo`, you don't want to change the use of `name` outside of that function because it means something else.

{% highlight javascript %}
function getUserInfo(userId) {
  var user = getUserObject(userId);
  var name = user.first + ' ' + user.last;
  return {userName: name, userAge: dateDiff(Date.now(), user.birthday)};
}
function getInput(name) {
  return document.getElementsByName(name)[0];
}
{% endhighlight %}

First, we query for functions named `getUserInfo`, we can do that with `func[id=#getUserInfo]` - the `id` field of a function is an identifier, and remember that we can easily query identifiers using the `#identifierNname` syntax. Then, to select children of that function that are the identifier `name`, we can do `func[id=#getUserInfo] #name`.

Putting it all together, you can do:

<pre class="term">
<span class="yellow">$</span> grasp 'func[id=#getUserInfo] #name' -R fullName file.js
</pre>

and we get as our updated code:

{% highlight javascript %}
function getUserInfo(userId) {
  var user = getUserObject(userId);
  var fullName = user.first + ' ' + user.last;
  return {userName: fullName, userAge: dateDiff(Date.now(), user.birthday)};
}
function getInput(name) {
  return document.getElementsByName(name)[0];
}
{% endhighlight %}

Note that the identifier `name` in the function `getInput` remains unchanged, while `name` has been changed to `fullName` in the `getUserInfo` function!

### Refactoring a function call

You have the function `setValue`. Originally it had just two arguments, `key` and `value`, but the requirements were changed at the last minute (which never usually happens!) and you had to add a boolean option `silent`.

{% highlight javascript %}
function setValue(key, value, silent) {
  ...
}

setValue('height', 2, false);
setValue('speed', getSpeed(user, 'm/s'), true);
{% endhighlight %}

You're unhappy with it, and want to refactor the silent version into a new function.

{% highlight javascript %}
function setValue(key, value) {
  ...
}
function setValueSilently(key, value) {
  ...
}
{% endhighlight %}

But how can you replace every single call to `setValue` to the appropriate new function? You can easily do it with Grasp! You will do two passes, one for the silent version, and one for the non-silent version. You can use equery (`-e`, `--equery`) to do what you want - `setValue($k, $v, true)` will match calls when the silent argument is `true`, and `setValue($k, $v, false)` will match calls when the silent argument is `false`, and we can access `k` and `v` when creating our replacement.

<p class="note">
Remember that you can update your files in-place with the <code>--in-place</code> or <code>-i</code> option
</p>

First,

{% raw %}
<pre class="term">
<span class="yellow">$</span> grasp -e 'setValue($k, $v, true)' -R 'setValueSilently({{k}}, {{v}})' file.js
</pre>
{% endraw %}

and then,

{% raw %}
<pre class="term">
<span class="yellow">$</span> grasp -e 'setValue($k, $v, false)' -R 'setValue({{k}}, {{v}})' file.js
</pre>
{% endraw %}

Your calls to `setValue` have been changed!

{% highlight javascript %}
setValue('height', 2);
setValueSilently('speed', getSpeed(user, 'm/s'));
{% endhighlight %}

We've done a couple of reasonably complicated examples using equery, but what about with squery?

### To Yoda conditions, we change

You just heard about [Yoda conditions](http://en.wikipedia.org/wiki/Yoda_conditions) and you think they're pretty great because you're a big fan of green large-eared fictional beings. You want to refactor your current conditions to all be in Yoda style!

You want to find all `==` operators where the left hand side is an identifier, and switch it so the identifier is on the right hand side. For example, change:

{% highlight javascript %}
if (x == 2) {
  ...
}
{% endhighlight %}

to

{% highlight javascript %}
if (2 == x) {
  ...
}
{% endhighlight %}

First, we find all `==` binary ops with `biop[op="=="]`, then we limit that to where the left hand side is an identifier: `biop[op="=="][left=ident]`. We can test out the search:

<pre class="term">
<span class="yellow">$</span> grasp 'biop[op="=="][left=ident]' file.js
</pre>

{% raw %}
Now that we have that done, we can create the replacement. With squery, we can access parts of our match with the `{{ selector }}` syntax. Thus, we create our replacement, switching left and right: `{{.right}} {{.op}} {{.left}}`.
{% endraw %}

Putting it all together:

{% raw %}
<pre class="term">
<span class="yellow">$</span> grasp 'biop[op="=="][left=ident]' -R  '{{.right}} {{.op}} {{.left}}' file.js
</pre>
{% endraw %}

and we get the proper final result

{% highlight javascript %}
if (2 == x) {
  ...
}
{% endhighlight %}

<p class="note">
You could select <code>==</code> and <code>===</code> operators with <code>biop[op~=/===?/]</code>
</p>

Grasp the JavaScript, you must!

### Changing how you do default arguments

So far in your JavaScript coding career you've been using a popular pattern when you need default arguments in one of your functions:

{% highlight javascript %}
function addNumOrTwo(n, x) {
  x = x || 2;
  return n + x;
}
addNumOrTwo(3, 4); //=> 7
addNumOrTwo(3);    //=> 5
{% endhighlight %}

You've realized however that this isn't the best way to do things, because the default will be used if you use a valid input that happens to be falsey, such as `0`.

{% highlight javascript %}
addNumOrTwo(3, 0);    //=> 5, you want 3
{% endhighlight %}

You can do defaults the proper way with this pattern: `arg == null && (arg = default)` - this will only set the default if the arg is `undefined` or `null`. How can you systematically change all the instances in your code to the new pattern? We can use equery for this task (`--equery` or `-e`).

One cool trick we can use is that if we specify a named wildcard (eg. `$name`) more than once in a pattern, then the two instances must be the same. Thus we can find the old default pattern with `$arg = $arg || $default`. Then, we can add the replacement and put it all together:

{% raw %}
<pre class="term">
<span class="yellow">$</span> grasp -e '$arg = $arg || $default' -R '{{arg}} == null &amp;&amp; ({{arg}} = {{default}})' file.js
</pre>
{% endraw %}

Complicated changes are easy with Grasp!

### Conclusion

I hope you have learned a few of things and will consider using Grasp the next time you need to search, replace, or refactor your JavaScript code. Check out the [documentation]({{ page.base_url }}/docs/), [demo]({{ page.base_url}}#demo), and [home page]({{ page.base_url}}) for more information!
