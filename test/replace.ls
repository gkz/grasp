{eq} = require './_helpers'
{strict-equal: equal}:assert = require 'assert'
fs = require 'fs'

suite 'replace' ->
  test 'single line same length' ->
    eq '--replace XX "#zz" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return XX + XX;
        }
      }''', it

  test 'single line longer length' ->
    eq '--replace XXX "#zz" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return XXX + XXX;
        }
      }''', it

  test 'single line shorter length' ->
    eq '--replace X "#zz" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return X + X;
        }
      }''', it

  test 'multiple lines to multiple lines' ->
    eq '--replace "{\n\n    return zz + zz; }" "with block" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {

          return zz + zz; }
      }''', it

  test 'multiple lines to single line' ->
    eq '--replace "{ return zz + zz; }" "with block" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) { return zz + zz; }
      }''', it

  test 'multiple lines to single line with end context' ->
    eq '--replace "z - foo" bi test/data/dir/ttt.js', '''var moooo = 23;
      var x = z - foo; z - foo;''', it

  test 'single line to multiple lines' ->
    eq '--replace "return zz +\nzz;" return test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return zz +
      zz;
        }
      }''', it

  test 'replace from file' ->
    eq '--replace-file test/data/replacement debugger test/data/tt.js', '''console.log('debug');
      function foobar(o) {
        with (o) {
          return zz + zz;
        }
      }''', it

  test 'replace from file error' ->
    eq '--replace-file test/data/FAKE debugger test/data/t.js', [
      {func-type: 'error', value: "Error: No such file 'test/data/FAKE'."}
    ], it

  test 'after selector' ->
    eq '"#zz" --replace XX test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return XX + XX;
        }
      }''', it

  test 'replacement with {}' ->
    eq '--replace "{}" "#zz" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return {} + {};
        }
      }''', it

  suite 'whole match replacement' ->
    test 'single line' ->
      eq '--replace "o({{}}) bi test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return o(zz + zz);
        }
      }''', it

    test 'single line multiple' ->
      eq '--replace "o({{}})" "#zz" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return o(zz) + o(zz);
        }
      }''', it

    test 'single line multiple to multiple lines' ->
      eq '--replace "o({\n      a: {{{}}: 1}\n    })" "#zz" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return o({
            a: {zz: 1}
          }) + o({
            a: {zz: 1}
          });
        }
      }''', it

    test 'multiple lines' ->
      eq '--replace "var f = {{}}" func test/data/tt.js', '''debugger;
      var f = function foobar(o) {
        with (o) {
          return zz + zz;
        }
      }''', it

  suite 'sub match replacement' ->
    test 'prop' ->
      eq '--replace "function moo(oooo) {{.body}}" "func" test/data/tt.js', '''debugger;
      function moo(oooo) {
        with (o) {
          return zz + zz;
        }
      }''', it

    test 'child' ->
      eq '--replace "function moo(oooo) {{block}}" "func" test/data/tt.js', '''debugger;
      function moo(oooo) {
        with (o) {
          return zz + zz;
        }
      }''', it

    test 'operator' ->
      eq "--replace 'x {{.op}} y' 'bi' test/data/tt.js", '''debugger;
      function foobar(o) {
        with (o) {
          return x + y;
        }
      }''', it

    test 'more complex' ->
      replacement = '{\n  if ({{with.object}} == 9) {\n    return 2 {{bi.op}} 3;\n  }\n}'
      eq "--replace '#replacement' 'func.body' test/data/tt.js", '''debugger;
      function foobar(o) {
        if (o == 9) {
          return 2 + 3;
        }
      }''', it

    test 'even more complex' ->
      replacement = '{\n  f({{with[obj=#o] return ident}} == {{bi[op=+] ident}});\n}'
      eq "--replace '#replacement' 'func.body' test/data/tt.js", '''debugger;
      function foobar(o) {
        f(zz == zz);
      }''', it

    test 'overlapping' ->
      eq 'bi --replace "{{.l}}-{{.r}}"', 'f(1 + 2-3);', it, {input: 'f(1 + 2 + 3);'}

    test 'no sub result' ->
      eq '--replace "lala({{FAKE}});" "func" test/data/tt.js', '''debugger;
      lala();
      ''', it

    test 'equery' ->
      eq '--equery --replace "return o({{__ + __}});" "return __;" test/data/tt.js', '''debugger;
      function foobar(o) {
        with (o) {
          return o(zz + zz);
        }
      }''', it

    test 'equery with {} in replacement' ->
      eq '--equery --replace "f({{__ && {} }})" "__ && __"', 'var a = f(b && {});', it, {input: 'var a = b && {};'}

  suite 'filters' ->
    obj-input = '''
                var obj = {
                  a: 1,
                  b: 2,
                  c: 3
                };
                '''
    arr-input = '[1,2,3,4]'

    test 'args escaped single quote' ->
      eq '''arr --replace "['{{ num | join '\\', \\''}}']"''', "['1', '2', '3', '4']", it, {input: arr-input}

    test 'args escaped double quote' ->
      eq '''arr --replace '["{{ num | join "\\", \\""}}"]' ''', '["1", "2", "3", "4"]', it, {input: arr-input}

    test 'args escaped single char' ->
      eq 'arr --replace "[{{ num | join \\\ }}]"', '[1\\2\\3\\4]', it, {input: arr-input}

    test 'join' ->
      result = '''
               var obj = {
                 a: 1,
                 b: 2,
                 c: 3,
                 d: 4
               };
               '''
      eq 'obj --replace "{\n  {{.props | join \',\n  \' }},\n  d: 4\n}"', result, it, {input: obj-input}

    test 'join no arg' ->
      eq 'arr --replace "[{{ num | join }}]"', '[1234]', it, {input: arr-input}

    test 'join before other filters' ->
      eq 'arr --replace "[{{ num | join \', \' | tail }}]"', '[2, 3, 4]', it, {input: arr-input}

    test 'prepend' ->
      eq 'arr --replace "[{{ num | prepend 0 | join \', \' }}]"', '[0, 1, 2, 3, 4]', it, {input: arr-input}

    test 'prepend multiple args' ->
      eq 'arr --replace "[{{ num | prepend 0 -1 | join \', \' }}]"', '[-1, 0, 1, 2, 3, 4]', it, {input: arr-input}

    test 'append' ->
      eq 'arr --replace "[{{ num | append 5 | join \', \' }}]"', '[1, 2, 3, 4, 5]', it, {input: arr-input}

    test 'append multiple args' ->
      eq 'arr --replace "[{{ num | append 5 6 | join \', \' }}]"', '[1, 2, 3, 4, 5, 6]', it, {input: arr-input}

    test 'before' ->
      eq 'arr --replace "[{{ num | join \', \' | before \'0, \' }}]"', '[0, 1, 2, 3, 4]', it, {input: arr-input}

    test 'before multiple times' ->
      eq 'arr --replace "[{{ num | join \', \' | before \'0, \' | before \'-1, \'}}]"', '[-1, 0, 1, 2, 3, 4]', it, {input: arr-input}

    test 'after' ->
      eq 'arr --replace "[{{ num | join \', \' | after \', 5\' }}]"', '[1, 2, 3, 4, 5]', it, {input: arr-input}

    test 'after multiple times' ->
      eq 'arr --replace "[{{ num | join \', \' | after \', 5\' | after \', 6\'}}]"', '[1, 2, 3, 4, 5, 6]', it, {input: arr-input}

    test 'wrap one arg' ->
      eq 'arr --replace "[{{ num | join \', \' | wrap \\\' }}]"', "['1, 2, 3, 4']", it, {input: arr-input}

    test 'wrap two args' ->
      eq 'arr --replace "[{{ num | join \', \' | wrap [ ] }}]"', '[[1, 2, 3, 4]]', it, {input: arr-input}

    test 'nth' ->
      eq 'arr --replace "[{{ num | nth 1 }}]"', '[2]', it, {input: arr-input}

    test 'nth-last' ->
      eq 'arr --replace "[{{ num | nth-last 1 }}]"', '[3]', it, {input: arr-input}

    test 'first' ->
      eq 'arr --replace "[{{ num | first }}]"', '[1]', it, {input: arr-input}

    test 'head' ->
      eq 'arr --replace "[{{ num | head }}]"', '[1]', it, {input: arr-input}

    test 'tail' ->
      eq 'arr --replace "[{{ num | tail }}]"', '[2]', it, {input: arr-input}

    test 'last' ->
      eq 'arr --replace "[{{ num | last }}]"', '[4]', it, {input: arr-input}

    test 'initial' ->
      eq 'arr --replace "[{{ num | initial }}]"', '[1]', it, {input: arr-input}

    test 'tail join' ->
      eq 'arr --replace "[{{ num | tail | join \', \' }}]"', '[2, 3, 4]', it, {input: arr-input}

    test 'initial join' ->
      eq 'arr --replace "[{{ num | initial | join \', \' }}]"', '[1, 2, 3]', it, {input: arr-input}

    test 'slice' ->
      eq 'arr --replace "[{{ num | slice 1 3 | join \', \' }}]"', '[2, 3]', it, {input: arr-input}

    test 'reverse' ->
      eq 'arr --replace "[{{ num | reverse | join \', \' }}]"', '[4, 3, 2, 1]', it, {input: arr-input}

    test 'each before' ->
      eq 'arr --replace "[{{ num | each before 1 | join \', \' }}]"', '[11, 12, 13, 14]', it, {input: arr-input}

    test 'each before multiple times' ->
      eq 'arr --replace "[{{ num | each before 1 | each before 0 | join \', \' }}]"', '[011, 012, 013, 014]', it, {input: arr-input}

    test 'each after' ->
      eq 'arr --replace "[{{ num | each after 0 | join \', \' }}]"', '[10, 20, 30, 40]', it, {input: arr-input}

    test 'each after multiple times' ->
      eq 'arr --replace "[{{ num | each after 0 | each after 0 | join \', \' }}]"', '[100, 200, 300, 400]', it, {input: arr-input}

    test 'each wrap one arg' ->
      eq '''arr --replace '[{{ num | each wrap \\" | join ", " }}]' ''', '["1", "2", "3", "4"]', it, {input: arr-input}

    test 'each wrap two args' ->
      eq '''arr --replace '[{{ num | each wrap ( ) | join ", " }}]' ''', '[(1), (2), (3), (4)]', it, {input: arr-input}

    test 'each wrap multiple times' ->
      eq '''arr --replace '[{{ num | each wrap ( ) | each wrap [ ] | join ", " }}]' ''', '[[(1)], [(2)], [(3)], [(4)]]', it, {input: arr-input}

    test 'each not enough args' ->
      eq 'arr --replace "[{{ num | each before | join \', \' }}]"', {func-type: 'error', value: /No arguments supplied for 'each before'/}, it, {input: arr-input}

    test 'invalid each' ->
      eq 'arr --replace "[{{ num | each FAKE 0 }}]"', {func-type: 'error', value: /'FAKE' is not supported by 'each'/}, it, {input: arr-input}

    test 'invalid filter' ->
      eq 'arr --replace "[{{ num | FAKE }}]"', {func-type: 'error', value: /Invalid filter: FAKE/}, it, {input: arr-input}

    test 'invalid filter with arg' ->
      eq 'arr --replace "[{{ num | FAKE arg }}]"', {func-type: 'error', value: /Invalid filter: FAKE arg/}, it, {input: arr-input}

    test 'no arg supplied' ->
      eq 'arr --replace "[{{ num | nth }}]"', {func-type: 'error', value: /No arguments supplied for 'nth' filter/}, it, {input: arr-input}

    test 'squery non-spaced |' ->
      eq 'arr --replace "{{ [op=|] }}"', 'x | y', it, {input: '[x | y]'}

    test 'squery spaced |' ->
      eq 'arr --replace "{{ [op= | ] }}"', 'x | y', it, {input: '[x | y]'}

    test 'equery' ->
      eq '"f(__)" --equery --replace "[{{ x|y }}]"', '[x | y]', it, {input: 'f(x | y)'}

    test 'equery filter fail' ->
      eq '"f(__)" --equery --replace "[{{ g( x | y ) }}]"', '[g(x|y)]', it, {input: 'f(g(x|y))'}

    test 'extra bit to args-str' ->
      eq 'arr --replace "[{{ num | after || }}2]"', '[1||2]', it, {input: '[1]'}

  suite 'named wildcards' ->
    test 'simple' ->
      eq '--equery --replace "{{b}} + {{a}}" "$a + $b"', 'x + y;', it, {input: 'y + x;'}

    test 'more complex' ->
      eq '--equery --replace "f({{b}}, true, {{b}}, {{a}})" "f($a, $b)"', 'f(x, true, x, y);', it, {input: 'f(y, x);'}

    test 'with filter' ->
      eq '--equery --replace "{{ num | wrap \\\' }}" "__ * $num"', "'2';", it, {input: 'x * 2;'}

    test 'array' ->
      eq '--equery --replace "f({{args | reverse | join \', \'}})" "f(_$args)"', 'f(x, y);', it, {input: 'f(y, x);'}

    test 'object' ->
      eq '--equery --replace "{ {{props | reverse | join \', \'}} }" "({_:$props})"', '{ y:2, x: 1 };', it, {input: '({x: 1, y:2});'}

  suite 'write to' ->
    replaced-content1 = '''
      debugger;
      function foobar(o) {
        with (o) {
          return XX + XX;
        }
      }
      '''

    replaced-content2 = '''
      function square(x) {
        return x * x;
      }
      var y = function(XX) {
        f.p(XX);
        XX++;
        var obj = {
          a: 1,
          b: 2,
          c: 3
        };
      }
      '''

    test 'object' ->
      eq '--replace XX --to "{test/data/tt.js: test/data/TMP.js}" "#zz" test/data/tt.js', [], it, do
        final: (content) ->
          path = './test/data/TMP.js'
          content = fs.read-file-sync path, 'utf8'
          fs.unlink-sync path
          equal content, replaced-content1

    test 'object with callback' ->
      eq '--replace XX --to "{test/data/tt.js: -}" "#zz" test/data/tt.js', [replaced-content1], it, do
        final: (content) ->
          equal content.'test/data/tt.js', replaced-content1

    test 'only write those input files which are present in the --to obj' ->
      eq '--replace XX --to "{test/data/tt.js: test/data/TMP.js}" "#/^z/" test/data/t.js test/data/tt.js', [], it, do
        final: (content) ->
          path = './test/data/TMP.js'
          content = fs.read-file-sync path, 'utf8'
          fs.unlink-sync path
          equal content, replaced-content1

    test 'string no special' ->
      eq '--replace XX --to "test/data/TMP.js" "#zz" test/data/tt.js', [], it, do
        final: (content) ->
          path = './test/data/TMP.js'
          content = fs.read-file-sync path, 'utf8'
          fs.unlink-sync path
          equal content, replaced-content1

    test 'string with special' ->
      eq '--replace XX --to "test/data/dir/%TMP.js" "#zz" test/data/tt.js', [], it, do
        final: (content) ->
          path = './test/data/dir/ttTMP.js'
          content = fs.read-file-sync path, 'utf8'
          fs.unlink-sync path
          equal content, replaced-content1

    test 'string with special, multiple files' ->
      eq '--replace XX --to "test/data/dir/%TMP.js" "#/^z/" test/data/t.js test/data/tt.js', [], it, do
        final: (content) ->
          path1 = './test/data/dir/ttTMP.js'
          path2 = './test/data/dir/tTMP.js'
          content1 = fs.read-file-sync path1, 'utf8'
          content2 = fs.read-file-sync path2, 'utf8'
          fs.unlink-sync path1
          fs.unlink-sync path2
          equal content1, replaced-content1
          equal content2, replaced-content2

    test 'in-place' ->
      path = './test/data/tt.js'
      orig = fs.read-file-sync path, 'utf8'

      eq '--replace XX --in-place "#/^z/" test/data/tt.js', [], it, do
        final: (content) ->
          content = fs.read-file-sync path, 'utf8'
          fs.write-file-sync path, orig
          equal content, replaced-content1

    test 'in-place, multiple files' ->
      path1 = './test/data/tt.js'
      path2 = './test/data/t.js'
      orig1 = fs.read-file-sync path1, 'utf8'
      orig2 = fs.read-file-sync path2, 'utf8'

      eq '--replace XX --in-place "#/^z/" test/data/t.js test/data/tt.js', [], it, do
        final: (content) ->
          content1 = fs.read-file-sync path1, 'utf8'
          content2 = fs.read-file-sync path2, 'utf8'
          fs.write-file-sync path1, orig1
          fs.write-file-sync path2, orig2
          equal content1, replaced-content1
          equal content2, replaced-content2
