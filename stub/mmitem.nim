# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import jsffi

import d3stub
import svg_js_stub

from config import cfg


type
  MmItem* = ref object of JsObject  # {{{1
    idx*: int
    begin*: cstring
    fin* {.importc: "end".} : cstring
    text*: cstring
    beginstr*: cstring
    endstr*: cstring

var mi_items: seq[MmItem] = @[]


method index(self: MmItem): int {.base.} =  # {{{1
    # TODO: why method?
    return self.idx


proc mi_regist*(mi: MmItem): void =  # {{{1
        mi_items.add(mi)
        mi.idx = len(mi_items) - 1


proc mi_len*(): int =  # {{{1
        return len(mi_items)


proc mi_get*(n: int): MmItem =  # {{{1
        return mi_items[n]


proc mi_items_all*(): seq[MmItem] =  # {{{1
        return mi_items


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
                        text: cstring): MmItem {.discardable.} =
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
        if idx > 0:
            # TODO: specified index => change order...?
            # mi.idx = idx
            # mi_items_reorder...
            var TODO = 0

        var svg = SVG.select("svg").get(0).doc()
        var g = svg.group()
        discard g.id(idx_to_xmlid(idx))

        var x1 = cfg.sx.to(float(t1))
        var x2 = cfg.sx.to(float(t2))
        var y1 = cfg.sy.to(mi.idx)
        var y2 = cfg.sy.to(mi.idx + 1)
        var rc = g.rect(int(x2 - x1), int(y2 - y1))
        rc.attr("class", "mmitem-normal"
         ).x(int(x1)
         ).y(int(y1))

        SVG.select("#" & rc.id()).draggable()
        create_title(g, rc, text)


# end of file {{{1
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
