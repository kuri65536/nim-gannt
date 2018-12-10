import jsffi
import dom

type
  Blob* = ref BlobObj
  BlobObj = object of RootObj

  UrlStub* = ref UrlObj
  UrlObj = ref object of RootObj

  JsPromise* = ref object of RootObj


proc newBlob*(ary: array[0..0, cstring],
              opt: JsAssoc): Blob {. importcpp: "new Blob(@)" .}
proc URL*(w: Window): UrlStub {. importcpp: "@.URL" .}

{.push importcpp.}

proc createObjectURL*(url: UrlStub, blob: Blob): cstring
proc revokeObjectURL*(url: UrlStub, src: cstring)


proc then*(self: JsPromise, cb: proc (ev: Event)): JsPromise
proc then*(self: JsPromise, cb: proc (dat: seq[JsObject])): JsPromise
# proc error*(self: JsPromise, cb: proc ()): JsPromise

{.pop.}

