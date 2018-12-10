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

build:
	nim js -p:stub mm.nim

fetch:
	cp orig/nim/*.nim stub
	cp orig/nim/mm.nim .

download:
	wget https://cdnjs.cloudflare.com/ajax/libs/svg.js/2.7.1/$(svgjs) \
	    -O svg.js
	wget https://cdnjs.cloudflare.com/ajax/libs/svg.js/2.7.1/$(svgjs) \
	    -O svg.js
	wget https://github.com/svgdotjs/svg.draggable.js/$(svgdjs) \
	    -O svg.draggable.js
	wget https://github.com/d3/d3/releases/download/v5.7.0/d3.zip \
	    -O d3.zip
	wget http://code.jquery.com/$(jquery) -O jquery.js
	# jQuery Mobile
	unzip -o d3.zip $(d3js); (mv $(d3js) d3.js || echo)

