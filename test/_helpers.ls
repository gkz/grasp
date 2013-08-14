grasp = require '..'
require! {
  clc: 'cli-color'
}
{strict-equal: equal, deep-equal, throws}:assert = require 'assert'
{keys, reject, map, lines} = require 'prelude-ls'
{EventEmitter} = require 'events'

class StdIn extends EventEmitter
  (@data) ~>
    @current-line = 0
    @data-len = @data?.length

  emit-data: ~>
    @emit 'data', @data[@current-line]
    @current-line++
    if @current-line is @data-len
      clear-interval @interval
      @emit 'end'
  resume: -> @interval = set-interval @emit-data, 5
  set-encoding: ->

class FileSystem
  (@tree) ->

  read-file-sync: (path) ->
    node = @tree[path]
    if node.type is 'directory'
      throw new Error "#path is directory"
    else
      node.contents

  read-dir-sync: (path) ->
    node = @tree[path]
    if node.type is 'file'
      throw new Error "#path is file"
    else
      keys node

  lstat-sync: (path) ->
    node = @tree[path]

    is-directory: -> node.type is 'directory'
    is-file: -> node.type is 'file'


q = (args, opts = {}) ->
  opts <<< {args}
  grasp opts

test-func = (type, o, quiet) ->
  (result) !->
    throw new Error 'Unexpected result - quiet is on.' if quiet
    try
      expected-val = o.expected[o.i]
      until o.callback or typeof! expected-val is 'Object'
        ++o.i
        expected-val = o.expected[o.i]

      if type is 'callback'
        expected-real-val = expected-val
      else
        unless expected-val?.func-type
          throw new Error "Expected callback, but got #type instead, with result: #result."
        equal type, expected-val?.func-type
        expected-real-val = expected-val?.value
      switch typeof! expected-real-val
      | 'RegExp' =>
        assert (expected-real-val.test if typeof! result is 'String' then result else JSON.stringify result), 'RegExp did not pass'
      | otherwise =>
        deep-equal result, expected-real-val
      ++o.i
    catch
      console.log o.expected
      console.log o.i
      console.log "\n#type"
      console.log '---'
      console.log result
      console.log expected-real-val
      console.log '---'
      console.log JSON.stringify result
      console.log JSON.stringify expected-real-val
      throw e

embolden = ->
  if typeof! it is 'String'
    it.replace /##/g '\u001b[1m' .replace /#/g '\u001b[22m'
  else
    it

eq = (arg-string, expected, done, {quiet, data, color, callback = true, stdin, fs, dir, final} = {}) !->
  process.chdir dir if dir
  expected-formatted = map embolden, [].concat expected
  args = if not arg-string? then null else if color then arg-string else "--no-color #arg-string"
  expected-len = expected-formatted.length

  o =
    i: 0
    expected: expected-formatted
    callback: callback

  options =
    console:
      log: test-func 'log', o
      warn: test-func 'warn', o
      error: test-func 'error', o
      time: test-func 'time', o
      time-end: test-func 'time-end', o
    callback: if callback then test-func 'callback', o, quiet else null
    error: test-func 'error', o
    stdin: stdin
    fs: fs
    data: data
    exit: (exit-code, results) ->
      res = [].concat results
      j = 0
      try
        if final
          final results
        else
          for exp in expected-formatted
            continue if exp.func-type?
            switch typeof! exp
            | 'RegExp' =>
              assert (exp.test res[j]), 'RegExp did not pass'
            | otherwise =>
              deep-equal exp, res[j]
            j++
      catch
        console.log '\n'
        console.log 'ERROR with final value compare'
        console.log res
        console.log expected-formatted
        console.log JSON.stringify res
        console.log JSON.stringify expected-formatted
        throw e
      done!

  unless options.callback?
    o.callback = false
  q args, options

module.exports = {grasp, eq, q, StdIn, FileSystem}
