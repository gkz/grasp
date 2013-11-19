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
      eq '--equery --replace "f({{__ && {} }})" "__ && __" test/data/dir/tttt.js', 'var a = f(b && {});', it

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
