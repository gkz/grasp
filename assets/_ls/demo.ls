path = require 'path'
window.process = stdout: {} # required to placate cli-color when we require grasp next line
FileSystem = require './fs'
Process = require './process'
{run} = require './command'

process = new Process
window.process = process
fs = new FileSystem process

# initial files
fs.write-file-sync 'a.js', '''
                           function g(x) {
                             if (x && f(x)) { return [1, 2]; }
                             doSomething();
                             while(x < 2) {
                               if (xs.length && ys.length) {
                                 return xs[x] + ys[x];
                               }
                               x++;
                             }
                             if (x == 3 && list[x]) {
                               return list;
                             }
                           }
                           '''
fs.write-file-sync 'b.js', '''
                           function g(x, str) {
                             if (x == null) { return; }
                             if (x < 2) { return x + 2; }
                             switch (n) {
                               case 1:
                                 f({x: str});
                                 try {
                                   zz(o);
                                 } catch (e) {
                                   return e;
                                 }
                               case 2:
                                 return '>>' + str.slice(2);
                             }
                             return f(z) + x;
                           }
                           '''
fs.write-file-sync 'c.js', '''
                           f(x < y, x == z);
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
