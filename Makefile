svgdjs:=raw/1848b5cac801e0e75eb1b9846542ce29c333d8e4

ifeq (,min)
    svgjs:=svg.min.js
    svgdjs:=$(svgdjs)/dist/svg.draggable.min.js
    jquery:=jquery-2.1.4.min.js
else
    svgjs:=svg.js
    svgdjs:=$(svgdjs)/dist/svg.draggable.js
    jquery:=jquery-2.1.4.js
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
	$(browse) http://localhost:8000/gannt.html?file=./sample.csv
	$(server)

nimcache/gannt.js: *.nim stub/*.nim
	nim js -p:stub gannt.nim

download: .download

.download:
	wget https://cdnjs.cloudflare.com/ajax/libs/svg.js/2.7.1/$(svgjs) \
	    -O svg.js
	wget https://github.com/svgdotjs/svg.draggable.js/$(svgdjs) \
	    -O svg.draggable.js
	wget http://code.jquery.com/$(jquery) -O jquery.js
	touch .download

ver:=$(shell git tag | grep v.* | sort | tail -n1)
hash:=$(shell git log -n1 --pretty=%h)

demo: jq:=$(subst /,\/,https://code.jquery.com/$(jquery))
demo: svg:=$(subst /,\/,https://cdnjs.cloudflare.com/ajax/libs/svg.js/2.7.1/$(svgjs))
demo: svgd:=$(subst /,\/,https://github.com/svgdotjs/svg.draggable.js/$(svgdjs))
demo: nimcache/gannt.js
	# echo debug: $(jq)
	cat gannt.html \
	| sed 's/src="jquery.js/src="$(jq)/' \
	| sed 's/src="svg.js/src="$(svg)/' \
	| sed 's/src="svg.draggable.js/src="$(svgd)/' \
	| sed 's/src="nimcache\/gannt.js/src="gannt.js/' > live.html
	@echo update gannt.js by: `ln nimcache/gannt.js .; git add gannt.js`

src_deploy:=*.nim stub Makefile README.md
deploy:
	zip -gur nim-gannt-$(ver)-$(hash).zip $(src_deploy)

deploy_full:
	zip -gur nim-gannt-$(ver)-$(hash).zip .git $(src_deploy)

