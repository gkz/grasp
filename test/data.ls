{eq} = require './_helpers'
{strict-equal: equal, deep-equal}:assert = require 'assert'

suite 'data' ->
  suite 'basic' ->
    test 'single file' ->
      eq 'return test/data/t.js', /ReturnStatement/, it, do
        data: true
        final: (result) ->
          equal (typeof! result), 'Array'
          equal result.0.type, 'ReturnStatement'

    test 'multiple files' ->
      eq 'return test/data/t.js test/data/tt.js', [/t\.js/, /tt\.js/], it, do
        data: true
        final: (result) ->
          equal (typeof! result), 'Object'
          equal result.'test/data/t.js'.0.type, 'ReturnStatement'

    test 'multiple files, no filename' ->
      eq '--no-filename return test/data/t.js test/data/tt.js', [/ReturnStatement/, /ReturnStatement/], it, do
        data: true
        final: (result) ->
          equal (typeof! result), 'Array'
          equal (typeof! result.0), 'Array'
          equal result.0.0.type, 'ReturnStatement'

  suite 'files with/without matches' ->
    test 'single file - files-with-matches' ->
      eq '--files-with-matches return test/data/t.js', /test\/data\/t\.js/, it, do
        data: true
        final: (result) ->
          deep-equal result, ["test/data/t.js"]

    test 'single file - files-with-matches - no results' ->
      eq '--files-with-matches "return.arg::func" test/data/t.js', [], it, do
        data: true
        final: (result) ->
          deep-equal result, []

    test 'single file - files-without-match' ->
      eq '--files-without-match "return.arg::func" test/data/t.js', /test\/data\/t\.js/, it, do
        data: true
        final: (result) ->
          deep-equal result, ["test/data/t.js"]

    test 'single file - files-without-match - no results' ->
      eq  '--files-without-match return test/data/t.js', [], it, do
        data: true
        final: (result) ->
          deep-equal result, []

  suite 'count' ->
    test 'single file - no filename' ->
      eq '--count "#x" test/data/t.js', /3/, it, do
        data: true
        final: (result) ->
          deep-equal result, [3]

    test 'single file - with filename' ->
      eq '--count --filename "#x" test/data/t.js', /test\/data\/t\.js/, it, do
        data: true
        final: (result) ->
          deep-equal result, {"test/data/t.js": 3}

    test 'multiple files - no filename' ->
      eq '--count --no-filename "#/^z/" test/data/t.js test/data/tt.js', [/3/, /2/], it, do
        data: true
        final: (result) ->
          deep-equal result, [3, 2]

    test 'multiple files - with filename' ->
      eq '--count "#/^z/" test/data/t.js test/data/tt.js', [/t\.js/, /tt\.js/], it, do
        data: true
        final: (result) ->
          deep-equal result, {"test/data/t.js": 3, "test/data/tt.js": 2}
