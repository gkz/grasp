out = -> console.log "#it\n"

to-md = ->
  it.replace /\n/g, '\n\n'
    .replace /`{{(.*)}}`/g, '&#x20;<code>{% raw %}{{$1}}{% endraw %}</code>'
    .replace /\[/g, '\\['
    .replace /\]/g, '\\]'
# this shouldn't be this difficult :/

star-to-em = (.replace /\*([^\*]*)\*/g, '<em>$1</em>')

module.exports = {out, star-to-em, to-md}
