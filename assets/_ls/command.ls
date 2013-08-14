{sort, names, unchars, words, unwords} = require 'prelude-ls'
path = require 'path'
{EventEmitter} = require 'events'
grasp = require 'grasp'

class StdIn extends EventEmitter
  (@data = []) ~>
    @done = false

  push: ->
    @data.push it
  finish: ->
    @done = true
  emit-data: ~>
    @emit 'data', @data.shift! if @data.length
    if not @data.length and @done
      clear-interval @interval
      @emit 'end'
  resume: -> @interval = set-interval @emit-data, 0
  set-encoding: ->

bold = -> "[[b;;]#it]"

aliases =
  '..':
    'cd'
    ['..']
  '...':
    'cd'
    ['../..']
  '....':
    'cd'
    ['../../..']
  'l':
    'ls'
    []

run-command = ({fs, process, term, callback, error, stdin, exit}, [command, ...args]) !->
  mv-cp = (cmd, args) !->
    [...sources, dest] = args
    try
      dest-is-dir = fs.lstat-sync dest .is-directory!
    catch
      dest-is-dir = false

    if dest-is-dir
      for source in sources
        dest-path = path.join dest, (path.basename source)
        try
          if cmd is 'mv'
            fs.mv-sync source, dest-path
          else
            fs.cp-sync source, dest-path
        catch
          error "#cmd: #{e.message}"
    else
      if sources.length is 1
        source = sources.0
        try
          if cmd is 'mv'
            fs.mv-sync source, dest
          else
            fs.cp-sync source, dest
        catch
          error "#cmd: #{e.message}"
      else
        error "#cmd: target '#dest' is not a directory"

  write-append = (cmd, args) ->
    output = ''
    stdin.on 'data', (output +=)
    stdin.on 'end', ->
      for target-path in args
        try
          fs["#{cmd}FileSync"] target-path, output
        catch
          error "Failed #{cmd}ing to #target-path"
      exit!
    stdin.resume!

  if command of aliases
    [command, args] = aliases[command]

  switch command
  | 'grasp' =>
    grasp do
      args: unwords args
      error: error
      callback: callback
      exit: exit
      stdin: stdin
      fs: fs
      console:
        log: callback
        warn: callback
        error: callback
        time: ->
        time-end: ->
  | 'clear' =>
    term.clear!
  | 'pwd' =>
    callback process.cwd!
  | 'ls' =>
    names = fs.readdir-sync args.0 || '.'
    output = for name in sort names
      if fs.lstat-sync name .is-directory! then bold name else name
    callback unwords output
  | 'cd' =>
    target = args.0 or '/'
    target-path = if target is '-' then process.previous-cwd! else path.resolve process.cwd!, target
    if fs.exists-sync target-path
      process.chdir target-path
    else
      error "cd: #target-path: No such file or directory"
  | 'mkdir' =>
    target-path = args.0
    try
      fs.mkdir-sync target-path
    catch
      error "mkdir: #{e.message}"
  | 'cat' =>
    output = []
    for file in args
      try
        output.push fs.read-file-sync file
      catch
        error "cat: #{e.message}"
    callback <| unchars output .replace /\n$/, ''
  | 'echo' =>
    callback unwords args
  | 'touch' =>
    try
      fs.write-file-sync args.0, ''
    catch
      error "touch: #{e.message}"
  | 'rm' =>
    if args.0 is '-r'
      args.shift!
      recursive = true
    else
      recursive = false
    for target in args
      try
        fs.unlink-sync target, recursive
      catch e
        error e.message
  | 'rmdir' =>
    for target in args
      try
        fs.rmdir-sync target
      catch e
        error e.message
  | 'cp' => mv-cp 'cp', args
  | 'mv' => mv-cp 'mv', args
  | 'write' => write-append 'write', args
  | 'append' => write-append 'append', args
  | 'edit' =>
    filename = args.0
    try
      output = fs.read-file-sync filename
    catch
      output = ''
    $demo-container = $ '#demo-container'
    $term = $ '#demo-terminal'
    $term.hide!
    $demo-container.append """
       <div class="edit-file">
         <textarea class="term">#output</textarea>
         <div class="edit-buttons">
           <button type="button" class="btn btn-primary action-save">Save</button>
           <button type="button" class="btn btn-default action-cancel">Cancel</button>
         </div>
       </div>
       """

    $demo-container.find '.edit-file textarea' .focus!

    cancel = ->
      $ '.edit-file' .remove!
      $term.show!
      $term.click!
      exit!

    save = ->
      fs.write-file-sync filename, ($demo-container.find '.edit-file textarea' .val!)
      $demo-container.find '.edit-file' .remove!
      $term.show!
      $term.click!
      exit!

    $demo-container.find '.edit-file .action-cancel' .click cancel
    $demo-container.find '.edit-file .action-save' .click save
  | otherwise =>
    error "Invalid command: #command #{ unwords args }"
  exit! unless command in <[ grasp edit write ]>

args-regex =
  //
    '(?:[^']|\\')+'
  | "(?:[^"]|\\")+"
  | \| | < | >> |  > | ;
  | [^\s\|<>;]+
  //g

run = ({term}:options, args) !->
  term.pause!
  args.=trim!
  ga 'send', 'event', 'demo', 'run', 'args', args

  tokens = args.match args-regex
  tokens.push ';' unless tokens[*-1] is ';'

  commands = []
  sequence = []
  tokens-so-far = []

  while tokens.length
    token = tokens.shift!
    switch token
    | '|' =>
      sequence.push tokens-so-far
      tokens-so-far := []
    | ';' =>
      sequence.push tokens-so-far if tokens-so-far.length
      commands.push sequence
      tokens-so-far := []
      sequence := []
    | '<' =>
      sequence.push ['cat', tokens.shift!]
    | '>' =>
      sequence.push tokens-so-far
      tokens-so-far := []
      sequence.push ['write', tokens.shift!]
    | '>>' =>
      sequence.push tokens-so-far
      tokens-so-far := []
      sequence.push ['append', tokens.shift!]
    | _   =>
      tokens-so-far.push token

  for sequence in commands
    last-i = sequence.length - 1
    stdin = new StdIn
    for command, i in sequence
      [stdin, callback, exit] = if i is last-i
        [stdin, options.callback, -> term.resume!]
      else
        stdin := new StdIn

        * stdin
          -> stdin.push it
          ->
            stdin.finish!
            term.resume!

      run-command-options =
        fs: options.fs
        process: options.process
        term: options.term
        callback: callback
        error: options.error
        stdin: stdin
        exit: exit
      run-command run-command-options, command

module.exports = {run}
