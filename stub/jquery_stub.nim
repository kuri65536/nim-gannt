import jsffi
import dom

import firefox_stub

type
  jQuerySelector* = ref object of RootObj
    dmy: int

  JQuery* = ref jQueryObj
  jQueryObj {.importc.} = ref object of RootObj
    ready*: cstring



{.push importcpp.}

proc off*(jq: jQuerySelector, ev_name: string): jQuerySelector
proc on*(jq: jQuerySelector, ev_name: string,
         cb: proc (ev: Event)): jQuerySelector

proc html*(jq: jQuerySelector): string
proc attr*(jq: jQuerySelector, name: string, src: string): jQuerySelector
proc append*(jq: jQuerySelector, src: jQuerySelector): jQuerySelector
proc `[]`*(jq: jQuerySelector, i: int): Element

proc jq*(selector: string): jQuerySelector
{.pop.}

proc jqwhen*(jq: JQuery, src: cstring): JsPromise
    {.importcpp: "when" .}

var jQuery* {.importc, nodecl.}: JQuery

# vi: ft=nim:et:sw=4:tw=80:nowrap
