# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# import macros
import times
import strutils

import jsffi
import dom

# special stub files from me.
import firefox_stub
import jquery_stub
import svg_js_stub

# own libraries.
import logging
import markers
import common
from config import cfg
import bars


type
  MM = ref object of RootObj  # {{{1
    items: seq[MmItem]
    target_item: MmItem

  tuple_xaxis = tuple[siz: int, nam: cstring, pos: int]  # {{{1

  fn_event = (proc(ev: Event) {.nimcall.})  # {{{1
  # - o .nimcall.
  # - x .closure.

# {{{1
var mi_index = 0
var drag_mode = 0
var drag_x = 0
var drag_y = 0


proc color(self: MmItem): cstring =
    return "#00F"


proc mi_begin2(self: JsObject): cstring =  # {{{1
    var x = cfg.sx.to(self.mi_begin())
    return $(x)

proc mi_end(self: JsObject): float =  # {{{1
    var item = (MmItem)self
    if cfg.mode_from_dtstring:
        var dt = times.parse($(item.endstr), $(cfg.fmt_dtstring))
        debg("mi_end:dt:" & dt.format("yyyy-MM-dd"))
        return dt.toTime().toSeconds()
    return atof(item.fin)

proc mi_end2(self: JsObject): cstring =  # {{{1
    var x = cfg.sx.to(self.mi_end())
    return $(x)

proc mi_span(self: JsObject): cstring =  # {{{1
    var ed = cfg.sx.to(self.mi_end())
    var bg = cfg.sx.to(self.mi_begin())
    debg("mi_span: " & $(bg) & "," & $(ed))
    var ret = ed - bg
    if ret < 1.0:
        ret = 1.0
    return $int(ret)

proc mi_y(obj: JsObject): cstring =  # {{{1
    var item = (MmItem)obj
    var y = cfg.sy.to(item.idx)
    return $(y)

proc mi_height(dat: JsObject): cstring =  # {{{1
        var item = (MmItem)dat
        debg("mi_create: " & $(item.idx))
        var n = item.idx
        return $(cfg.sy.to(float(n + 1)) - cfg.sy.to(float(n)))


proc mi_create(dat: JsObject): MmItem {.discardable.} =  # {{{1
        var item = (MmItem)dat
        mi_regist(item)
        debg("mi_create: " & $(item.idx))
        return item


proc mi_xmlid(dat: JsObject): cstring =  # {{{1
        var item = (MmItem)dat
        return (cstring)("mmitem-" & $(item.idx))

proc mi_select(src: cstring): cstring =  # {{{1
        var xmlid = cstring("")
        if strutils.isDigit($(src)):
            var n = int(atof(src))
            if n >= mi_len():
                return ""
            var mi = mi_get(n)
            xmlid = mi.mi_xmlid()
        else:
            # test with jQuery, so SVG selector raise exception
            # if src is not valid XML id string.
            var sel = jq("#" & src)
            if len(sel) < 1:
                return ""
            xmlid = src
        return xmlid

proc xaxis_month_1st(x1: float, x2: float): cstring =  # {{{1
    if true:
        var d1 = times.getLocalTime(times.fromSeconds((int64)x1))
        var d2 = times.getLocalTime(times.fromSeconds((int64)x2))
        debg("new:" & d2.format("yyyy-MM-dd"))
        if d1.month == d2.month:
            return (cstring)""
        # return (cstring)($(d2.year) & "/" & $(d2.month))
        return (cstring)d2.format("yyyy/MM")
    # faster than pure/times.
    # else:
    #     var d1 = times.fromSeconds((int64)x1)
    #     var d2 = times.fromSeconds((int64)x2)
    #     var m = d2.getMonth()
    #     if m == d1.getMonth():
    #         return (cstring)""
    #     return (cstring)($(d2.getYear()) & "/" & $(m + 1))


proc day_search(x: int, dir: float): tuple[x: float, name: cstring] =  # {{{1
        var d = times.getLocalTime(times.fromSeconds((int64)x))
        d.second = 0
        d.minute = 0
        d.hour = 0
        if dir > 0:
            d = d + times.initInterval(0, 0, 0, 0, 1, 0, 0)
            d = d - times.initInterval(0, 2, 0, 0, 0, 0, 0)
        var n: cstring
        if d.monthday == 1:
            n = d.format("mm")
        else:
            n = d.format("d")
        return (x: d.toTime().toSeconds(), name: n)


