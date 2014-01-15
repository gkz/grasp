{eq} = require './_helpers'

suite 'recursive' ->
  base-dir = process.cwd!

  teardown ->
    process.chdir base-dir

  test 'basic' ->
    eq '--recursive "#x" test/data', [
      * func-type: 'error', value: /Error: Could not parse JavaScript from/
      'test/data/dir/ttt.js:2:var ##x# = z -'
      'test/data/t.js:1:function square(##x#) {'
      'test/data/t.js:2:  return ##x# * x;'
      'test/data/t.js:2:  return x * ##x#;'
    ], it

  results = [
    * func-type: 'error', value: /Error: Could not parse JavaScript from/
    'dir/ttt.js:2:var ##x# = z -'
    't.js:1:function square(##x#) {'
    't.js:2:  return ##x# * x;'
    't.js:2:  return x * ##x#;'
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
