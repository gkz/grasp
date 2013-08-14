{eq} = require './_helpers'

suite 'context' ->
  test 'context' ->
    eq '--context 1 return test/data/t.js', '''
      2:(multiline):
      function square(x) {
        ##return x * x;#
      }''', it

  test 'before context' ->
    eq '--before-context 1 return test/data/t.js', '''
      2:(multiline):
      function square(x) {
        ##return x * x;#''', it

  test 'after context' ->
    eq '--after-context 1 return test/data/t.js', '''
      2:(multiline):
        ##return x * x;#
      }''', it

  test 'context shorthand' ->
    eq '-1 return test/data/t.js', '''
      2:(multiline):
      function square(x) {
        ##return x * x;#
      }''', it
