# import class
import firefox_stub
import jsffi

type
  D3* = ref D3Inst
  D3Inst {.importc.} = ref object of RootObj
    dmy: int

  D3Scale* = ref object of RootObj
    dmy: int

  D3Selector* = ref object of RootObj
    dmy: int


{.push importcpp.}

# method
proc min*(self: D3, sequence: seq[JsObject],
          chooser: proc (obj: JsObject): float): float
proc max*(self: D3, sequence: seq[JsObject],
          chooser: proc (self: JsObject): float): float
proc scaleLinear*(x: D3): D3Scale
proc select*(self: D3, selector: string): D3Selector
proc csv*(self: D3, url: string): JsPromise

# scaler
proc domain*(self: D3Scale,
             minmax: array[0..1, float]): D3Scale {.importc.}
proc range*(self: D3Scale,
            minmax: array[0..1, float]): D3Scale {.importc.}
proc to*(self: D3Scale, val: float): float
proc to*(self: D3Scale, val: int): int

# selector
proc selectAll*(self: D3Selector, selector: cstring): D3Selector
proc data*(self: D3Selector, sequence: seq[JsObject]): D3Selector
proc enter*(self: D3Selector): D3Selector
proc append*(self: D3Selector, tag: string): D3Selector
# proc attr*(self: D3Selector, attr: string,
#            chooser: proc (obj: JsObject): int): D3Selector
# proc attr*(self: D3Selector, attr: string,
#            chooser: proc (obj: JsObject): float): D3Selector
proc attr*(self: D3Selector, name: string,
           chooser: proc (obj: JsObject): string): D3Selector
proc attr*(self: D3Selector, name: string, value: string): D3Selector

{.pop.}

var d3* {.importc, nodecl.}: D3

# vi: ft=nim:et:sw=4:tw=80:nowrap
