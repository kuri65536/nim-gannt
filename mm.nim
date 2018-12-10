# import macros
import jsffi
import dom

import firefox_stub
import jquery_stub
import d3stub
import svg_js_stub

# from jsutils import jq, Event, Location

# import SVG  # stub


type
  MmItem = ref object of JsObject  # {{{1
    begin: int
    fin: int

  MM = ref object of RootObj  # {{{1
    items: seq[MmItem]
    target_item: MmItem


var mi_index = 0
var mi_items: seq[MmItem] = @[]

proc color(self: MmItem): string =
    return "#00F"

method index(self: MmItem): int {.base.} =
    mi_index = mi_index + 1
    return mi_index


proc mi_begin(obj: JsObject): float =  # {{{1
    return float(MmItem(obj).begin)

proc mi_end(self: JsObject): float =  # {{{1
    return float(MmItem(self).fin)

proc mi_span(self: JsObject, sx: D3Scale): string =  # {{{1
    var ed = sx.to(self.mi_end())
    var bg = sx.to(self.mi_begin())
    return $int(ed - bg)

proc mi_create(dat: JsObject): string =  # {{{1
        var item = MmItem()
        mi_items.add(item)
        return $1

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
        var minx = d3.min(dat, mi_begin)
        var maxx = d3.max(dat, mi_end)
        var dom: array[0..1, float] = [minx, maxx]
        var rng: array[0..1, float] = [200.0, 1000.0]
        var sx = d3.scaleLinear().domain(dom).range(rng)
        dom = [0.0, (float)len(dat)]
        rng = [0.0, 300.0]
        var sy = d3.scaleLinear().domain(dom).range(rng)

        var svg = d3.select("svg")
        var rect = svg.selectAll("rect"
          ).data(dat
          ).enter().append("rect"
          ).attr("height", mi_create
          ).attr("width", proc (x: JsObject): string = x.mi_span(sx)
          ).attr("x", proc (x: JsObject): string = $(sx.to(x.mi_begin()))
          ).attr("y", proc (x: JsObject): string = $(sy.to(mi_index))
          ).attr("fill", proc (x: JsObject): string = MmItem(x).color()
          )

        var rects = SVG.select("rect").draggable()
        var node = document.createAttribute("abc")

        var jqc = jq("#save").off("click").on("click", on_save)

proc on_init(ev: Event): void =  # {{{1
        var d3c = d3.csv("../gannt-d3.csv").then(on_csv)

method on_load(self: MM, data: JSObject): void {.base.} =  # {{{1
        var svg = d3.select("svg")
        var d3c = svg.append("g"
                    ).attr("class", "x axis")

# main {{{1
var pm = jQuery.jqwhen(jQuery.ready).then(on_init)
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
