{eq} = require './_helpers'

suite 'line-number and col-number' ->
  test 'no line-number and no col-number' ->
    eq '--no-line-number return test/data/t.js', '  ##return x * x;#', it

  test 'line-number and col-number' ->
    eq '--col-number return test/data/t.js', '2,2-2,14:  ##return x * x;#', it

  test 'col-number without line-number' ->
    eq '--col-number --no-line-number return test/data/t.js', '2-14:  ##return x * x;#', it

  test 'line-number without col-number' ->
    eq 'return test/data/t.js', '2:  ##return x * x;#', it

  test 'multiline no line-number and no col-number' ->
    eq '--no-line-number func-dec test/data/t.js', '''
      (multiline):
      ##function square(x) {#
      ##  return x * x;#
      ##}#''', it

  test 'multiline col-number without line-number' ->
    eq '--col-number --no-line-number func-dec test/data/t.js', '''
      0-0:(multiline):
      ##function square(x) {#
      ##  return x * x;#
      ##}#''', it
