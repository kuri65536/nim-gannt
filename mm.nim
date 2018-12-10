# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# import macros
import times

import jsffi
import jsconsole
import dom

import firefox_stub
import jquery_stub
import d3stub
import svg_js_stub


type
  MmItem = ref object of JsObject  # {{{1
    idx: int
    begin: cstring
    fin {.importc: "end".} : cstring
    text: cstring

  MM = ref object of RootObj  # {{{1
    items: seq[MmItem]
    target_item: MmItem

  Config = object of RootObj  # {{{1
    X1: float
    Y1: float
    X2: float
    Y2: float
    sx: D3Scale
    sy: D3Scale
    mode_xrange: int
    mode_title: int
    mode_q1jan: bool

  tuple_xaxis = tuple[siz: int, nam: cstring, pos: int]

var cfg = Config(X1: 200.0, Y1: 50.0, X2: 1000.0, Y2: 500.0,
                 mode_xrange: 0, mode_title: 1, mode_q1jan: false)
var mi_index = 0
var mi_items: seq[MmItem] = @[]

proc color(self: MmItem): cstring =
    return "#00F"

method index(self: MmItem): int {.base.} =
    mi_index = mi_index + 1
    self.idx = mi_index
    return mi_index


proc atof(src: cstring): float {.importc: "parseFloat" .}  # {{{1

proc mi_begin(obj: JsObject): float =  # {{{1
    var item = (MmItem)obj
    return atof(item.begin)

proc mi_begin2(self: JsObject): cstring =  # {{{1
    var x = cfg.sx.to(self.mi_begin())
    return $(x)

proc mi_end(self: JsObject): float =  # {{{1
    var item = (MmItem)self
    return atof(item.fin)

proc mi_end2(self: JsObject): cstring =  # {{{1
    var x = cfg.sx.to(self.mi_end())
    return $(x)

proc mi_span(self: JsObject): cstring =  # {{{1
    var ed = cfg.sx.to(self.mi_end())
    var bg = cfg.sx.to(self.mi_begin())
    var ret = ed - bg
    if ret < 1.0:
        ret = 1.0
    return $int(ret)

proc mi_y(obj: JsObject): cstring =  # {{{1
    var item = (MmItem)obj
    var y = cfg.sy.to(item.idx - 1)
    return $(y)

proc mi_create(dat: JsObject): cstring =  # {{{1
        var item = (MmItem)dat
        mi_items.add(item)
        var n = item.index()
        return $(cfg.sy.to((float)n) - cfg.sy.to((float)(n - 1)))

proc mi_xmlid(dat: JsObject): cstring =  # {{{1
        var item = (MmItem)dat
        return (cstring)("mmitem-" & $(item.idx))

proc xaxis_month_1st(x1: float, x2: float): cstring =  # {{{1
    if true:
        var d1 = times.getLocalTime(times.fromSeconds((int64)x1))
        var d2 = times.getLocalTime(times.fromSeconds((int64)x2))
        # console.debug("new:" & d2.format("yyyy-MM-dd"))
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

proc week_search(x: int, dir: float): tuple[x: float, name: cstring] =  # {{{1
        var d = times.getLocalTime(times.fromSeconds((int64)x))
        d.second = 0
        d.minute = 0
        d.hour = 0
        if dir > 0:
            var n = 6 - d.weekday.ord + 7 * int(dir)
            d = d + times.initInterval(0, 0, 0, 0, n, 0, 0)
        else:
            console.debug("w-srch: %d-%s-%s", d.weekday.ord, $(d.weekday), d.format("yyyy-MM-dd"))
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
        console.debug("w-tick: %d-%d-%d", ti.months, ti.days, ti.hours)
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
        var sc = d3.scaleLinear(
                  ).domain([min, max]).range([cfg.X1, cfg.X2])
        cfg.sx = sc
        var x = min
        var d1pct = (max - min) * 0.01
        var cur = week_search(int(x), -0.1)
        var (sx, nn) = xaxis_week_subtick(d1pct)
        var px = -5 * sx
        var n = nn + 1
        cur.name = ""
        console.debug("w-axis-step: %.2f-%d", sx, nn)
        while x < max:
            var nxt = week_search(int(x), -0.1)
            var nx = sc.to(x)
            x = x + sx
            n += 1
            console.debug("w-axis: %d-%d", n, sc.to(x))
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
        console.debug("tick: " & $(ti.days))
        if ti.days > 13:
            return (x: 14.0 * 24 * 60 * 60, n: 2)
        if ti.days > 2:
            ti = times.initInterval(0, 0, 0, 0, 7, 0, 0)
            return (x: 7.0 * 24 * 60 * 60, n: 4)
        if ti.days > 0 and ti.hours > 11:
            return (x: 2.0 * 24 * 60 * 60, n: 4)
        return (x: 24.0 * 60 * 60, n: 28)


