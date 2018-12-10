type
  SvgJs* = ref SvgJsObj
  SvgJsObj {.importc.} = object of RootObj
    dmy: int
  SvgElement* {.importc.} = ref object of RootObj
  SvgSet* = ref object of RootObj
  SvgParent* = ref object of SvgElement
  SvgRect* {.importc.} = ref object of SvgElement
  SvgLine* {.importc.} = ref object of SvgElement

{.push importcpp.}

proc select*(svg: SvgJs, tag: cstring): SvgSet
proc get*(svg: SvgSet, n: int): SvgElement
proc doc*(svg: SvgElement): SvgParent
proc group*(svg: SvgParent): SvgParent
proc rect*(svg: SvgParent, w: int, h: int): SvgRect
proc line*(svg: SvgParent, x: int, y: int, w: int, h: int): SvgLine

proc fill*(svg: SvgElement, src: cstring): SvgElement
proc x*(svg: SvgElement, x: int): SvgElement
proc y*(svg: SvgElement, y: int): SvgElement
proc x*(svg: SvgElement): int
proc y*(svg: SvgElement): int
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
