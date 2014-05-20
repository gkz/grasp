{eq} = require './_helpers'

suite 'count' ->
  test 'single file - no filename' ->
    eq '--count "#x" test/data/a.js', '3', it

  test 'single file - with filename' ->
    eq '--count --filename "#x" test/data/a.js', 'test/data/a.js:3', it

  test 'multiple files - no filename' ->
    eq '--count --no-filename "#/^z/" test/data/a.js test/data/b.js', [
      '3'
      '2'
    ], it

  test 'multiple files - with filename' ->
    eq '--count "#/^z/" test/data/a.js test/data/b.js', [
      'test/data/a.js:3'
      'test/data/b.js:2'
    ], it
