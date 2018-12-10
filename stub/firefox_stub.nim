import jsffi
import dom

type
  Blob* = ref BlobObj
  BlobObj = ref object of RootObj

  UrlStub* = ref UrlObj
  UrlObj = ref object of RootObj

  JsPromise* = ref object of RootObj


proc newBlob*(ary: array[0..0, string],
              opt: JsAssoc): Blob {. importcpp: "{@}" .}

{.push importcpp.}
proc URL*(w: Window): UrlStub

proc createObjectURL*(url: UrlStub, blob: Blob): string
proc revokeObjectURL*(url: UrlStub, src: string)


proc then*(self: JsPromise, cb: proc (ev: Event)): JsPromise
proc then*(self: JsPromise, cb: proc (dat: seq[JsObject])): JsPromise
# proc error*(self: JsPromise, cb: proc ()): JsPromise

{.pop.}

