{eq} = require './_helpers'
path = require 'path'

suite 'filename' ->
  test 'single file - with filename' ->
    eq '--filename return test/data/t.js', 'test/data/t.js:2:  ##return x * x;#', it

  test 'single file - without filename' ->
    eq 'return test/data/t.js', '2:  ##return x * x;#', it

  test 'multiple files - with filename' ->
    eq 'return test/data/t.js test/data/tt.js', [
      'test/data/t.js:2:  ##return x * x;#'
      'test/data/tt.js:4:    ##return zz + zz;#'
    ], it

  test 'multiple files - without filename' ->
    eq '--no-filename return test/data/t.js test/data/tt.js', [
      '2:  ##return x * x;#'
      '4:    ##return zz + zz;#'
    ], it

  test 'absolute file paths' ->
    eq "--filename return #{process.cwd!}/test/data/t.js", "test/data/t.js:2:  #\#return x * x;#", it