proc xaxis_day_subtick(w: float): tuple[x: float, n: int] =  # {{{1
        var ti = times.initInterval(0, int(w), 0, 0, 0, 0, 0)
        # debg("w-tick: %d-%d-%d", ti.months, ti.days, ti.hours)
        if ti.months > 0:
            return (x: 30.0 * 24 * 60 * 60, n: 10)
        if ti.days > 6:
            return (x: 7.0 * 24 * 60 * 60, n: 20)
        if ti.days > 2:
            return (x: 3.0 * 24 * 60 * 60, n: 6)
        if ti.days > 1:
            return (x: 2.0 * 24 * 60 * 60, n: 4)
        if ti.hours > 11:
            return (x: 1.0 * 24 * 60 * 60, n: 14)
        return (x: 1.0 * 24 * 60 * 60, n: 7)


iterator xaxis_day(min: float, max: float): tuple_xaxis =  # {{{1
        var sc = initScaleLinear(
                  ).domain([min, max]).range([cfg.X1, cfg.X2])
        cfg.rx = initScaleLinear(
                  ).domain([cfg.X1, cfg.X2]).range([min, max])
        cfg.sx = sc
        var x = min
        var d1pct = (max - min) * 0.01
        var cur = day_search(int(x), -0.1)
        var (sx, nn) = xaxis_day_subtick(d1pct)
        var px = -5 * sx
        var n = nn + 1
        cur.name = ""
        # debg("w-axis-step: %.2f-%d", sx, nn)
        while x < max:
            var nxt = day_search(int(x), -0.1)
            var nx = sc.to(x)
            x = x + sx
            n += 1
            # debg("w-axis: %d-%d", n, sc.to(x))
            if n < nn or nxt.name == cur.name:  # sub-tick
                var tup: tuple_xaxis = (siz: 2, nam: (cstring)"", pos: int(nx))
                yield tup
                continue

            n = 0
            cur = nxt
            var name = cur.name
            if cur.x - px < 5 * d1pct:
                name = ""
            else:
                px = cur.x
            var tup: tuple_xaxis = (siz: 1, nam: name, pos: int(nx))
            yield tup

proc week_search(x: int, dir: float): tuple[x: float, name: cstring] =  # {{{1
        var d = times.getLocalTime(times.fromSeconds((int64)x))
        d.second = 0
        d.minute = 0
        d.hour = 0
        if dir > 0:
            var n = 6 - d.weekday.ord + 7 * int(dir)
            d = d + times.initInterval(0, 0, 0, 0, n, 0, 0)
        else:
            # debg("w-srch: %d-%s-%s", d.weekday.ord, $(d.weekday), d.format("yyyy-MM-dd"))
            d = d - times.initInterval(0, 0, 0, 0, d.weekday.ord, 0, 0)
        var w = (d.yearday div 7) + 1
        var n: cstring
        if w < 10:
            n = "w0" & $(w)
        else:
            n = "w" & $(w)
        n = cstring(d.format("yyyy") & n)
        return (x: d.toTime().toSeconds(), name: n)


proc xaxis_week_subtick(w: float): tuple[x: float, n: int] =  # {{{1
        var ti = times.initInterval(0, int(w), 0, 0, 0, 0, 0)
        # debg("w-tick: %d-%d-%d", ti.months, ti.days, ti.hours)
        if ti.months > 0:
            return (x: 30.0 * 24 * 60 * 60, n: 10)
        if ti.days > 6:
            return (x: 7.0 * 24 * 60 * 60, n: 20)
        if ti.days > 2:
            return (x: 3.0 * 24 * 60 * 60, n: 6)
        if ti.days > 1:
            return (x: 2.0 * 24 * 60 * 60, n: 4)
        if ti.hours > 11:
            return (x: 1.0 * 24 * 60 * 60, n: 14)
        return (x: 1.0 * 24 * 60 * 60, n: 7)


