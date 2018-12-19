# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import times

import jsffi
import jsconsole

import d3stub
import svg_js_stub

# own libraries.
from config import cfg


type
  MmItem* = ref object of JsObject  # {{{1
    group*: cstring
    idx*: int
    begin*: cstring
    fin* {.importc: "end".} : cstring
    text*: cstring
    beginstr*: cstring
    endstr*: cstring

  MmStone* = object of RootObj  # {{{1
    idx: int
    at_or_on*: float
    title*: cstring

var mi_items: seq[MmItem] = @[]
var mi_stones: seq[MmStone] = @[]


proc atof*(src: cstring): float {.importc: "parseFloat" .}  # {{{1


method index(self: MmItem): int {.base.} =  # {{{1
    # TODO: why method?
    return self.idx


proc mi_regist*(mi: MmItem): void =  # {{{1
        mi_items.add(mi)
        var n = 0
        if len(mi_stones) > 0:
            n = 1
        mi.idx = n + len(mi_items) - 1
        # console.debug("mi_regist: " & $(len(mi_items)))


proc mi_len*(): int =  # {{{1
        return len(mi_items)


proc mi_get*(n: int): MmItem =  # {{{1
        return mi_items[n]


proc mi_items_all*(): seq[MmItem] =  # {{{1
        return mi_items


proc mi_begin*(obj: JsObject): float =  # {{{1
    var item = (MmItem)obj
    if cfg.mode_from_dtstring:
        var dt = times.parse($(item.beginstr), $(cfg.fmt_dtstring))
        # console.debug("mi_begin:dt:" & dt.format("yyyy-MM-dd"))
        return dt.toTime().toSeconds()
    return atof(item.begin)


proc xmlid*(self: MmStone): cstring =  # {{{1
        return "stone-" & $(self.idx)


proc initMmItem*(): MmItem =  # {{{1
        result = MmItem(newJsObject())
        mi_regist(result)


proc idx_to_xmlid(n: int): cstring =  # {{{1
        return (cstring)("mmitem-" & $(n))


proc create_title(g: SvgParent, r: SvgElement, t: cstring): void =  # {{{1
            var t = g.text(t)
            case cfg.mode_title
            of 1:
                t.x(r.x).y(r.y)
            of 2:
                t.x(r.x + SvgRect(r).width).y(r.y)
            else:
                t.x(0).y(r.y)


proc create_new_mmitem*(t1, t2, idx: int,  # {{{1
                        text: cstring, cls: cstring): MmItem {.discardable.} =
        # <g>
        #   <rect> <text>
        # </g>

        # if len(t1) < 1:
        #     console.debug("new_bar: title text is not specified.")
        #     return
        var mi = initMmItem()
        mi.begin = $(t1)
        mi.fin = $(t2)
        mi.text = text
        var newidx = mi.idx
        if idx > 0:
            # TODO: specified index => change order...?
            # mi.idx = idx
            # mi_items_reorder...
            var TODO = 0

        var svg = SVG.select("svg").get(0).doc()
        var g = svg.group()
        discard g.id(idx_to_xmlid(newidx))

        var x1 = cfg.sx.to(float(t1))
        var x2 = cfg.sx.to(float(t2))
        var w = int(x2 - x1)
        if w < 1 and t1 < t2:
            w = 1
        var y1 = cfg.sy.to(mi.idx)
        var y2 = cfg.sy.to(mi.idx + 1)
        var rc = g.rect(w, int(y2 - y1) - 4)
        rc.radius(2
         ).x(int(x1)
         ).y(int(y1) + 2
         ).cls("bars bar-" & cls)

        create_title(g, rc, text)


proc create_new_milestone*(mi: MmItem): MmStone {.discardable.} =  # {{{1
        # create object
        var ret = MmStone()
        ret.title = mi.text
        ret.at_or_on = mi_begin(mi)
        mi_stones.add(ret)
        ret.idx = len(mi_stones) - 1

        # draw mile-stones
        var svg = SVG.select("svg").get(0).doc()
        var g = svg.group()
        discard g.id(ret.xmlid())
        var x = int(cfg.sx.to(ret.at_or_on))
        var y = int(cfg.sy.to(0))
        var t = g.text(ret.title)
        t.x(x + 10).y(y)
        var p = g.path("M" & $(x) & " " & $(y + 10))
        var mk = SvgMarker(SVG.select("#marker-2").get(0))
        discard p.marker("start", mk)
        return ret

# end of file {{{1
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
