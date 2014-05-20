{eq} = require './_helpers'

suite 'json' ->
  suite 'basic' ->
    test 'single file' ->
      eq '--json return test/data/a.js', /^\[{"type":"ReturnStatement"/, it

    test 'single file without callback' ->
      eq '--json return test/data/a.js', /^\[{"type":"ReturnStatement"/, it, {-callback}

    test 'multiple files' ->
      eq '--json return test/data/a.js test/data/b.js', /^{"test\/data\/a.js":\[/, it

    test 'multiple files no filename' ->
      eq '--no-filename --json return test/data/a.js test/data/b.js', /^\[\[/, it

  suite 'files with/without match' ->
    test 'single file - files-with-matches' ->
      eq '--files-with-matches --json return test/data/a.js', '["test/data/a.js"]', it

    test 'single file - files-with-matches - no results' ->
      eq '--files-with-matches --json "return.arg::func" test/data/a.js', '[]', it

    test 'single file - files-without-match' ->
      eq '--files-without-match --json "return.arg::func" test/data/a.js', '["test/data/a.js"]', it

    test 'single file - files-without-match - no results' ->
      eq '--files-without-match --json return test/data/a.js', '[]', it

  suite 'count' ->
    test 'single file - no filename' ->
      eq '--count --json "#x" test/data/a.js', '[3]', it

    test 'single file - with filename' ->
      eq '--count --json --filename "#x" test/data/a.js', '{"test/data/a.js":3}', it

    test 'multiple files - no filename' ->
      eq '--count --json --no-filename "#/^z/" test/data/a.js test/data/b.js', '[3,2]', it

    test 'multiple files - with filename' ->
      eq '--count --json "#/^z/" test/data/a.js test/data/b.js', '{"test/data/a.js":3,"test/data/b.js":2}', it