iterator xaxis_week(min: float, max: float): tuple_xaxis =  # {{{1
        var sc = initScaleLinear(
                  ).domain([min, max]).range([cfg.X1, cfg.X2])
        cfg.rx = initScaleLinear(
                  ).domain([cfg.X1, cfg.X2]).range([min, max])
        cfg.sx = sc
        var x = min
        var d1pct = (max - min) * 0.01
        var cur = week_search(int(x), -0.1)
        var (sx, nn) = xaxis_week_subtick(d1pct)
        var px = -5 * sx
        var n = nn + 1
        cur.name = ""
        # debg("w-axis-step: %.2f-%d", sx, nn)
        while x < max:
            var nxt = week_search(int(x), -0.1)
            var nx = sc.to(x)
            x = x + sx
            n += 1
            # debg("w-axis: %d-%d", n, sc.to(x))
            if n < nn or nxt.name == cur.name:  # sub-tick
                var tup: tuple_xaxis = (siz: 2, nam: (cstring)"", pos: int(nx))
                yield tup
                continue

            n = 0
            cur = nxt
            var name = cur.name
            if cur.x - px < 5 * d1pct:
                name = ""
            else:
                px = cur.x
            var tup: tuple_xaxis = (siz: 1, nam: name, pos: int(nx))
            yield tup

proc month_search(x: int, dir: float): tuple[x: float, name: cstring] =  # {{{1
        var d = times.getLocalTime(times.fromSeconds((int64)x))
        d.second = 0
        d.minute = 0
        d.hour = 0
        if dir > 0:
            d.monthday = 27
            d = d + times.initInterval(0, 0, 0, 0, 7, int(dir), 0)
            d.monthday = 1
            d = d - times.initInterval(0, 0, 0, 0, 1, 0, 0)
        else:
            d.monthday = 1
            # d = d - times.initInterval(0, 0, 0, 0, 1, 0, 0)
        var n = cstring(d.format("yyyy/MM"))
        return (x: d.toTime().toSeconds(), name: n)


proc xaxis_month_subtick(w: float): tuple[x: float, n: int] =  # {{{1
        var ti = times.initInterval(0, int(w), 0, 0, 0, 0, 0)
        debg("tick: " & $(ti.days))
        if ti.days > 13:
            return (x: 14.0 * 24 * 60 * 60, n: 2)
        if ti.days > 2:
            ti = times.initInterval(0, 0, 0, 0, 7, 0, 0)
            return (x: 7.0 * 24 * 60 * 60, n: 4)
        if ti.days > 0 and ti.hours > 11:
            return (x: 2.0 * 24 * 60 * 60, n: 4)
        return (x: 24.0 * 60 * 60, n: 28)


iterator xaxis_month(min: float, max: float): tuple_xaxis =  # {{{1
        var sc = initScaleLinear(
                  ).domain([min, max]).range([cfg.X1, cfg.X2])
        cfg.rx = initScaleLinear(
                  ).domain([cfg.X1, cfg.X2]).range([min, max])
        cfg.sx = sc
        var x = min
        var d1pct = (max - min) * 0.01
        var px = 0.0
        var n = 0
        var cur = month_search(int(x), -0.1)
        var (sx, nn) = xaxis_month_subtick(d1pct)
        while x < max:
            x = x + sx
            var nxt = month_search(int(x), -0.1)
            n += 1
            if n < nn:  # sub-tick
                var nx = sc.to(x)
                var tup: tuple_xaxis = (siz: 2, nam: (cstring)"", pos: int(nx))
                yield tup
            if nxt.name == cur.name:
                var nx = sc.to(x)
                var tup: tuple_xaxis = (siz: 2, nam: (cstring)"", pos: int(nx))
                yield tup

            n = 0
            cur = nxt
            var nx = sc.to(cur.x)
            var name = cur.name
            if cur.x - px < 5 * d1pct:
                name = ""
            else:
                px = cur.x
            var tup: tuple_xaxis = (siz: 1, nam: name, pos: int(nx))
            yield tup

