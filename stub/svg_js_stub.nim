type
  SvgJs* = ref SvgJsObj
  SvgJsObj {.importc.} = object of RootObj
    dmy: int
  SvgSet* = ref object of RootObj
  SvgParent* = ref object of RootObj
  SvgElement* {.importc.} = ref object of RootObj
  SvgRect* {.importc.} = ref object of SvgElement

{.push importcpp.}

proc select*(svg: SvgJs, tag: cstring): SvgSet
proc get*(svg: SvgSet, n: int): SvgElement
proc doc*(svg: SvgElement): SvgParent
proc rect*(svg: SvgParent, w: int, h: int): SvgRect

proc fill*(svg: SvgElement, src: cstring): SvgElement
proc x*(svg: SvgRect, x: int): SvgRect
proc y*(svg: SvgRect, y: int): SvgRect
proc x*(svg: SvgRect): int
proc y*(svg: SvgRect): int
proc width*(svg: SvgRect): int
proc height*(svg: SvgRect): int

# svg.draggable.js
proc draggable*(tags: SvgSet): SvgSet

{.pop.}

proc stroke*(svg: SvgElement, col: cstring,
             w: int): SvgElement {.importcpp: "#.stroke({color: #, width: #})".}
proc stroke*(svg: SvgElement, col: cstring, w: int,
             op: float): SvgElement {.importcpp: "#.stroke({color: #, width: #, opacity: #})".}

var SVG* {.importc, nodecl.}: SvgJs

# vi: ft=nim:et:sw=4:tw=80:nowrap
