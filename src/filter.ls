filter = (name, args, {raw-prepend, raw-prepend, results, text-operations}) ->
  if not args.length and name in <[ prepend before after prepend append wrap nth nth-last
                                            slice each replace substring substr str-slice ]>
    throw new Error "No arguments supplied for '#filter-name' filter"
  else if name in <[ replace ]> and args.length < 2
    throw new Error "Must supply at least two arguments for '#filter-name' filter"

  switch name
  | 'join' =>
    join := if args.length then "#{args.0}" else ''
  | 'before' =>
    raw-prepend := "#{args.0}#raw-prepend"
  | 'after' =>
    raw-append += "#{args.0}"
  | 'wrap' =>
    [pre, post] = if args.length is 1 then [args.0, args.0] else args
    raw-prepend := "#pre#raw-prepend"
    raw-append += "#post"
  | 'prepend' =>
    for arg in args then results.unshift type: 'Raw', raw: "#arg"
  | 'append' =>
    for arg in args then results.push type: 'Raw', raw: "#arg"
  | 'each' =>
    throw new Error "No arguments supplied for 'each #{args.0}'" if args.length < 2
    switch args.0
    | 'before' =>
      for result in results
        result.raw-prepend = "#{args.1}#{ result.raw-prepend ? ''}"
    | 'after' =>
      for result in results
        result.raw-append = "#{ result.raw-append ? ''}#{args.1}"
    | 'wrap' =>
      [pre, post] = if args.length is 2 then [args.1, args.1] else [args.1, args.2]
      for result in results
        result.raw-prepend = "#{pre}#{ result.raw-prepend ? ''}"
        result.raw-append = "#{ result.raw-append ? ''}#{post}"
    | otherwise =>
      throw new Error "'#{args.0}' is not supported by 'each'"
  | 'nth' =>
    n = +args.0
    results := results.slice n, (n + 1)
  | 'nth-last' =>
    n = results.length - +args.0 - 1
    results := results.slice n, (n + 1)
  | 'first', 'head' =>
    results := results.slice 0, 1
  | 'tail' =>
    results := results.slice 1
  | 'last' =>
    len = results.length
    results := results.slice (len - 1), len
  | 'initial' =>
    results := results.slice 0, (results.length - 1)
  | 'slice' =>
    results := [].slice.apply results, args
  | 'reverse' =>
    results.reverse!
  | 'replace' =>
    let args
      text-operations.push (.replace args.0, args.1)
  | 'lowercase' =>
    text-operations.push (.to-lower-case!)
  | 'uppercase' =>
    text-operations.push (.to-upper-case!)
  | 'capitalize' =>
    text-operations.push capitalize
  | 'uncapitalize' =>
    text-operations.push -> (it.char-at 0).to-lower-case! + it.slice 1
  | 'camelize' =>
    text-operations.push camelize
  | 'dasherize' =>
    text-operations.push dasherize
  | 'trim' =>
    text-operations.push (.trim!)
  | 'substring' =>
    let args
      text-operations.push (.substring args.0, args.1)
  | 'substr' =>
    let args
      text-operations.push (.substr args.0, args.1)
  | 'str-slice' =>
    let args
      text-operations.push (.slice args.0, args.1)
  | otherwise =>
    throw new Error "Invalid filter: #filter-name#{ if args-str then " #args-str" else ''}"