proc quater_search(x: int, dir: float): tuple[x: float, name: cstring] =  # {{{1
        var d = times.getLocalTime(times.fromSeconds((int64)x))
        d.second = 0
        d.minute = 0
        d.hour = 0
        d.monthday = 1

        # 1-12(0-11) -> 0-3 -> 1, 4, 7, 10
        var i = d.month.ord div 3
        d.month = Month(1 + i * 3)

        if dir > 0:
            d = d + times.initInterval(0, 0, 0, 0, 0, 3 * int(dir) + 1, 0)
            d = d - times.initInterval(0, 0, 0, 0, 1, 0, 0)

        var n: cstring
        if cfg.mode_q1jan:
            n = cstring(d.format("yyyy") & "Q" & $(i + 1))
        elif i < 1:
            n = cstring($(d.year - 1) & "Q4")
        else:
            n = cstring(d.format("yyyy") & "Q" & $(i))
        return (x: d.toTime().toSeconds(), name: n)


proc xaxis_quater_subtick(w: float): tuple[x: float, n: int] =  # {{{1
        var ti = times.initInterval(0, int(w), 0, 0, 0, 0, 0)
        # debg("q-tick: %d-%d-%d", ti.months, ti.days, ti.hours)
        if ti.months > 0:
            return (x: 30.0 * 24 * 60 * 60, n: 5)
        if ti.days > 9:
            return (x: 14.0 * 24 * 60 * 60, n: 4)
        return (x: 7.0 * 24 * 60 * 60, n: 4)


iterator xaxis_quater(min: float, max: float): tuple_xaxis =  # {{{1
        var sc = initScaleLinear(
                  ).domain([min, max]).range([cfg.X1, cfg.X2])
        cfg.rx = initScaleLinear(
                  ).domain([cfg.X1, cfg.X2]).range([min, max])
        cfg.sx = sc
        var x = min
        var d1pct = (max - min) * 0.01
        var px = 0.0
        var n = 0
        var cur = quater_search(int(x), -0.1)
        var (sx, nn) = xaxis_quater_subtick(d1pct)
        while x < max:
            x = x + sx
            var nxt = quater_search(int(x), -0.1)
            n += 1
            if n < nn:  # sub-tick
                var nx = sc.to(x)
                var tup: tuple_xaxis = (siz: 2, nam: (cstring)"", pos: int(nx))
                yield tup
            if nxt.name == cur.name:
                var nx = sc.to(x)
                var tup: tuple_xaxis = (siz: 2, nam: (cstring)"", pos: int(nx))
                yield tup

            n = 0
            cur = nxt
            var nx = sc.to(cur.x)
            var name = cur.name
            if cur.x - px < 5 * d1pct:
                name = ""
            else:
                px = cur.x
            var tup: tuple_xaxis = (siz: 1, nam: name, pos: int(nx))
            yield tup


iterator xaxis_auto_range(min: float, max: float): tuple_xaxis =  # {{{1
        var rng = max - min
        # if rng < 7 * 24 * 60 * 60:          # in week
        #
        if rng < 30 * 24 * 60 * 60:         # in month -> days
            for i in xaxis_day(min, max):
                yield i
        elif rng < 6 * 30 * 24 * 60 * 60:   # in quater or half -> weeks
            for i in xaxis_week(min, max):
                yield i
        elif rng < 2 * 365 * 24 * 60 * 60:  # 2years -> month
            for i in xaxis_month(min, max):
                yield i


iterator xaxis_iter(min: float, max: float): tuple_xaxis =  # {{{1
        var x1, x2: float
        var dmy: cstring
        var typ = cfg.mode_xrange div 100
        var spn = cfg.mode_xrange mod 100
        case typ
        of 1:  # week
            if spn == 0:
                (x1, x2) = (max, 0.1)
            else:
                (x1, x2) = (min, float(spn) * 4.0 - 0.1)
            (x2, dmy) = week_search(int(x1), x2)
            (x1, dmy) = week_search(int(min), -0.1)
            for i in xaxis_week(x1, x2):
                yield i
        of 2:  # month
            if spn == 0:
                (x1, x2) = (max, 0.1)
            else:
                (x1, x2) = (min, float(spn) - 0.1)
            (x2, dmy) = month_search(int(x1), x2)
            (x1, dmy) = month_search(int(min), -0.1)
            for i in xaxis_month(x1, x2):
                yield i
        of 3:  # quater
            if spn == 0:
                (x1, x2) = (max, 0.1)
            else:
                (x1, x2) = (min, float(spn div 3) - 0.1)
            (x2, dmy) = quater_search(int(x1), x2)
            (x1, dmy) = quater_search(int(min), -0.1)
            for i in xaxis_quater(x1, x2):
                yield i
        else:
            for i in xaxis_auto_range(min, max):
                yield i