iterator xaxis_month(min: float, max: float): tuple_xaxis =  # {{{1
        var sc = d3.scaleLinear(
                  ).domain([min, max]).range([cfg.X1, cfg.X2])
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
        console.debug("q-tick: %d-%d-%d", ti.months, ti.days, ti.hours)
        if ti.months > 0:
            return (x: 30.0 * 24 * 60 * 60, n: 5)
        if ti.days > 9:
            return (x: 14.0 * 24 * 60 * 60, n: 4)
        return (x: 7.0 * 24 * 60 * 60, n: 4)


iterator xaxis_quater(min: float, max: float): tuple_xaxis =  # {{{1
        var sc = d3.scaleLinear(
                  ).domain([min, max]).range([cfg.X1, cfg.X2])
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

iterator xaxis_percent_month(min: float, max: float): tuple_xaxis =  # {{{1
        var sc = cfg.sx
        var px = 0.0
        var x = min
        var sx = (max - min) * 0.01
        var nn = 5
        while x < max:
            var nx = sc.to(x)
            var name = xaxis_month_1st(px, x)
            var siz = 2
            px = x
            if name != "":
                siz = 1
                nn += 1
            if nn < 5:
                name = ""
            else:
                nn = 0
            x += sx
            var tup: tuple_xaxis = (siz: siz, nam: name, pos: (int)nx)
            yield tup


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
            for i in xaxis_percent_month(min, max):
                yield i


proc rect_black(rect: SvgRect, msg: cstring): void =  # {{{1
        discard rect.fill("none").stroke("#000", 2, 1.0)
        if msg == "":
            return
        console.debug(msg & ": " & $(rect.x()) & "," & $(rect.y()) &
                      "-" & $(rect.width()) & "," & $(rect.height()))


proc on_csv_xaxis(min: float, max: float): void =  # {{{1
        var svg = SVG.select("svg").get(0).doc()
        var bbox = svg.rect(int(cfg.X2 - cfg.X1), (int)cfg.Y1)
        discard bbox.x(int(cfg.X1)).y(0)
        rect_black(bbox, "xaxis: bbox")

        var px = 0
        var ga = svg.group()
        var g = ga.group()
        var gs = ga.group()
        var gt = ga.group()
        for tup in xaxis_iter(min, max):
            # console.debug("x-iter: " & $(tup.pos))
            px = tup.pos
            if tup.siz == 1:
                var y1 = 0
                if len(tup.nam) < 1:
                    y1 = 14
                discard g.line(px, y1, px, int(cfg.Y1))
                discard g.line(px, int(cfg.Y1), px, int(cfg.Y2))
            if tup.siz == 2:
                discard g.line(px, 20, px, int(cfg.Y1))
                discard gs.line(px, int(cfg.Y1) + 1, px, int(cfg.Y2))
            if len(tup.nam) > 0:
                discard gt.text(tup.nam).size(10).x(px + 2).y(0)
        discard g.stroke("#000", 2, 1.0)
        discard gs.stroke("#999", 1, 1.0)

