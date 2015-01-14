## Dev setup

**Dependencies** are `jQuery` and `d3.js`, however by default these are loaded 
in `departments.jade` from the Cloudflare JS CDN. (Subject to change.) We also
use [`d3-tip.js`](https://github.com/Caged/d3-tip), but it's packaged in this 
repo at the moment.

**Development dependencies** are noted in `package.json`. Direct deps are just
`grunt` and various `grunt-contrib-*` friends, but they themselves depend on 
things like `coffee-script` and `jade`.

Since these are all static files, for development I've just been doing
```
$ cd depts-faculties/app
$ python -m SimpleHTTPServer 8008
```
and then navigating to `localhost:8008/departments.html`.


### License for [d3-tip](https://github.com/Caged/d3-tip)

The MIT License (MIT)
Copyright (c) 2013 Justin Palmer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.