proc rect_black(rect: SvgRect, msg: cstring): void =  # {{{1
        discard rect.fill("none").stroke("#000", 2, 1.0)
        if msg == "":
            return
        debg($(msg) & ": " & $(rect.x()) & "," & $(rect.y()) &
             "-" & $(rect.width()) & "," & $(rect.height()))


proc on_csv_xaxis(min: float, max: float): void =  # {{{1
        var svg = SVG.select("svg").get(0).doc()
        var bbox = svg.rect(int(cfg.X2 - cfg.X1), (int)cfg.Y1)
        discard bbox.x(int(cfg.X1)).y(0)
        rect_black(bbox, "xaxis: bbox")

        var n = 0
        var px = 0
        var ga = svg.group()
        var g = ga.group()
        var gs = ga.group()
        var gt = ga.group()
        for tup in xaxis_iter(min, max):
            debg("x-iter: " & $(tup.pos))
            px = tup.pos
            n += 1
            var ns = $(n)
            if tup.siz == 1:
                var y1 = 0
                if len(tup.nam) < 1:
                    y1 = 14
                g.line(px, y1, px, int(cfg.Y1)).id("t1-" & ns).cls("xtick1")
                g.line(px, int(cfg.Y1), px, int(cfg.Y2)
                ).id("t2-" & ns).cls("xtick2")
            if tup.siz == 2:
                g.line(px, 20, px, int(cfg.Y1)).id("s1-" & $(n)
                ).cls("xtick-sub1")
                gs.line(px, int(cfg.Y1) + 1, px, int(cfg.Y2)
                 ).id("s2-" & $(n)).cls("xtick-sub2")
            if len(tup.nam) > 0:
                discard gt.text(tup.nam).size(10).x(px + 2).y(0)
        g.stroke("#000", 2, 1.0).id("xtics")
        gs.id("xtics-sub")
        ga.id("xaxis")


proc on_csv_yaxis(min: float, max: float, sc: D3Scale): void =  # {{{1
        var svg = SVG.select("svg").get(0).doc()
        var y1 = sc.to(min)
        var y2 = sc.to(max)
        var bbox = svg.rect(199, int(y2 - y1))
        discard bbox.x(0).y((int)cfg.Y1)
        rect_black(bbox, "yaxis: bbox")


proc on_drag_limit_y(el: Element, x, y: int, m: JsObject): JsObject =  # {{{1
        # m: transformation matrix
        var ret = newJsObject()
        ret.x = true
        return ret


proc on_drag_before(ev: SvgEvent): bool =  # {{{1
        var svg = SVG.select("svg").get(0).doc()
        var m = svg.screenCTM()
        var rc = ev.originalTarget.getBBox()
        var x = int(ev.detail.event.pageX) - int(m.e)
        var y = int(ev.detail.event.pageY) - int(m.f)
        var msg = "-" & $(rc.x)

        drag_x = rc.x
        drag_y = rc.y
        if float(x - rc.x) < rc.width / 5:
            debg("left:" & $(ev.detail.event.pageX) & msg)
            drag_mode = 1
        elif float(x - rc.x) > rc.width * 4 / 5:
            debg("right:" & $(ev.detail.event.pageX) & msg)
            drag_mode = 2
        else:
            debg("center:" & $(ev.detail.event.pageX) & msg)
            drag_mode = 0



proc on_drag_finish(ev: SvgEvent): bool =  # {{{1
        var rc = SvgRect(SVG.select("#" & ev.originalTarget.id).get(0))
        var x = rc.x()
        case drag_mode:
        of 1:  # left
            if x < drag_x:
                var w = int(drag_x) - x + rc.width()
                rc.width(w)
                debg("left<:" & $(rc.width))
            else:
                var w = rc.width() - (x - int(drag_x))
                if w < 0:
                    rc.x(int(drag_x))
                    debg("left0:" & $(rc.x()))
                else:
                    rc.width(w)
                    debg("left>:" & $(rc.width()))
        of 2:  # right
            if x > drag_x:
                var w = x - int(drag_x) + rc.width()
                rc.x(drag_x)
                rc.width(w)
                debg("rigt>:" & $(rc.width))
            else:
                var w = rc.width() - (int(drag_x) - x)
                if w < 0:
                    rc.x(drag_x)
                    rc.x(int(drag_x))
                    debg("rigt0:" & $(rc.x()))
                else:
                    rc.x(drag_x)
                    rc.width(w)
                    debg("rigt<:" & $(rc.width()))
        else:  # move
            # nothing
            debg("abc")


