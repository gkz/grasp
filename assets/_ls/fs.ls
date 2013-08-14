{keys, compact, Obj} = require 'prelude-ls'
path = require 'path'

module.exports = class FileSystem
  (@process) ->
    @fs =
      type: 'directory'
      contents: {}

  _get-at-path: (target-path) ->
    current = @fs
    parts = compact target-path.split '/'
    for part, i in parts
      if current.type is 'directory'
        if current.contents[part]
          current = that
          continue
      throw new Error "#target-path: No such file or directory"
    current

  exists-sync: (target-path) ->
    try
      @_get-at-path target-path
      return true
    catch
      return false

  read-file-sync: (target-path) ->
    abs-path = path.resolve @process.cwd!, target-path
    node = @_get-at-path abs-path
    if node.type is 'directory'
      throw new Error "#abs-path is directory"
    else
      node.contents

  write-file-sync: (target-path, data) !->
    filename = path.basename target-path
    parent = @_get-at-path path.resolve @process.cwd!, target-path, '..'
    parent.contents[filename] =
      type: 'file'
      contents: data

  append-file-sync: (target-path, data) !->
    node = @_get-at-path path.resolve @process.cwd!, target-path
    if /\n$/.test node.contents
      node.contents += data
    else
      node.contents += "\n#data"

  mkdir-sync: (target-path) !->
    dirname = path.basename target-path
    parent = @_get-at-path path.resolve @process.cwd!, target-path, '..'
    parent.contents[dirname] =
      type: 'directory'
      contents: {}

  readdir-sync: (target-path) ->
    node = @_get-at-path path.resolve @process.cwd!, target-path
    if node.type is 'file'
      throw new Error "#target-path is file"
    else
      keys node.contents

  lstat-sync: (target-path) ->
    node = @_get-at-path path.resolve @process.cwd!, target-path
    is-directory: -> node.type is 'directory'
    is-file: -> node.type is 'file'

  cp-sync: (source, destination) ->
    dest-name = path.basename destination
    source-node = @_get-at-path path.resolve @process.cwd!, source
    destination-parent = @_get-at-path path.resolve @process.cwd!, destination, '..'
    destination-parent.contents[dest-name] = source-node

  mv-sync: (source, destination) ->
    basename = path.basename source
    dest-name = path.basename destination
    source-node = @_get-at-path path.resolve @process.cwd!, source
    parent-node = @_get-at-path path.resolve @process.cwd!, source, '..'
    delete parent-node.contents[basename]
    destination-parent = @_get-at-path path.resolve @process.cwd!, destination, '..'
    destination-parent.contents[dest-name] = source-node

  unlink-sync: (target-path, recursive) !->
    target-name = path.basename target-path
    resolved-path = path.resolve @process.cwd!, target-path
    parent-path = path.resolve resolved-path, '..'
    parent = @_get-at-path parent-path

    if '/' is resolved-path
      throw new Error 'rm: cannot remove root directory'
    else if parent.contents[target-name]
      if that.type is 'file' or recursive
        delete parent.contents[target-name]
      else
        throw new Error "rm: cannot remove '#target-path': Is a directory"
    else
      throw new Error "rm: cannot remove '#target-path': No such file or directory"

  rmdir-sync: (target-path) !->
    target-name = path.basename target-path
    resolved-path = path.resolve @process.cwd!, target-path, '..'
    parent = @_get-at-path resolved-path

    if '/' is path.resolve resolved-path, target-name
      throw new Error 'rmdir: cannot remove root directory'
    else if parent.contents[target-name]
      target = that
      if target.type is 'directory'
        if Obj.empty target.contents
          delete parent.contents[target-name]
        else
          throw new Error "rmdir: failed to remove '#target-path': Directory not empty"
      else
        throw new Error "rmdir: cannot remove '#target-path': Not a directory"
    else
      throw new Error "rmdir: cannot remove '#target-path': No such file or directory"
