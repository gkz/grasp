path = require 'path'

module.exports = class Process
  ->
    @_cwd = '/'

  stdout: {}
  cwd: -> @_cwd
  previous-cwd: -> @_previous-cwd
  chdir: (dir) !->
    @_previous-cwd = @_cwd
    @_cwd = path.resolve @_cwd, dir
