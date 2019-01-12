# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import times
import strutils
import system

import jsffi

import jquery_stub
import svg_js_stub

# own libraries.
import logging
import common
from config import cfg


type
  GntBar* = ref object of RootObj  # {{{1
    group*: cstring
    file*: cstring
    idx*: int
    begin*: float
    fin*: float
    text*: cstring
    beginstr*: cstring
    endstr*: cstring
    misc*: cstring

  GntStone* = object of RootObj  # {{{1
    idx: int
    at_or_on*: float
    title*: cstring

var gnt_bars: seq[GntBar] = @[]
var mi_stones: seq[GntStone] = @[]


proc atof*(src: cstring): float {.importc: "parseFloat" .}  # {{{1


proc mi_regist*(mi: GntBar): void =  # {{{1
        gnt_bars.add(mi)
        mi.idx = len(gnt_bars)  # idx=0 for milestones.
        debg("mi_regist: " & $(len(gnt_bars)))


proc mi_len*(): int =  # {{{1
        return len(gnt_bars)


proc mi_get*(n: int): GntBar =  # {{{1
        return gnt_bars[n]


proc class_to_group*(cname: cstring): int =  # {{{1
        var name = ""
        for i in split($(cname)):
            if not i.startsWith("bar-"):
                continue
            # name = substr(i, 4, len(i) - 1)  # same as bellow.
            name = i[4 .. ^1]
        return int(atof(name))


proc xmlid_to_idx*(src: cstring): int =  # {{{1
        var xmlid = $(src)
        return int(atof(xmlid.split("-")[1]))

proc rect_to_idx*(rc: SvgRect): int =  # {{{1
        var g = rc.parent()
        var id = g.id()
        # remove "gntbar-" from "gntbar-100"
        var ret = xmlid_to_idx(id)
        info("rect_to_idx: " & rc.id() & "->" & $(ret) & "(" & id)
        return ret


proc xmlid*(item: GntBar): cstring =  # {{{1
        return (cstring)("gntbar-" & $(item.idx))


proc bars_get_all_seq*(): seq[GntBar] =  # {{{1
        return gnt_bars


proc mi_items_clear*(): void =  # {{{1
        gnt_bars = @[]


proc move_to_idx*(self: GntBar, n: int): void =  # {{{1
        # var bars = gnt_bars  # this make copy of seq -> no effect.
        var i = n - 1                     # idx=0 for milestones
        var j = self.idx - 1
        gnt_bars.delete(j)                # idx=0 for milestones
        info("move " & $(j) & " element to " & $(i))
        if i < 1:                         # idx=0 for milestones
            i = 0
            gnt_bars.insert(self, 0)
        elif i < len(gnt_bars):
            gnt_bars.insert(self, i)      # idx=0 for milestones
        else:
            i = len(gnt_bars) - 1
            gnt_bars.add(self)
        self.idx = i + 1


proc mi_begin*(item: GntBar): float =  # {{{1
    if cfg.mode_from_dtstring:
        var dt = times.parse($(item.beginstr), $(cfg.fmt_dtstring))
        debg("mi_begin:dt:" & dt.format("yyyy-MM-dd"))
        return dt.toTime().toSeconds()
    return item.begin


proc mi_end*(item: GntBar): float =  # {{{1
    if cfg.mode_from_dtstring:
        var dt = times.parse($(item.endstr), $(cfg.fmt_dtstring))
        debg("mi_end:dt:" & dt.format("yyyy-MM-dd"))
        return dt.toTime().toSeconds()
    return item.fin


proc format*(self: GntBar): cstring =  # {{{1
    var dat = self.group
    dat &= ",sample.txt,"
    dat &= $(self.idx) & ","
    dat &= int(self.begin).intToStr(9) & ","
    dat &= int(self.fin).intToStr(9) & ","
    dat &= self.beginstr & "," & self.endstr & "," & self.text
    dat &= "\n"
    return dat


proc fetch_from_rect*(self: GntBar,  # {{{1
                      r: SvgRect): GntBar {.discardable.} =
    const fmt = "yyyy/MM/dd HH:mm:ss"
    debg("update rect: " & $(r.x) & "," & $(r.width()))
    var x1 = cfg.rx.to(r.x)
    var x2 = cfg.rx.to(r.x + r.width())
    debg("update rect: " & $(x1) & "," & $(x2))
    var d1 = times.getLocalTime(times.fromSeconds(x1))
    var d2 = times.getLocalTime(times.fromSeconds(x2))
    self.begin = x1
    self.fin = x2
    self.beginstr = d1.format(fmt)
    self.endstr = d2.format(fmt)
    return self


