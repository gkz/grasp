{eq} = require './_helpers'

suite 'exclude' ->
  base-dir = process.cwd!

  teardown ->
    process.chdir base-dir

  test 'without exclude' ->
    eq '--recursive "#x" test/data', [
      'test/data/a.js:1:function square(##x#) {'
      'test/data/a.js:2:  return ##x# * x;'
      'test/data/a.js:2:  return x * ##x#;'
      * func-type: 'error', value: /Error: Could not parse JavaScript from/
      'test/data/dir/c.js:2:var ##x# = z -'
    ], it

  test 'exclude **/a.js' ->
    eq '--exclude "**/a.js" --recursive "#x" test/data', [
      * func-type: 'error', value: /Error: Could not parse JavaScript from/
      'test/data/dir/c.js:2:var ##x# = z -'
    ], it

  test 'exclude negated pattern' ->
    eq '--exclude "!**/a.js" --recursive "#x" test/data', [
      'test/data/a.js:1:function square(##x#) {'
      'test/data/a.js:2:  return ##x# * x;'
      'test/data/a.js:2:  return x * ##x#;'
    ], it

  test 'custom minimatch props' ->
    eq '--minimatch-options={nocase:true} --exclude "!**/A.js" --recursive "#x" test/data', [
      'test/data/a.js:1:function square(##x#) {'
      'test/data/a.js:2:  return ##x# * x;'
      'test/data/a.js:2:  return x * ##x#;'
    ], it
