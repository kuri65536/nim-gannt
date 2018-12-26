Simple Gannt chart tool by nim
====================================

Prerequirement
---------------------
- browser: tested with Firefox 64.0
- optional: python3 for serving the files.


Installation
---------------------
open the gannt.html from a your web-browser.

then upload `sample.csv` from `upload` button.

### server mode
In server mode, `sample.csv` will be send automatically
and gannt chart show up immidiately.

```shell
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
- refresh with no reload
- change range with no reload
- copy bar
- change default to title-field


License
---------------------
MPL 2.0

<!-- vi: ft=markdown
  -->
