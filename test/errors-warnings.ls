{grasp, eq, q} = require './_helpers'
{throws} = require 'assert'

suite 'errors and warnings' ->
  test 'call with nothing' ->
    throws (-> grasp!), /Must specify arguments/

  test 'must specify arguments' ->
    eq null, [func-type: 'error', value: 'Error: Must specify arguments.'], it

  test 'option parsing errors' ->
    msg = "Invalid value for option 'context' - expected type n::Int, received value: hi."
    eq '--context hi "#x" t.js', {func-type: 'error', value: msg}, it

  test 'no such file (single target file)' ->
    eq 'x test/data/FAKE.js' [
      func-type: 'error', value: "Error: No such file or directory 'test/data/FAKE.js'."
    ], it

  test 'no selector specified' ->
    eq '' [
      func-type: 'error', value: /Error: No selector specified./
      /Usage: grasp/
    ], it

  test 'no selector specified with default error func' ->
    throws (-> q ''), /No selector specified/

  test 'could not parse JS' ->
    eq 'x test/data/badly-formed.js', {func-type: 'error', value: /Error: Could not parse JavaScript/}, it

  test 'warn - use -r' ->
    eq '"#x" test/data', {func-type: 'warn', value: "'test/data' is a directory. Use '-r, --recursive' to recursively search directories."}, it
