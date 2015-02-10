{grasp} = require './_helpers'
{strict-equal: equal} = require 'assert'

suite 'lib functions' ->
  input = '''
          function square(x) {
            return x * x;
          }
          '''
  test 'version' ->
    equal grasp.VERSION, (require '../package.json' .version)

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
      equal (grasp.replace 'squery', '#x', 'y', input), replaced

    test 'replace with nothing' ->
      replaced = '''
                 function square(x) {
                   return ;
                 }
                 '''
      equal (grasp.replace 'squery', 'func', '', input), ''
      equal (grasp.replace 'squery', 'return.arg', '', input), replaced

    test 'curried' ->
      equal (grasp.replace 'squery', '#x', 'y')(input), replaced
      equal (grasp.replace 'squery', '#x')('y')(input), replaced
      equal (grasp.replace 'squery')('#x')('y')(input), replaced

    test 'full squery' ->
      equal (grasp.replace 'grasp-squery', '#x', 'y', input), replaced

    test 'equery' ->
      equal (grasp.replace 'equery' 'x', 'y', input), replaced

    test 'with replace function' ->
      equal (grasp.replace 'squery' 'func', (get-raw, node, query) ->
        x = get-raw (query '.params' .0)
        """
        function #{ node.id.name }AddZ(#{ query '.params' .map get-raw .concat ['z'] .join ', ' }) {
          return #x * #x + z;
        }
        """
      , input), """
                  function squareAddZ(x, z) {
                    return x * x + z;
                  }
                  """

    test 'with replace function (equery)' ->
      equal (grasp.replace 'equery', 'return $x * $x;', (get-raw, node, query, named) ->
        X = (get-raw named.x).to-upper-case!
        "return #X * #X;"
      , input), """
                  function square(x) {
                    return X * X;
                  }
                  """
