---
layout: post
title: Grasp 0.1.0 released!
category: release
base_url: ../../../../..
---

The first version of Grasp, 0.1.0, has been released!

Grasp is a command line utility that allows you to search and replace your JavaScript code - but unlike programs like `grep` or `sed`, it searches for the structure behind your code (the abstract syntax) rather than simply its textual representation. We call this structural search and replace, and it allows for much more powerful search and replace.

Install with `npm install -g grasp`.

Check out the [main site]({{ page.base_url }}), the [demo]({{ page.base_url }}#demo), the [quick start guide]({{ page.base_url }}/quick-start), and the [documentation]({{ page.base_url }}/docs)!

### Completeness

Grasp is quiet feature rich for its first release. The command line portion is the most complete - it already has many possibly desired options available. Squery is next - a lot of the syntax will probably stay the same, though user feedback may change some aspects. Equery is least complete - it may undergo major changes in the future depending on user feedback.

### Speed

I haven't done any profiling/optimization of Grasp yet, due to the fact that I ran into my self imposed deadline for releasing the first version, and that it runs in a reasonable time already for most purposes. In the upcoming releases, I focus on optimization to improve the experience on larger code bases.
