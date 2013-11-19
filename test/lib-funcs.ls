{grasp} = require './_helpers'
{strict-equal: equal} = require 'assert'

suite 'lib functions' ->
  input = '''
          function square(x) {
            return x * x;
          }
          '''

  suite 'search' ->
    test 'basic' ->
      equal 3, (grasp.search '#x', input .length)
      equal 2, (grasp.search 'bi #x', input .length)

    test 'curried' ->
      equal 3, (grasp.search '#x')(input).length

  suite 'replace' ->
    replaced = '''
               function square(y) {
                 return y * y;
               }
               '''

    test 'basic' ->
      equal (grasp.replace '#x', 'y', input).0, replaced

    test 'curried' ->
      equal (grasp.replace '#x', 'y')(input).0, replaced
      equal (grasp.replace '#x')('y')(input).0, replaced

