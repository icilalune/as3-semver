# as3-semver

A library for semantic versioning ([semver](http://semver.org/)) in AS3.

This is a port of [node-semver](https://github.com/isaacs/node-semver). 100% of the original 856 tests pass.

### Usage

```as3
SemVer.clean('  =v1.2.3   ') // '1.2.3'
SemVer.satisfies('1.2.3', '1.x || >=2.5.0 || 5.0.0 - 7.2.3') // true
SemVer.satisfies('1.2.0', '0.3.X') // false
SemVer.gt('1.2.3', '9.8.7') // false
SemVer.lt('1.2.3', '9.8.7') // true
SemVer.valid('1.2.3') // '1.2.3'
SemVer.valid('a.b.c') // null
```

## Methods

<table width="100%">
  <tr>
    <th align="left" width="150px">Method</th>
    <th width="80px">Returns</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>gt(v1, v2)</code></td>
    <td align="center">boolean</td>
    <td>Returns true if v1 > v2.</td>
  </tr>
  <tr>
    <td><code>lt(v1, v2)</code></td>
    <td align="center">boolean</td>
    <td>Returns true if v1 < v2.</td>
  </tr>
  <tr>
    <td><code>SemVer.gte(v1, v2)</code></td>
    <td align="center">boolean</td>
    <td>Returns true if v1 >= v2.</td>
  </tr>
  <tr>
    <td><code>lte(v1, v2)</code></td>
    <td align="center">boolean</td>
    <td>Returns true if v1 <= v2.</td>
  </tr>
  <tr>
    <td><code>eq(v1, v2)</code></td>
    <td align="center">boolean</td>
    <td>Returns true if v1 === v2.</td>
  </tr>
  <tr>
    <td><code>neq(v1, v2)</code></td>
    <td align="center">boolean</td>
    <td>Returns true if v1 !== v2.</td>
  </tr>
  <tr>
    <td><code>gt(v1, op, v2)</code></td>
    <td align="center">boolean</td>
    <td>Compares two versions. The "op" argument should be one of the following: ">", "<", ">=", "<=", "==", "!=", "===", or "!==".</td>
  </tr>
  <tr>
    <td><code>satisfies(version, range)</code></td>
    <td align="center">boolean</td>
    <td>Determines if the provided version satisfies teh given range.</td>
  </tr>
  <tr>
    <td valign="top"><code>compare(v1, v2)</code></td>
    <td align="center" valign="top">int</td>
    <td>Compares two versions and returns an integer result (0: equal, 1: v1 > v2, -1: v1 < v2). Useful for sorting versions.</td>
  </tr>
</table>

## Tests

```sh
$ make test
```

You must have the latest [AIR SDK](http://www.adobe.com/devnet/air/air-sdk-download.html) installed and the "bin" directory added to your PATH.

## License

Copyright &copy; 2013 Isaac Z. Schlueter, Creative Market, & Contributors — All rights reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.