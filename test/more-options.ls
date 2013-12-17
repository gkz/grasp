{eq} = require './_helpers'

suite 'more options' ->
  test 'version' ->
    eq '--version', 'grasp v0.2.0', it

  test 'version no callback' ->
    eq '--version', 'grasp v0.2.0', it, {-callback}

  test 'file (selector)' ->
    eq '--file test/data/selector test/data/t.js', [
      '6:  ##z++#;'
      '9:    b: ##2#,'
    ], it

  test 'file (selector) error' ->
    eq '--file test/data/FAKE test/data/t.js', [
      {func-type: 'error', value: "Error: No such file 'test/data/FAKE'."}
    ], it

  test 'max-count' ->
    eq '--max-count 2 "#x" test/data/t.js', ['1:function square(##x#) {', '2:  return ##x# * x;'], it

  test 'debug' ->
    eq '--debug bi test/data/t.js', [
      * func-type: 'time', value: 'everything'
      * func-type: 'log', value: 'options:'
      * func-type: 'log', value: /"debug":true/
      * func-type: 'time', value: 'parse-selector'
      * func-type: 'time-end', value: 'parse-selector'
      * func-type: 'log', value: 'parsed-selector:'
      * func-type: 'log', value: /"value":"BinaryExpression"/
      * func-type: 'time', value: 'search-total:test/data/t.js'
      * func-type: 'time', value: 'parse-input:test/data/t.js'
      * func-type: 'time-end', value: 'parse-input:test/data/t.js'
      * func-type: 'time', value: 'query:test/data/t.js'
      * func-type: 'time-end', value: 'query:test/data/t.js'
      * '2:  return ##x * x#;'
      * func-type: 'time-end', value: 'search-total:test/data/t.js'
      * func-type: 'time-end', value: 'everything'
    ], it

  test 'quiet' ->
    eq '--quiet return test/data/t.js', '2:  ##return x * x;#', it, {+quiet}

  test 'equery' ->
    eq '--equery "__ * __" test/data/t.js', '2:  return ##x * x#;', it

  test 'equery' ->
    eq '--equery --squery "[op=*]" test/data/t.js', '2:  return ##x * x#;', it

  test 'engine' ->
    eq "--engine ../node_modules/grasp-squery \"update[op='++']\" test/data/t.js", '6:  ##z++#;', it

  test 'parser with path and options' ->
    eq '--parser "../node_modules/acorn, {locations: true}" prop test/data/t.js', [
      '8:    ##a: 1#,'
      '9:    ##b: 2#,'
      '10:    ##c: 3#'
    ], it
