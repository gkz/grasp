{eq} = require './_helpers'

suite 'es6plus' ->
  test 'single line' ->
    eq '"func.body #a" test/data/es6plus.js', '24:    this.n += ##a#;', it
