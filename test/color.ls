{eq} = require './_helpers'
clc = require 'cli-color'

suite 'color' ->
  test 'basic single line' ->
    eq 'return test/data/t.js', "#{ clc.green 2 }#{ clc.cyan ':' }  #{ clc.red clc.bold 'return x * x;'}", it, {+color}
