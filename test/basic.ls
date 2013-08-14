{eq} = require './_helpers'

suite 'basic' ->
  test 'single line' ->
    eq '"#square" test/data/t.js', '1:function ##square#(x) {', it

  test 'no callback' ->
    eq '"#square" test/data/t.js', '1:function ##square#(x) {', it, {-callback}

  test 'single line - 2' ->
    eq '"#x" test/data/t.js', ['1:function square(##x#) {', '2:  return ##x# * x;', '2:  return x * ##x#;'], it

  test 'single line - 3' ->
    eq 'return test/data/t.js', '2:  ##return x * x;#', it

  test 'multiline func' ->
    eq 'func-dec test/data/t.js', '''
      1-3:(multiline):
      ##function square(x) {#
      ##  return x * x;#
      ##}#''', it

  test 'multiline obj' ->
    eq 'obj test/data/t.js', '''
      7-11:(multiline):
        var obj = ##{#
      ##    a: 1,#
      ##    b: 2,#
      ##    c: 3#
      ##  }#;''', it

  test 'multiple files' ->
    eq 'return test/data/t.js test/data/tt.js', [
      'test/data/t.js:2:  ##return x * x;#'
      'test/data/tt.js:4:    ##return zz + zz;#'
    ], it
