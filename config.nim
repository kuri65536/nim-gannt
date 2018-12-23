# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import common

type
  Config* = object of RootObj  # {{{1
    X1*: float
    Y1*: float
    X2*: float
    Y2*: float
    sx*: D3Scale
    rx*: D3Scale  # TODO: unified to sx.
    sy*: D3Scale
    mode_xrange*: int
    mode_title*: int
    mode_q1jan*: bool
    mode_from_dtstring*: bool

    fmt_dtstring*: cstring

var cfg* = Config(X1: 200.0, Y1: 50.0, X2: 1000.0, Y2: 500.0,
                  mode_xrange: 0, mode_title: 1, mode_q1jan: false,
                  fmt_dtstring: "yyyy/MM/dd hh:mm:ss",
                  mode_from_dtstring: true)

# end of file {{{1
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
