{eq, q, StdIn, FileSystem} = require './_helpers'
{strict-equal: equal}:assert = require 'assert'

suite 'lib options' ->
  data =
    'function square(x) {\n'
    '  return x * x;\n'
    '}\n'

  results = [
    '1:function square(##x#) {'
    '2:  return ##x# * x;'
    '2:  return x * ##x#;'
  ]

  suite 'stdin' ->
    test 'basic' ->
      eq '#x', results, it, {stdin: StdIn data}

    test 'using -' ->
      eq '#x -', results, it, {stdin: StdIn data}

    test '- and files' ->
      results =
        'test/data/a.js:1:function ##square#(x) {'
        '(standard input):1:function ##square#(x) {'
      eq '#square test/data/a.js - test/data/b.js', results, it, {stdin: StdIn data}

    test 'error in stdin input' ->
      eq '#x', [func-type: 'error', value: /Could not parse JavaScript/], it, {stdin: StdIn '%$@%@%'}

    test 'error: stdin not defined' ->
      eq '#x', [func-type: 'error', value: /Error: stdin not defined/], it

  suite 'exit' ->
    f = (done, expected, result) -->
      equal result, expected
      done!

    test 'matches' ->
      q '#x test/data/a.js', {exit: f it, 0; error: ->}

    test 'no matches' ->
      q '#NONEXISTANT test/data/a.js', {exit: f it, 1; error: ->}

    test 'no exit' ->
      equal void, q '--version', {error: ->}

  suite 'file system (fs)' ->
    fs = new FileSystem do
      'file.js':
        type: 'file'
        contents: '''
        function square(x) {
          return x * x;
        }
        '''

    test 'basic' ->
      eq 'return file.js', '2:  ##return x * x;#', it, {fs}

  suite 'text-format' ->
    text-format =
      green: ->
      cyan: ->
      magenta: ->
      red: ->
      bold: -> "!!#it!!"

    test 'basic' ->
      eq 'return test/data/a.js', '2:  !!return x * x;!!', it, {text-format}

  suite 'input' ->
    input = '''
            if (x) {
              f(2 + x);
            }
            '''

    test 'basic' ->
      eq 'bi', '2:  f(##2 + x#);', it, {input}

    test 'filename' ->
      eq 'bi --filename', '(input):2:  f(##2 + x#);', it, {input}
