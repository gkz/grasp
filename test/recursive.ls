{eq} = require './_helpers'

suite 'recursive' ->
  base-dir = process.cwd!

  teardown ->
    process.chdir base-dir

  test 'basic' ->
    eq '--recursive "#x" test/data', [
      'test/data/a.js:1:function square(##x#) {'
      'test/data/a.js:2:  return ##x# * x;'
      'test/data/a.js:2:  return x * ##x#;'
      * func-type: 'error', value: /Error: Could not parse JavaScript from/
      'test/data/dir/c.js:2:var ##x# = z -'
    ], it

  results = [
    'a.js:1:function square(##x#) {'
    'a.js:2:  return ##x# * x;'
    'a.js:2:  return x * ##x#;'
    * func-type: 'error', value: /Error: Could not parse JavaScript from/
    'dir/c.js:2:var ##x# = z -'
  ]

  test 'on .' ->
    eq '--recursive "#x" .', results, it, {dir: 'test/data/'}

  test 'no target specified, default to .' ->
    eq '--recursive "#x"', results, it, {dir: 'test/data/'}

  results2 = [
    * func-type: 'error', value: /Error: Could not parse JavaScript from/
    * func-type: 'error', value: /Error: Could not parse JavaScript from/
    'test/data/replacement:1:console.##log#(\'debug\');'
  ]

  test 'no extension' ->
    eq '--extensions "." --recursive "#log" test/data', results2, it
