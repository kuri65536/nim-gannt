# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import jsffi
import dom

import firefox_stub

type
  jQuerySelector* = ref object of RootObj
    dmy: int

  JQuery* = ref jQueryObj
  jQueryObj {.importc.} = object of RootObj
    ready*: cstring



{.push importcpp.}

proc off*(jq: jQuerySelector, ev_name: cstring): jQuerySelector
proc on*(jq: jQuerySelector, ev_name: cstring,
         cb: proc (ev: Event)): jQuerySelector

proc html*(jq: jQuerySelector): cstring
proc attr*(jq: jQuerySelector, name: cstring, src: cstring): jQuerySelector
proc append*(jq: jQuerySelector, src: jQuerySelector): jQuerySelector

{.pop.}

proc `[]`*(jq: jQuerySelector, i: int): Element {.importcpp: "#[#]" .}

proc jq*(selector: cstring): jQuerySelector {.importc: "jQuery", nodecl.}

proc jqwhen*(jq: JQuery, src: cstring): JsPromise
    {.importcpp: "when" .}

var jQuery* {.importc, nodecl.}: JQuery

# vi: ft=nim:et:sw=4:tw=80:nowrap
