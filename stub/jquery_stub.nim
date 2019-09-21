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
  jQueryPosition* = ref object of RootObj
    top*: int

  JQuery* = ref jQueryObj
  jQueryObj {.importc.} = object of RootObj
    ready*: cstring

  CallbackNone* = proc()
  CallbackAjax* = proc(data, stat: cstring, jqXHR: JsObject)
  CallbackEvent1* = proc(ev: Event): bool
  CallbackEvent2* = proc(ev: Event, cb: CallbackNone): bool
  JsDeferred* = ref object of RootObj


{.push importcpp.}

proc off*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc off*(jq: jQuerySelector, ev_name: cstring): jQuerySelector {.discardable.}
proc on*(jq: jQuerySelector, ev_name: cstring,
         cb: CallbackEvent1): jQuerySelector {.discardable.}
proc on*(jq: jQuerySelector, ev_name: cstring,
         cb: CallbackEvent2): jQuerySelector {.discardable.}

proc html*(jq: jQuerySelector): cstring
proc html*(jq: jQuerySelector, val: cstring): jQuerySelector {.discardable.}
proc text*(jq: jQuerySelector): cstring
proc text*(jq: jQuerySelector, val: cstring): jQuerySelector {.discardable.}
proc attr*(jq: jQuerySelector, name: cstring): cstring
proc prop*(jq: jQuerySelector, name: cstring): cstring
proc children*(jq: jQuerySelector,
               sel: cstring): seq[Node] {.discardable.}
proc parents*(jq: jQuerySelector,
              sel: cstring): jQuerySelector {.discardable.}
proc siblings*(jq: jQuerySelector,
               sel: cstring): jQuerySelector {.discardable.}
proc next*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc val*(jq: jQuerySelector): cstring
proc val*(jq: jQuerySelector, newval: cstring): jQuerySelector {.discardable.}
proc val*(jq: jQuerySelector, newval: int): jQuerySelector {.discardable.}
proc attr*(jq: jQuerySelector,
           name: cstring, src: cstring): jQuerySelector {.discardable.}
proc filter*(jq: jQuerySelector,
             name: cstring): jQuerySelector {.discardable.}
proc prop*(jq: jQuerySelector,
           name: cstring, src: cstring): jQuerySelector {.discardable.}
proc prop*(jq: jQuerySelector,
           name: cstring, src: int): jQuerySelector {.discardable.}
proc data*(jq: jQuerySelector, name: cstring): cstring
proc data*(jq: jQuerySelector,
           name, value: cstring): jQuerySelector {.discardable.}
proc removeData*(jq: jQuerySelector, name: cstring
                 ): jQuerySelector {.discardable.}
proc removeAttr*(jq: jQuerySelector, name: cstring
                 ): jQuerySelector {.discardable.}
proc position*(jq: jQuerySelector): jQueryPosition
proc append*(jq: jQuerySelector,
             src: jQuerySelector): jQuerySelector {.discardable.}
proc append*(jq: jQuerySelector, src: cstring): jQuerySelector {.discardable.}
proc prepend*(jq: jQuerySelector,
              src: cstring): jQuerySelector {.discardable.}
proc prepend*(jq: jQuerySelector,
              src: jQuerySelector): jQuerySelector {.discardable.}
proc remove*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc remove*(jq: jQuerySelector, sel: cstring): jQuerySelector {.discardable.}
proc clone*(jq: jQuerySelector): jQuerySelector
proc clone*(jq: jQuerySelector, with_event: bool): jQuerySelector
proc empty*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc parent*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc focus*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc submit*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc submit*(jq: jQuerySelector, fn: proc(): bool): jQuerySelector {.discardable.}
proc trigger*(jq: jQuerySelector, evname: cstring): jQuerySelector {.discardable.}
proc trigger*(jq: jQuerySelector, evname: cstring,
              cb: CallbackNone): jQuerySelector {.discardable.}
proc select*(jq: jQuerySelector): jQuerySelector {.discardable.}
proc serialize*(jq: jQuerySelector): cstring

proc css*(jq: jQuerySelector,
          name: cstring, value: cstring): jQuerySelector {.discardable.}
proc css*(jq: jQuerySelector, name: cstring): cstring
proc animate*(jq: jQuerySelector,
              params: JsObject,
              msec: int, value: cstring): jQuerySelector {.discardable.}
proc addClass*(jq: jQuerySelector,
               cls: cstring): jQuerySelector {.discardable.}
proc removeClass*(jq: jQuerySelector,
                  cls: cstring): jQuerySelector {.discardable.}
proc toggleClass*(jq: jQuerySelector,
                  cls: cstring): jQuerySelector {.discardable.}

proc param*(jq: JQuery, src: cstring): cstring
proc Deferred*(jq: JQuery): JsDeferred
proc resolve*(jq: JsDeferred): JsDeferred
proc reject*(jq: JsDeferred): JsDeferred
proc promise*(jq: JsDeferred): JsPromise

proc parseHTML*(jq: JQuery, data: cstring): seq[Node]
{.pop.}

proc len*(jq: jQuerySelector): int {.importcpp: "#.length" .}
proc `[]`*(jq: jQuerySelector, i: int): Element {.importcpp: "#[#]" .}

proc prop_bool*(jq: jQuerySelector,
                name: cstring): bool {.importcpp: "#.prop(#)".}

proc jq*(doc: Document): jQuerySelector {.importc: "jQuery", nodecl.}
proc jq*(nod: Node): jQuerySelector {.importc: "jQuery", nodecl.}
proc jq*(nodes: seq[Node]): jQuerySelector {.importc: "jQuery", nodecl.}
proc jq*(selector: cstring): jQuerySelector {.importc: "jQuery", nodecl.}
proc jq*(selector: cstring,
         sel: Node): jQuerySelector {.importc: "jQuery", nodecl.}
proc jq*(selector: cstring,
         sel: jQuerySelector): jQuerySelector {.importc: "jQuery", nodecl.}
proc jq_iter*(selector: cstring): seq[Node] {.importc: "jQuery", nodecl.}
proc jq_this*(): jQuerySelector {.importcpp: "jQuery(this)", nodecl.}
proc jq_window*(): jQuerySelector {.importcpp: "jQuery(window)", nodecl.}
proc jq_each*(selector: cstring,
              cb: proc()): void {.importcpp: "jQuery(#).each(#)", nodecl.}


proc jqwhen*(jq: JQuery, src: cstring): JsPromise
    {.importcpp: "when" .}

var jQuery* {.importc, nodecl.}: JQuery

{.push importcpp.}
proc ajax*(jq: JQuery, url: cstring): JsPromise
proc ajax*(jq: JQuery, prm: JsObject): JsPromise

{.pop.}

# vi: ft=nim:et:sw=4:tw=80:nowrap
