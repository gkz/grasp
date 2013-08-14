pad = (str, num) ->
  len = str.length
  pad-amount = (num - len)
  "#str#{ ' ' * (if pad-amount > 0 then pad-amount else 0)}"

module.exports = {pad}
