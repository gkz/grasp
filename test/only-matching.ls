{eq} = require './_helpers'

suite 'only-matching' ->
  test 'basic' ->
    eq '--only-matching "#square" test/data/t.js', '1:##square#', it

  test 'multiline' ->
    eq '--only-matching "func-dec block" test/data/t.js', '''
      1-3:(multiline):
      ##{#
      ##  return x * x;#
      ##}#''', it

  test 'multiline turned into single line' ->
    eq '--only-matching -1 return test/data/t.js', '2:##return x * x;#', it