proc xmlid*(self: GntStone): cstring =  # {{{1
        return "stone-" & $(self.idx)


proc initBar*(): GntBar =  # {{{1
        result = new(GntBar)


proc newBar*(row: string): GntBar =  # {{{1
        var obj = new(GntBar)
        var col = 0
        for cell in ajax_text_split_cols(row):
            col += 1
            case col
            of 1:
                obj.group = cell
            of 2:
                obj.file = cell
            of 3:
                obj.idx = int(atof(cell))
            of 4:
                obj.begin = atof(cell)
            of 5:
                obj.fin = atof(cell)
            of 6:
                obj.beginstr = cell
            of 7:
                obj.endstr = cell
            of 8:
                obj.text = cell
            else:
                obj.misc = cell
        if col >= 8:
            return obj
        return nil


proc copyBar*(id: cstring): GntBar =  # {{{1
        var obj = new(GntBar)

        var cname = jq("#" & id & " rect").attr("class")
        var name = cstring($(class_to_group(cname)))

        obj.file = "gui"
        obj.group = name
        obj.text = jq("#" & id & " text").text()
        obj.idx = 0

        var rc = SVG.select("#" & id & " rect").get(0)
        obj.fetch_from_rect(SvgRect(rc))
        return obj


proc initBar_from_rect*(rc: SvgRect): GntBar =  # {{{1
        let bars = gnt_bars
        var n = rect_to_idx(rc) - 1
        if n < 0:
            n = 0
        elif n >= len(bars):
            n = len(bars) - 1
        return bars[n]


proc idx_to_xmlid(n: int): cstring =  # {{{1
        return (cstring)("gntbar-" & $(n))


proc create_title(g: SvgParent, r: SvgElement, t: cstring): void =  # {{{1
            var t = g.text(t)
            case cfg.mode_title
            of 1:
                t.x(r.x).y(r.y)
            of 2:
                t.x(r.x + SvgRect(r).width).y(r.y)
            else:
                t.x(0).y(r.y)


proc regist_as_bar*(mi: GntBar): GntBar {.discardable.} =
        # create
        # <g>
        #   <rect> <text>
        # </g>

        # if len(t1) < 1:
        #     debg("new_bar: title text is not specified.")
        #     return
        mi.mi_regist()
        var idx = mi.idx
        var cls = mi.group
        var text = mi.text
        if idx < 0:
            # TODO: specified index => change order...?
            # mi.idx = idx
            # mi_items_reorder...
            var TODO = 0

        var svg = SVG.select("svg").get(0).doc()
        var g = svg.group()
        discard g.id(idx_to_xmlid(idx))

        var t1 = mi.mi_begin()
        var t2 = mi.mi_end()
        var x1 = cfg.sx.to(t1)
        var x2 = cfg.sx.to(t2)
        var w = int(x2 - x1)
        if w < 1:
            w = 1
        var y1 = cfg.sy.to(mi.idx)
        var y2 = cfg.sy.to(mi.idx + 1)
        var rc = g.rect(w, int(y2 - y1) - 2 * cfg.H2)
        rc.radius(cfg.H3
         ).x(int(x1)
         ).y(int(y1) + cfg.H2
         ).cls("bars bar-" & cls)

        create_title(g, rc, text)


proc regist_as_milestone*(mi: GntBar): GntStone {.discardable.} =  # {{{1
        # create object
        var ret = GntStone()
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
        t.x(x + cfg.W1).y(y)
        var p = g.path("M" & $(x) & " " & $(y + cfg.H4))
        var mk = SvgMarker(SVG.select("#marker-2").get(0))
        discard p.marker("start", mk)
        return ret


proc min_from*(dat: seq[GntBar],
               chooser: proc(src: GntBar): float): float =  # {{{1
    var cur = Inf
    for obj in dat:
        var v = chooser(obj)
        if v < cur:
            cur = v
    return cur


proc max_from*(dat: seq[GntBar],
               chooser: proc(src: GntBar): float): float =  # {{{1
    var cur = NegInf
    for obj in dat:
        var v = chooser(obj)
        if v > cur:
            cur = v
    return cur


# end of file {{{1
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
