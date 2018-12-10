type
  SvgJs* = ref SvgJsObj
  SvgJsObj {.importc.} = object of RootObj
    dmy: int
  SvgSelector* = ref object of RootObj

{.push importcpp.}

proc select*(svg: SvgJs, tag: cstring): SvgSelector

# svg.draggable.js
proc draggable*(tags: SvgSelector): SvgSelector

{.pop.}

var SVG* {.importc, nodecl.}: SvgJs

# vi: ft=nim:et:sw=4:tw=80:nowrap
