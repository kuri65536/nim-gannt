# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import jsffi
import dom

type
  Blob* = ref BlobObj
  BlobObj = object of RootObj

  UrlSearchParams* = ref RootObj
  UrlStub* = ref UrlObj
  UrlObj = object of RootObj
    searchParams*: UrlSearchParams

  JsPromise* = ref object of RootObj

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

proc createObjectURL*(url: UrlStub, blob: Blob): cstring
proc revokeObjectURL*(url: UrlStub, src: cstring)
proc get*(usp: UrlSearchParams, name: cstring): cstring

proc then*(self: JsPromise, cb: proc (ev: Event)): JsPromise
# proc then*(self: JsPromise, cb: proc (dat: seq[JsObject])): JsPromise
proc then*(self: JsPromise,
           cb: proc (data, textStatus: cstring, jqXHR: JsObject)): JsPromise
# proc error*(self: JsPromise, cb: proc ()): JsPromise

proc readAsText(src: JsFile): void

{.pop.}

proc newFileReader*(): FileReader {.importc: "new FileReader".}

proc event_filereader_result*(
        ev: Event): cstring {.importcpp: "@.target.result".}
proc element_input_files*(
        el: Element): FileList {.importcpp: "@.files".}

proc id*(src: Node): cstring {.importcpp: "@.id".}

# vi: ft=nim:ts=4:sw=4:tw=80:nowrap:fdm=marker
