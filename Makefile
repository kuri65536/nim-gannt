svgdjs:=raw/1848b5cac801e0e75eb1b9846542ce29c333d8e4

ifeq (,min)
    svgjs:=svg.min.js
    svgdjs:=$(svgdjs)/dist/svg.draggable.min.js
    jquery:=jquery-2.1.4.min.js
    d3js:=d3.min.js
else
    svgjs:=svg.js
    svgdjs:=$(svgdjs)/dist/svg.draggable.js
    jquery:=jquery-2.1.4.js
    d3js:=d3.js
endif

ifeq (,windows)
	browse=start
else
	browse=browse
endif

server:=python
ifeq ($(server),python)
    server:=python3 -m http.server 8000
else
    error1:
		echo ???
		exit 1
endif

build: .download nimcache/gannt.js

launch: nimcache/gannt.js .download
	$(browse) http://localhost:8000/gannt.html
	$(server)

nimcache/gannt.js: *.nim stub/*.nim
	nim js -p:stub gannt.nim

fetch:
	cp orig/nim/*.nim stub
	cp orig/nim/gannt.html .
	cp orig/nim/gannt.nim .

download: .download

.download:
	wget https://code.jquery.com//$(jquery) \
	    -O jquery.js
	wget https://cdnjs.cloudflare.com/ajax/libs/svg.js/2.7.1/$(svgjs) \
	    -O svg.js
	wget https://github.com/svgdotjs/svg.draggable.js/$(svgdjs) \
	    -O svg.draggable.js
	wget http://code.jquery.com/$(jquery) -O jquery.js
	touch .download

deploy:
	zip -gur nim-gannt.zip *.nim stub

deploy_full:
	zip -gur nim-gannt.zip .git *.nim stub

