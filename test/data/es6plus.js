// @flow
import w from 'w';
import type t from 'types';

type XYZ = {
  a: string,
  b: number,
}

interface Comparable<T> {
  compare(a: T, b: T): number;
}

class C {
  s: string;
  n: number;
  constructor(s) {
    this.s = s;
  }
  foo() {
    return this.n;
  }
  bar(a: number) {
    this.n += a;
  }
  render() {
    return <div style={{width: this.n}}>Hi {this.s}!</div>;
  }
}