proc on_save_core(dat: cstring, ext: cstring): void =  # {{{1
        var anc = jq("<a style=\"display: none;\" />")
        var opt = newJsAssoc[string, string]()
        opt["type"] = "data:attachment/text"
        var blob = newBlob([dat], opt)
        var url = window.URL.createObjectURL(blob)
        warn(url)
        var chn = anc.attr("href", url
                    ).attr("download", "download." & ext)
        chn = jq("body").append(anc)
        anc[0].click()
        window.URL.revokeObjectURL(url)
        # a.remove()

        # # do as LocalStorage
        # ls = LocalStorage()  # type: ignore
        # ls.blob = dat
        # ls.mime = "data/quoted-printable"
        # Location.href = ls.addr

proc on_save(ev: Event): void =  # {{{1
        var dat = jq("#root").html()  # SVG
        dat = cstring("<svg>") & dat & cstring("</svg>")
        on_save_core(dat, "svg")

proc on_save_csv(ev: Event): void =  # {{{1
        const fmt = "yyyy/MM/dd hh:mm:ss"
        var dat: cstring = "prior,file,line,begin,end,beginstr,endstr,text\n"
        for i in mi_items_all():
            var r = SVG.select("rect#" & mi_xmlid(i)).get(0)
            var x1 = cfg.rx.to(r.x)
            var x2 = cfg.rx.to(r.x + SvgRect(r).width())
            var d1 = times.getLocalTime(times.fromSeconds(x1))
            var d2 = times.getLocalTime(times.fromSeconds(x2))
            dat &= "1,sample.txt,  1," & int(x1).intToStr(9) & ","
            dat &= int(x2).intToStr(9) & ","
            dat &= d1.format(fmt) & "," & d2.format(fmt) & "," & i.text
            dat &= "\n"
        on_save_core(dat, "csv")


proc create_title(g: SvgParent, r: SvgElement, t: cstring): void =  # {{{1
            if r == nil:
                debg("title: skip with no rect..." & $(t))
                return
            var t = g.text(t)
            case cfg.mode_title
            of 1:
                t.x(r.x).y(r.y)
            of 2:
                t.x(r.x + SvgRect(r).width).y(r.y)
            else:
                t.x(0).y(r.y)


proc on_csv(dat: seq[JsObject]): void =  # {{{1
        debg("inst:" & $(len(dat)))
        mi_index = 0

        # x domain, create x-axis ruler
        var minx = min_from(dat, mi_begin)
        var maxx = max_from(dat, mi_end)
        on_csv_xaxis(minx, maxx)

        # y domain
        var dom = [0.0, (cfg.Y2 - cfg.Y1) / 20.0]  # (float)len(dat)]
        var rng = [cfg.Y1, cfg.Y2]
        var sy = initScaleLinear().domain(dom).range(rng)
        cfg.sy = sy

        # create y-axis ruler
        on_csv_yaxis(dom[0], dom[1], sy)

        # create tile-stones
        for i in dat:
            var mi = MmItem(i)
            if mi.group != "1":
                continue
            create_new_milestone(mi)

        # create rectangles
        for i in dat:
            var mi = MmItem(i)
            if mi.group == "1":
                continue
            var x1 = int(mi_begin(i))
            var x2 = int(mi_end(i))
            create_new_mmitem(x1, x2, -1, mi.text, mi.group)

        SVG.select("rect.bars"
          ).event("beforedrag.mm", on_drag_before
          ).event("dragend.mm", on_drag_finish
          ).draggable(on_drag_limit_y)

        # all rects to draggable
        # var rects = SVG.select("rect").draggable()


