# ubyssey/salary-analysis
*Visualizations of the public [UBC salary information](https://github.com/ubyssey/salarydb) obtained by the Ubyssey.*


## Dev setup
*As it applies to the departments/dept family; to be updated.*

**Dependencies** are `jQuery` and `d3.js`. jQuery is loaded from the Google
CDN as on ubyssey.ca; d3 is saved locally. (Subject to change). We also
use [`d3-tip.js`](https://github.com/Caged/d3-tip), which is packaged in this 
repo at the moment.

**Development dependencies** are noted in `package.json` and can be automatically
installed by running `npm install`. Direct deps are just `grunt` and various `grunt-contrib-*` friends, which themselves depend on things like `coffee-script` and `jade`.

Since these are all static files, the following should work for development:
```
$ git clone https://github.com/ubyssey/salary-analysis.git
$ cd salary-analysis
$ npm install
$ python -m SimpleHTTPServer 8008
```
and, in a separate tab,
```
$ grunt watch
```
and then navigating to `localhost:8008/charts/departments.html` or whichever chart.


### License for [d3-tip](https://github.com/Caged/d3-tip)

The MIT License (MIT)
Copyright (c) 2013 Justin Palmer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.