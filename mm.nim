# import macros
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

  MM = ref object of RootObj  # {{{1
    items: seq[MmItem]
    target_item: MmItem


var mi_index = 0
var mi_items: seq[MmItem] = @[]

proc color(self: MmItem): cstring =
    return "#00F"

method index(self: MmItem): int {.base.} =
    mi_index = mi_index + 1
    return mi_index


proc atof(src: cstring): float {.importc: "parseFloat" .}  # {{{1

proc mi_begin(obj: JsObject): float =  # {{{1
    return atof(((MmItem)obj).begin)

proc mi_end(self: JsObject): float =  # {{{1
    return atof(MmItem(self).fin)

proc mi_span(self: JsObject, sx: D3Scale): string =  # {{{1
    var ed = sx.to(self.mi_end())
    var bg = sx.to(self.mi_begin())
    return $int(ed - bg)

proc mi_create(dat: JsObject): float =  # {{{1
        var item = MmItem()
        mi_items.add(item)
        var n = item.index()
        ((MmItem)dat).idx = n
        return 1.0

proc rect_black(rect: SvgRect, msg: cstring): void =  # {{{1
        discard rect.fill("none").stroke("#000", 2, 1.0)
        if msg == "":
            return
        console.debug(msg & ": " & $(rect.x()) & "," & $(rect.y()) &
                      "-" & $(rect.width()) & "," & $(rect.height()))


proc on_csv_xaxis(xmin: float, xmax: float, sx: D3Scale): void =  # {{{1
        var svg = SVG.select("svg").get(0).doc()
        var x1 = sx.to(xmin)
        var x2 = sx.to(xmax)
        var bbox = svg.rect(int(x2 - x1), 50)
        discard bbox.x(int(x1)).y(0)
        rect_black(bbox, "xaxis: bbox")

proc on_csv_yaxis(min: float, max: float, sc: D3Scale): void =  # {{{1
        var svg = SVG.select("svg").get(0).doc()
        var y1 = sc.to(min)
        var y2 = sc.to(max)
        var bbox = svg.rect(200, int(y2 - y1))
        discard bbox.x(0).y(50)
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

        # x domain
        var minx = d3.min(dat, mi_begin)
        var maxx = d3.max(dat, mi_end)
        var dom = [minx, maxx]
        var rng = [200.0, 1000.0]
        var sx = d3.scaleLinear().domain(dom).range(rng)

        # create x-axis ruler
        on_csv_xaxis(minx, maxx, sx)

        # y domain
        dom = [0.0, (float)len(dat)]
        rng = [50.0, 500.0]
        var sy = d3.scaleLinear().domain(dom).range(rng)

        # create y-axis ruler
        on_csv_yaxis(dom[0], dom[1], sy)

        # create rectangles
        var svg = d3.select("svg")
        var rect = svg.selectAll("rect"
          ).data(dat
          ).enter().append("rect"
          ).attr("height", proc (x: JsObject): cstring = $(sy.to(mi_create(x)))
          ).attr("width", proc (x: JsObject): cstring = ((MmItem)x).mi_span(sx)
          ).attr("x", proc (x: JsObject): cstring =
                 $(sx.to(((MmItem)x).mi_begin()))
          ).attr("y", proc (x: JsObject): cstring = $(sy.to(((MmItem)x).idx))
          ).attr("fill", proc (x: JsObject): cstring = ((MmItem)x).color()
          )

        # make bars draggable
        var rects = SVG.select("rect").draggable()

        # enable save button
        var jqc = jq("#save").off("click").on("click", on_save)

proc on_init(ev: Event): void =  # {{{1
        var d3c = d3.csv("./gannt-d3.csv").then(on_csv)

        # var svg = d3.select("svg")
        # d3c = svg.group
        #         ).attr("class", "x axis")

# main {{{1
var pm = jQuery.jqwhen(jQuery.ready).then(on_init)
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