iterator ajax_text_split_cols(row: string): cstring =  # {{{1
        var f_quote = false
        var f_esc = false
        var col = 0
        var cell = ""
        debg("row..." & row)
        for c2 in row:
            if f_quote:
                if f_esc:
                    f_esc = false
                elif c2 == '\\':
                    f_esc = true
                    continue
                elif c2 == '"':
                    f_quote = false
                cell &= c2
                continue

            if f_esc:
                f_esc = false
            elif c2 == '"':
                f_quote = true
                continue
            elif c2 == '\\':
                f_esc = true
                continue
            elif c2 == ',':
                debg("cells..." & cell)
                yield cell
                col += 1
                cell = ""
                continue
            cell &= c2
        if len(cell) > 0:
            debg("cells..." & cell)
            yield cell


proc ajax_text(data, textStatus: cstring, jqXHR: JsObject): void =  # {{{1
        var f_first = true
        var dat: seq[JsObject] = @[]
        debg("ajax_text..." & data)
        for row in splitLines($(data)):
            debg("lines..." & $(len(dat)))
            if f_first:
                f_first = false
                continue
            var obj = newJsObject()
            var col = 0
            for cell in ajax_text_split_cols(row):
                col += 1
                case col
                of 1:
                    obj.group = cell
                of 2:
                    obj.file = cell
                of 3:
                    obj.idx = cell
                of 4:
                    obj.begin = cell
                of 5:
                    obj.fin = cell
                of 6:
                    obj.beginstr = cell
                of 7:
                    obj.endstr = cell
                of 8:
                    obj.text = cell
                else:
                    obj.misc = cell
            if col >= 8:
                dat.add(obj)
        on_csv(dat)


proc initMmItem(): MmItem =  # {{{1
        result = MmItem(newJsObject())
        mi_regist(result)
        discard result.index()


proc create_new_arrow_core(r1, r2: SvgRect): void =  # {{{1
        var x1 = int(r1.x() + r1.width())
        var x2 = int(r2.x())
        var y1 = int(r1.y() + int(r1.height() / 2))
        var y2 = int(r2.y() + int(r2.height() / 2))
        var svg = SVG.select("svg").get(0).doc()
        var lin = svg.line(x1, y1, x2, y2)

        # line style.
        var mk = SvgMarker(SVG.select("marker").get(0))
        discard lin.stroke("#000", 2, 1.0)
        discard lin.marker("end", mk)

        # TODO: register arrows to group
        # var arw = initMmArrow()


proc create_new_bar(t1, t2: cstring): void =  # {{{1
        if len(t1) < 1:
            debg("new_bar: title text is not specified.")
            return

        var s1 = int(cfg.rx.to((cfg.X2 + cfg.X1)/ 3))
        var s2 = int(cfg.rx.to((cfg.X2 + cfg.X1) / 2))
        create_new_mmitem(s1, s2, -1, t1, "2")


proc create_new_text(t1, t2: cstring): void =  # {{{1
        if len(t1) < 1:
            debg("new_txt: title text is not specified.")
            return
        var y = int(cfg.sy.to(mi_index))
        if len(t2) > 0:
            y = int(atof(t2))
        var svg = SVG.select("svg").get(0).doc()
        var txt = svg.text(t1)
        var x = 0
        discard txt.x(x).y(y)


proc create_new_arrow(t1, t2: cstring): void =  # {{{1
        if len(t1) < 1 or len(t2) < 1:
            debg("new_arw: IDs are not specified")
            return
        var id1 = mi_select(t1)
        var id2 = mi_select(t2)
        if len(id1) < 1:
            debg("new_arw: ID1 can not be found")
            return
        if len(id2) < 1:
            debg("new_arw: ID2 can not be found")
            return
        var r1 = SVG.select("#" & id1)
        var r2 = SVG.select("#" & id2)
        if len(id1) < 1 or len(id2) < 1:
            debg("new_arw: ")
            return
        create_new_arrow_core(SvgRect(r1.get(0)), SvgRect(r2.get(0)))


proc on_new_object(ev: Event): void =  # {{{1
        var sel = $(jq("#new_object").val())  # jq(ev).target()
        var t1 = jq("#new_text1").val()
        var t2 = jq("#new_text2").val()
        case sel
        of "bar":
            create_new_bar(t1, t2)
        of "text":
            create_new_text(t1, t2)
        of "arrow":
            create_new_arrow(t1, t2)
        # of "0":
        else:
            sel = ""
        discard jq("#new_object").val("0")


