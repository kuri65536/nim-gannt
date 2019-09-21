Simple Gannt chart tool by nim
====================================

Prerequirement
---------------------
- browser: tested with Firefox 68.0.1
- optional: compile with nim 0.19.4
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


Demonstaration
---------------------
[demo](http://kuri65536.github.com/nim-gannt/live.html?file=sample.csv)

![demo image](https://user-images.githubusercontent.com/11357613/51353406-e7cf2c00-1af3-11e9-9b85-82aabc9e4f0a.png)


Limitation
---------------------
- drag) show extending bars -> modify svg.draggable.js.


TODO
---------------------
see [sample.csv](http://kuri65536.github.com/nim-gannt/live.html?file=sample.csv)


Donations
---------------------
If you are feel to nice for this software, please donation to my

-   Bitcoin **| 1FTBAUaVdeGG9EPsGMD5j2SW8QHNc5HzjT |**
-   or Ether **| 0xd7Dc5cd13BD7636664D6bf0Ee8424CFaF6b2FA8f |** .


License
---------------------
MPL 2.0

<!-- vi: ft=markdown
  -->
