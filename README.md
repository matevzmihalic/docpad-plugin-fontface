# @font-face Plugin for [DocPad](http://docpad.org)

[![Build Status](https://secure.travis-ci.org/matevzmihalic/docpad-plugin-fontface.png?branch=master)](http://travis-ci.org/matevzmihalic/docpad-plugin-fontface "Check this project's build status on TravisCI")
[![NPM version](https://badge.fury.io/js/docpad-plugin-fontface.png)](https://npmjs.org/package/docpad-plugin-fontface "View this project on NPM")

Generates all required fonts for embedding fonts in websites.
Currently only supported input format is svg.

Convention:  `.(ff|fontface).svg`

## Install

```
docpad install fontface
```

##Configuration

You can set which output files should be generated in `docpad.coffee`:

```
plugins:
  fontface:
    output: ['ttf', 'svg', 'eot', 'woff', 'css']
```

##TODO

* Support more input formats (at least ttf would be nice)


Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT License](http://creativecommons.org/licenses/MIT/)
<br/>Copyright &copy; 2014+ [Matevz Mihalic](https://github.com/matevzmihalic)