proc on_refresh(ev: Event): void =  # {{{1
        var loc = window.location
        var url = loc.protocol & cstring("//") & loc.host & loc.pathname
        var xrange = jq("#xrange").val()
        var title = jq("#title").val()
        window.location.href = url & "?xrange=" & xrange & "&title=" & title


proc on_cm_focus(ev: Event) =  # {{{1
        debg("on_cm_focus")

proc on_cm_newbar(ev: Event) =  # {{{1
        debg("on_cm_newbar")

iterator cm_menuitems_at(x, y: int  # {{{1
                         ): tuple[id, text: string, callback: fn_event] =
        var id_area = 0
        if x > int(cfg.X1):
            if y > int(cfg.Y1):
                id_area = 3
            else:
                id_area = 1
        elif y > int(cfg.Y1):
            id_area = 2
        case id_area
        of 1:
            yield (id: "cm_focus_xrange", text: "Change range",
                   callback: on_cm_focus)
            yield (id: "cm_focus_xmin", text: "Select start", callback: on_cm_focus)
            yield (id: "cm_focus_xmax", text: "Select end", callback: on_cm_focus)
        of 2:
            yield (id: "cm_newbar", text: "Create bar", callback: on_cm_newbar)
        of 3:
            yield (id: "cm_focus_xrange", text: "Change range", callback: on_cm_focus)
            yield (id: "cm_focus_title", text: "Edit text", callback: on_cm_focus)
            yield (id: "cm_newbar", text: "Create bar", callback: on_cm_newbar)
        else:
            yield (id: "cm_newbar", text: "Create bar", callback: on_cm_newbar)

proc on_contextmenu(ev: Event): void =  # {{{1
        ev.preventDefault()
        var x: int = ev.pageX
        var y: int = ev.pageY
        jq("#contextmenu").css("left", $(x - 10) & "px"
                         ).css("top", $(y - 10) & "px"
                         ).css("display", "block")
        jq("#contextmenu li").remove()
        var ul = jq("#contextmenu ul")
        for tup in cm_menuitems_at(x, y):
            # fetch menu on svg item...
            # display menu...
            # enable click events...
            ul.append("<li id=\"" & tup.id & "\">" & tup.text & "</li>")
            jq("#" & tup.id).off("click").on("click", tup.callback)


proc on_cm_leave(ev: Event): void =  # {{{1
        jq("#contextmenu").css("display", "none")


proc on_init(ev: Event): void =  # {{{1
        setLevel(cfg.log_level)
        cfg.mode_xrange = 0  # TODO: move to config.nim

        var url = initURL(window.location.href)
        var xrange = url.searchParams.get("xrange")
        if xrange != nil:
            cfg.mode_xrange = int(atof(xrange))
        var title = url.searchParams.get("title")
        if title != nil:
            cfg.mode_title = int(atof(title))

        jq(document).off("contextmenu").on("contextmenu", on_contextmenu)
        jq("#xrange").off("change").on("change", on_refresh)
        jq("#title").off("change").on("change", on_refresh)
        jq("#new_object").off("change").on("change", on_new_object)
        jq("#save").off("click").on("click", on_save)
        jq("#save_csv").off("click").on("click", on_save_csv)
        jq("#refresh").off("click").on("click", on_refresh)
        jq("#contextmenu").off("mouseout").on("mouseout", on_cm_leave)
        # jq("#contextmenu").off("onblur").on("onblur", on_cm_leave)

        var g = SVG.select("svg").get(0).doc()

        # create styles
        # TODO: CDATA section
        g.defs().element("style").words(
            "    .xtick-sub2 {\n" &
            "        stroke: #DDD;\n" &
            "        stroke-width: 2;\n" &
            "        stroke-opacity: 1.0;}\n" &
            "")

        # create markers
        var mk = g.marker(10, 10, marker_arrow)
        discard mk.id("marker-1")
        mk = g.marker(10, 10, marker_milestone)
        discard mk.id("marker-2")

        # load csv...
        discard jQuery.ajax("./gannt-d3.csv").then(ajax_text)

        # var svg = d3.select("svg")
        # d3c = svg.group
        #         ).attr("class", "x axis")

# main {{{1
var pm = jQuery.jqwhen(jQuery.ready).then(on_init)
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
