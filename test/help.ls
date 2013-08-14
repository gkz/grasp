{eq} = require './_helpers'

suite 'help' ->
  test 'no positional' ->
    eq '--help', /^Usage: grasp/, it

  test 'no positional no callback' ->
    eq '--help', /^Usage: grasp/, it, {-callback}

  test 'more' ->
    eq '--help more', /-h, --help\n==========\ndescription:/, it

  test 'advanced' ->
    eq '--help advanced', /-p, --parser/, it

  test 'option-name' ->
    eq '--help --context', /-C, --context n::Int\n====================\ndescription:/, it

  test 'short option-name' ->
    eq '--help -CA', /-C, --context n::Int[\s\S]+-A, --after-context/, it

  test 'multiple options' ->
    eq '--help --context --after-context', /-C, --context n::Int[\s\S]+-A, --after-context/, it

  test 'non existant option' ->
    eq '--help --FAKE', "Invalid option '--FAKE' - perhaps you meant '-A'?", it

  test 'verbose options' ->
    eq '--help verbose', /# Context control #[\s\S]+-A, --after-context n::Int[\s\S]+description: Print n/, it

  test 'syntax' ->
    eq '--help syntax', /JavaScript abstract syntax help:[\s\S]+if \(IfStatement\)/, it

  test 'node, syntax and multiple examples' ->
    eq '--help if', /if \(IfStatement\)[\s\S]+node fields: test, consequent \(alias: then\)[\s\S]+syntax:[\s\S]+examples:/, it

  test 'node with one example' ->
    eq '--help debugger', /debugger \(DebuggerStatement\)[\s\S]+example:/, it

  test 'node without syntax or example' ->
    eq '--help program', /program \(Program\)[\s\S]+node array fields: body/, it

  test 'node full name ' ->
    eq '--help DebuggerStatement', /debugger \(DebuggerStatement\)[\s\S]+example:/, it

  test 'multiple nodes' ->
    eq '--help debugger empty', /debugger \(DebuggerStatement\)[\s\S]+example:[\s\S]+empty \(EmptyStatement\)/, it

  test 'categories' ->
    eq '--help categories', /Categories of node types:[\s\S]+func \(Function\): func-dec, func-exp\n/, it

  test 'category' ->
    eq '--help func', /A node type category\.\n\nfunc \(Function\)[\s\S]+func-exp \(FunctionExpression\)/, it

  test 'category full name' ->
    eq '--help Function', /A node type category\.\n\nfunc \(Function\)[\s\S]+func-exp \(FunctionExpression\)/, it

  test 'no such help option' ->
    eq '--help FAKE', 'No such help option: FAKE.', it
