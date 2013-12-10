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
      equal 3, (grasp.search 'squery', '#x', input .length)
      equal 2, (grasp.search 'squery', 'bi #x', input .length)

    test 'curried' ->
      equal 3, (grasp.search 'squery', '#x')(input).length
      equal 3, (grasp.search 'squery')('#x')(input).length

    test 'equery' ->
      equal 3, (grasp.search 'equery', 'x', input .length)

  suite 'replace' ->
    replaced = '''
               function square(y) {
                 return y * y;
               }
               '''

    test 'basic' ->
      equal (grasp.replace 'squery', '#x', 'y', input).0, replaced

    test 'curried' ->
      equal (grasp.replace 'squery', '#x', 'y')(input).0, replaced
      equal (grasp.replace 'squery', '#x')('y')(input).0, replaced
      equal (grasp.replace 'squery')('#x')('y')(input).0, replaced

    test 'full squery' ->
      equal (grasp.replace 'grasp-squery', '#x', 'y', input).0, replaced

    test 'equery' ->
      equal (grasp.replace 'equery' 'x', 'y', input).0, replaced
