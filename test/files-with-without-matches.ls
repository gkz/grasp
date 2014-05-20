{eq} = require './_helpers'

suite 'files with/without matches' ->
  test 'single file - files-with-matches' ->
    eq '--files-with-matches return test/data/a.js', 'test/data/a.js', it

  test 'single file - files-with-matches - no results' ->
    eq '--files-with-matches "return.arg::func" test/data/a.js', [], it

  test 'single file - files-without-match' ->
    eq '--files-without-match "return.arg::func" test/data/a.js', 'test/data/a.js', it

  test 'single file - files-without-match - no results' ->
    eq '--files-without-match return test/data/a.js', [], it