proc on_csv_yaxis(min: float, max: float, sc: D3Scale): void =  # {{{1
        var svg = SVG.select("svg").get(0).doc()
        var y1 = sc.to(min)
        var y2 = sc.to(max)
        var bbox = svg.rect(199, int(y2 - y1))
        discard bbox.x(0).y((int)cfg.Y1)
        rect_black(bbox, "yaxis: bbox")

proc on_save(ev: Event): void =  # {{{1
        var dat = jq("#root").html()  # SVG
        dat = "<svg>" & dat & "</svg>"
        var anc = jq("<a style=\"display: none;\" />")
        var opt = newJsAssoc[string, string]()
        opt["type"] = "data:attachment/text"
        var blob = newBlob([dat], opt)
        var url = window.URL.createObjectURL(blob)
        # console.log(url)
        var chn = anc.attr("href", url
                    ).attr("download", "download.svg")
        chn = jq("body").append(anc)
        anc[0].click()
        window.URL.revokeObjectURL(url)
        # a.remove()

        # # do as LocalStorage
        # ls = LocalStorage()  # type: ignore
        # ls.blob = dat
        # ls.mime = "data/quoted-printable"
        # Location.href = ls.addr

proc on_csv(dat: seq[JsObject]): void =  # {{{1
        console.debug("inst:" & $(len(dat)))
        mi_index = 0

        # x domain, create x-axis ruler
        var minx = d3.min(dat, mi_begin)
        var maxx = d3.max(dat, mi_end)
        on_csv_xaxis(minx, maxx)

        # y domain
        var dom = [0.0, (cfg.Y2 - cfg.Y1) / 20.0]  # (float)len(dat)]
        var rng = [cfg.Y1, cfg.Y2]
        var sy = d3.scaleLinear().domain(dom).range(rng)
        cfg.sy = sy

        # create y-axis ruler
        on_csv_yaxis(dom[0], dom[1], sy)

        # create rectangles
        var svg = d3.select("svg")
        svg.selectAll("rect"
          ).data(dat
          ).enter().append("rect"
          ).attr("height", mi_create
          ).attr("width", mi_span
          ).attr("x", mi_begin2
          ).attr("y", mi_y
          ).attr("id", mi_xmlid
          ).attr("fill", proc (x: JsObject): cstring = ((MmItem)x).color()
          )

        var g = SVG.select("svg").get(0).doc()
        for i in mi_items:
            var t = g.text(i.text)
            # make bars draggable
            var r = SVG.select("rect#" & mi_xmlid(i))
            r.draggable()
            case cfg.mode_title
            of 1:
                t.x(r.get(0).x).y(r.get(0).y)
            of 2:
                t.x(r.get(0).x + SvgRect(r.get(0)).width).y(r.get(0).y)
            else:
                t.x(0).y(r.get(0).y)

        # all rects to draggable
        # var rects = SVG.select("rect").draggable()


proc on_refresh(ev: Event): void =  # {{{1
        var loc = window.location
        var url = loc.protocol & cstring("//") & loc.host & loc.pathname
        var xrange = jq("#xrange").val()
        var title = jq("#title").val()
        window.location.href = url & "?xrange=" & xrange & "&title=" & title


proc on_init(ev: Event): void =  # {{{1
        var url = initURL(window.location.href)
        var xrange = url.searchParams.get("xrange")
        if xrange != nil:
            cfg.mode_xrange = int(atof(xrange))
        var title = url.searchParams.get("title")
        if title != nil:
            cfg.mode_title = int(atof(title))

        jq("#xrange").off("change").on("change", on_refresh)
        jq("#title").off("change").on("change", on_refresh)
        jq("#save").off("click").on("click", on_save)
        jq("#refresh").off("click").on("click", on_refresh)

        var d3c = d3.csv("./gannt-d3.csv").then(on_csv)

        # var svg = d3.select("svg")
        # d3c = svg.group
        #         ).attr("class", "x axis")

# main {{{1
var pm = jQuery.jqwhen(jQuery.ready).then(on_init)
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
