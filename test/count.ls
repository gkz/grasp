{eq} = require './_helpers'

suite 'count' ->
  test 'single file - no filename' ->
    eq '--count "#x" test/data/t.js', '3', it

  test 'single file - with filename' ->
    eq '--count --filename "#x" test/data/t.js', 'test/data/t.js:3', it

  test 'multiple files - no filename' ->
    eq '--count --no-filename "#/^z/" test/data/t.js test/data/tt.js', [
      '3'
      '2'
    ], it

  test 'multiple files - with filename' ->
    eq '--count "#/^z/" test/data/t.js test/data/tt.js', [
      'test/data/t.js:3'
      'test/data/tt.js:2'
    ], it
