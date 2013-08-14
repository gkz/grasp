path = require 'path'
window.process = stdout: {} # required to placate cli-color when we require grasp next line
FileSystem = require './fs'
Process = require './process'
{run} = require './command'

process = new Process
fs = new FileSystem process

# initial files
fs.write-file-sync 'a.js', '''
                           var x = 1;\n
                           '''
fs.write-file-sync 'b.js', '''
                           if (x < 2) {
                             f(x);
                           }\n
                           '''
fs.write-file-sync 'c.js', '''
                           while (y) {
                             y.pop()
                           }\n
                           '''

# solarized colors for terminal output
$.terminal.ansi_colors.normal =
    black: '#000'
    red: '#dc322f'
    green: '#859900'
    yellow: '#b58900'
    blue: '#268bd2'
    magenta: '#d33682'
    cyan: '#2aa198'
    white: '#839496'

<- $
$demo = $ '#demo-terminal'
$demo.terminal do
  (args, term) -> run {callback: term.echo, error: term.error, term: term, fs, process}, args
  greetings: ''
  enabled: false
  keydown: (e, term) -> term.resume! if (e.which or e.key-code) in [67, 90] and e.ctrl-key # CTRL+C or CTRL+Z
  prompt: ->
    it process.cwd! + '[[;#b58900;]$] '
