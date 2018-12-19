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

{.push importcpp.}

proc select*(svg: SvgJs, tag: cstring): SvgSet
proc get*(svg: SvgSet, n: int): SvgElement
proc doc*(svg: SvgElement): SvgParent
proc defs*(svg: SvgParent): SvgParent
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
proc width*(svg: SvgRect): int
proc height*(svg: SvgRect): int
proc radius*(svg: SvgRect, r: int): SvgRect {.discardable.}

proc size*(svg: SvgText, siz: int): SvgText


# svg.draggable.js
proc draggable*(tags: SvgSet): SvgSet {.discardable.}
proc draggable*(tags: SvgSet, constraint: JsObject): SvgSet {.discardable.}
proc draggable*(tags: SvgSet,
                cb: proc(el: Element, x, y: int, m: JsObject): JsObject
                ): SvgSet {.discardable.}

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
            cb: proc(ev: Event): bool): SvgSet {.
              importcpp: "on", discardable.}

var SVG* {.importc, nodecl.}: SvgJs

# vi: ft=nim:et:sw=4:tw=80:nowrap
