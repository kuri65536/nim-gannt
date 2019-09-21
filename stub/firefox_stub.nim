# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import jsffi
import dom

import macros

type
  Blob* = ref BlobObj
  BlobObj = object of RootObj

  UrlSearchParams* = ref RootObj
  UrlStub* = ref UrlObj
  UrlObj = object of RootObj
    searchParams*: UrlSearchParams

  JsonClass* = ref object of RootObj
  JsPromise* = ref object of RootObj
  JsRegExp* = ref object of RootObj

  JsFile* {.importc: "File".} = ref object of RootObj
  FileList* = seq[JsFile]

  FileReader* = ref object of JsObject
    result_data* {.importc: "result".}: cstring
    onload*: proc(ev: Event): bool


proc newBlob*(ary: array[0..0, cstring],
              opt: JsAssoc): Blob {. importcpp: "new Blob(@)" .}
proc URL*(w: Window): UrlStub {. importcpp: "@.URL" .}
proc initURL*(src: cstring): UrlStub {. importc: "new URL" .}

proc href*(loc: Location, src: cstring): void {. importcpp: "#.href = #" .}

{.push importcpp.}

proc execCommand*(self: Document, cmd: cstring): void

proc createObjectURL*(url: UrlStub, blob: Blob): cstring
proc revokeObjectURL*(url: UrlStub, src: cstring)
proc get*(usp: UrlSearchParams, name: cstring): cstring

proc then*(self: JsPromise, cb: proc (ev: Event)): JsPromise {.discardable.}
# proc then*(self: JsPromise, cb: proc (dat: seq[JsObject])): JsPromise
proc then*(self: JsPromise,
           cb: proc (data, textStatus: cstring, jqXHR: JsObject)
           ): JsPromise {.discardable.}
proc then*(self: JsPromise,
           cb: proc (data, textStatus: cstring, jqXHR: JsObject): JsPromise
           ): JsPromise {.discardable.}
proc then*(self: JsPromise,
           fullfilled: proc (data, textStatus: cstring, jqXHR: JsObject),
           rejected: proc (data: cstring): bool
           ): JsPromise {.discardable.}
proc then*(self: JsPromise,
           fullfilled: proc (
                data, textStatus: cstring, jqXHR: JsObject): JsPromise,
           rejected: proc (data: cstring): bool
           ): JsPromise {.discardable.}
proc always*(self: JsPromise,
             rejected: proc()
             ): JsPromise {.discardable.}
proc always*(self: JsPromise,
             cb: proc(d, s: cstring, xhr: JsObject): JsPromise
             ): JsPromise {.discardable.}

#[ jq 3.0>
proc catch*(self: JsPromise,
            cb: proc (jqXHR: JsObject, stat, err: cstring): bool
            ): JsPromise {.discardable.}
 ]#
# proc error*(self: JsPromise, cb: proc ()): JsPromise

proc readAsText*(src: JsFile): void
proc parse*(self: JsonClass, src: cstring): JsObject

proc test*(self: JsRegExp, testie: cstring): bool

proc replace*(self, sub, rep: cstring): cstring

{.pop.}

var JSON*{.importc, nodecl.}: JsonClass

proc eval*(src: cstring): JsObject {.importc: "eval".}
proc setTimeout*(cb: proc(), msec: cint): void {.importc.}

proc newFileReader*(): FileReader {.importc: "new FileReader".}

proc event_filereader_result*(
        ev: Event): cstring {.importcpp: "@.target.result".}
proc element_input_files*(
        el: Element): FileList {.importcpp: "@.files".}

proc id*(src: Node): cstring {.importcpp: "@.id".}

macro js_array*(src: varargs[string]): untyped =  # {{{1
    result = newNimNode(nnkBracket)
    for i in src.children:
        let t1 = newIdentNode("cstring")
        let t2 = newNimNode(nnkCast)
        t2.add(t1)
        t2.add(i)
        result.add(t2)


proc parse_pairs*(self: JsonClass, src: cstring
                  ): JsAssoc[cstring, JsObject] {. importcpp: "#.parse(#)" .}
proc parse_seq*(self: JsonClass,
                src: cstring): seq[JsObject] {. importcpp: "#.parse(#)" .}
proc newJsRegExp*(rex: cstring): JsRegExp {.importcpp: "RegExp(#)" .}

proc array_sort*[K](ary: seq[K], fn: proc(a, b: K): int
                    ): seq[K] {. importcpp: "#.sort(#)" .}

proc array_slice*[K](ary: seq[K], n: int): seq[K] {. importcpp: "#.slice(#)" .}

# vi: ft=nim:ts=4:sw=4:tw=80:nowrap:fdm=marker
