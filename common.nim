# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import jsffi
import jsconsole


type
  # D3Scale* = object of RootObj  # {{{1
  D3Scale* = ref object of RootObj  # {{{1
    a, b, c: float
    r1, r2, d1, d2: float


proc initScaleLinear*(): var D3Scale =  # {{{1
    new(result)
    result.d1 = 0.0
    result.d2 = 0.0
    result.r1 = 0.0
    result.r2 = 0.0


proc calc(self: var D3Scale): bool {.discardable.} =  # {{{1
    if self.d1 == 0.0 and self.d1 == self.d2:
        return true
    elif self.r1 == 0.0 and self.r1 == self.r2:
        return true
    self.a = (self.r2 - self.r1) / (self.d2 - self.d1)
    self.b = self.d1
    self.c = self.r1
    return false


proc domain*(self: var D3Scale, minmax: array[0..1, float]
             ): var D3Scale {.discardable.} =  # {{{1
    self.d1 = minmax[0]
    self.d2 = minmax[1]
    self.calc()
    return self


proc range*(self: var D3Scale, minmax: array[0..1, float]
            ): var D3Scale {.discardable.} =  # {{{1
    self.r1 = minmax[0]
    self.r2 = minmax[1]
    self.calc()
    return self


proc to*(self: D3Scale, x: float): float =  # {{{1
    var ret = self.a * (x - self.b) + self.c
    console.debug("scale.to: " & $(x) & "->" & $(ret))
    return ret


proc to*(self: D3Scale, x: int): float =  # {{{1
    return self.to(float(x))


proc min_from*(dat: seq[JsObject],
               chooser: proc(src: JsObject): float): float =  # {{{1
    var cur = Inf
    for obj in dat:
        var v = chooser(obj)
        if v < cur:
            cur = v
    return cur


proc max_from*(dat: seq[JsObject],
               chooser: proc(src: JsObject): float): float =  # {{{1
    var cur = NegInf
    for obj in dat:
        var v = chooser(obj)
        if v > cur:
            cur = v
    return cur

# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
