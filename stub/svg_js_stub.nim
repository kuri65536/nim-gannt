# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import jsffi
import dom

type
  SvgJs* = ref SvgJsObj
  SvgJsObj {.importc.} = object of RootObj
    dmy: int
  SvgElement* {.importc.} = ref object of RootObj
  SvgSet* = ref object of RootObj
  SvgParent* = ref object of SvgElement
  SvgRect* {.importc.} = ref object of SvgElement
  SvgLine* {.importc.} = ref object of SvgElement
  SvgPath* {.importc.} = ref object of SvgElement
  SvgText* {.importc.} = ref object of SvgElement
  SvgMarker* {.importc.} = ref object of SvgElement

  SvgTargetOrg* {.importc.} = ref object of RootObj
    id* {.importc.}: cstring

  SvgEvent* {.importc.} = ref object of JsObject
    originalTarget* {.importc.}: SvgTargetOrg
    detail* {.importc.}: SvgDetail

  SvgDetail* {.importc.} = ref object of JsObject
    event* {.importc.}: Event

  SvgRect2* {.importc.} = ref object of SvgElement
    x*, y*, width*, height*: int

  SvgMatrix* {.importc.} = ref object of RootObj
    a*, b*, c*, d*, e*, f*: float

{.push importcpp.}

proc select*(svg: SvgJs, tag: cstring): SvgSet

proc get*(svg: SvgSet, n: int): SvgElement
proc doc*(svg: SvgElement): SvgParent
proc defs*(svg: SvgParent): SvgParent
proc screenCTM*(svg: SvgParent): SvgMatrix

proc element*(svg: SvgParent, typ: cstring): SvgElement
proc group*(svg: SvgParent): SvgParent
proc rect*(svg: SvgParent, w: int, h: int): SvgRect
proc line*(svg: SvgParent, x: int, y: int, w: int, h: int): SvgLine
proc text*(svg: SvgParent, t: cstring): SvgText
proc path*(svg: SvgParent, t: cstring): SvgPath {.discardable.}
proc marker*(svg: SvgParent, vx: int, vy: int,
             figure: proc(cont: SvgParent)): SvgMarker {.discardable.}
proc marker*(svg: SvgElement,
             pos: cstring, mk: SvgMarker): SvgElement {.discardable.}

proc parent*(svg: SvgElement): SvgElement {.discardable.}
proc id*(svg: SvgElement, src: cstring): SvgElement {.discardable.}
proc id*(svg: SvgElement): cstring
proc attr*(svg: SvgElement, name, value: cstring): SvgElement
proc style*(svg: SvgElement, name, value: cstring): SvgElement
proc words*(svg: SvgElement, value: cstring): SvgElement {.discardable.}
proc fill*(svg: SvgElement, src: cstring): SvgElement
proc x*(svg: SvgElement, x: int): SvgElement {.discardable.}
proc y*(svg: SvgElement, y: int): SvgElement {.discardable.}
proc x*(svg: SvgElement): int
proc y*(svg: SvgElement): int
# proc getBBox*(svg: SvgElement): SvgRect2
proc clear*(svg: SvgElement): SvgElement {.discardable.}

proc width*(svg: SvgRect): int
proc width*(svg: SvgRect, w: int): SvgRect {.discardable.}
proc height*(svg: SvgRect): int
proc radius*(svg: SvgRect, r: int): SvgRect {.discardable.}

proc size*(svg: SvgText, siz: int): SvgText

proc getBBox*(svg: SvgTargetOrg): SvgRect2

proc off*(svg: SvgSet, name: cstring): SvgSet {.discardable.}

# svg.draggable.js
proc draggable*(tags: SvgSet): SvgSet {.discardable.}
proc draggable*(tags: SvgSet, constraint: JsObject): SvgSet {.discardable.}
proc draggable*(tags: SvgSet,
                cb: proc(el: Element, x, y: int, m: JsObject): JsObject
                ): SvgSet {.discardable.}

proc preventDefault*(ev: SvgEvent): void {.discardable.}  # {{{1

{.pop.}

proc stroke*(svg: SvgElement, col: cstring,
             w: int): SvgElement {.importcpp: "#.stroke({color: #, width: #})".}
proc stroke*(svg: SvgElement, col: cstring, w: int,
             op: float): SvgElement {.importcpp: "#.stroke({color: #, width: #, opacity: #})".}

proc len*(svg: SvgSet): int {.importcpp: "#.length()".}

proc cls*(svg: SvgElement,
          value: cstring): SvgElement {.
              importcpp: "#.attr(\"class\", #)",discardable.}

proc event*(svg: SvgSet, name: cstring,
            cb: proc(ev: SvgEvent): bool): SvgSet {.
              importcpp: "on", discardable.}

proc svg_from_node*(el: Node): SvgElement {.importcpp: "#".}

var SVG* {.importc, nodecl.}: SvgJs

# vi: ft=nim:et:sw=4:tw=80:nowrap
