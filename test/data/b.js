debugger;
function foobar(o) {
  with (o) {
    return zz + zz;
  }
}
