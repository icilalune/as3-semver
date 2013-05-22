# AS3 SemVer

A library for semantic versioning ([semver](http://semver.org/)) in AS3. This is a port of [node-semver](https://github.com/isaacs/node-semver).

## Usage

```as3
SemVer.valid('1.2.3') // '1.2.3'
SemVer.valid('a.b.c') // null
SemVer.clean('  =v1.2.3   ') // '1.2.3'
SemVer.satisfies('1.2.3', '1.x || >=2.5.0 || 5.0.0 - 7.2.3') // true
SemVer.gt('1.2.3', '9.8.7') // false
SemVer.lt('1.2.3', '9.8.7') // true
```

## Tests

```sh
$ make test
```

You must have the [AIR SDK](http://www.adobe.com/devnet/air/air-sdk-download.html) installed and the "bin" directory added to your PATH.

## License

Copyright &copy; 2013 Isaac Z. Schlueter, Creative Market, & Contributors
All rights reserved.

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