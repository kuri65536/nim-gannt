Simple Gannt chart tool by nim
====================================

Prerequirement
---------------------
- browser: tested with Firefox 64.0
- optional: python3 for serving the files.


Installation
---------------------
### from release
1. extract a release zip file.
2. open the gannt.html from a your web-browser.
3. then upload `sample.csv` from `upload` button.

```shell
$ unzip nim-gannt.v0.6.0.zip
$ browse gannt.html
```

### from source
1. download svg.js, svg.draggable.js and jquery.js.
2. after all, the method is same as `from release`

```shell
$ git clone ...
$ make download
$ browse gannt.html
```

### server mode
In server mode, `sample.csv` will be send automatically
and gannt chart show up immidiately.

```shell
$ git clone ...
$ make download
$ make launch
```


Limitation
---------------------
- drag) show extending bars -> modify svg.draggable.js.
- users cannot change the bar's orders from GUI, edit source csv by hand.


TODO
---------------------
### ver.1.0.0
- copy bar
- change default to title-field
- change order of bars


License
---------------------
MPL 2.0

<!-- vi: ft=markdown
  -->
