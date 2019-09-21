# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import logging
import common

## ## Configuration
## ```
##       | A H6: x-tic              | yyyy/mm <- S1: font-size
##       | |                        |
##       | |   |  | A H5: x-sub-tic |  |  |  |
##       | V   |  | V               |  |  |  |
## ------+-------------------------------------
##       |<-(X1,Y1)  v milestoneA
##       |           <-> W1: milestone and text padding
##       |
##       |                      AA H1:bar-height
##       |     +--------------+ |V H2:bar-padding
##       |     |<--bar------->| |
##       |     +--------------+ |
##       |                      V
##       |                            (X2,Y2)->
## ```
type
  Config* = object of RootObj  # {{{1
    X1*, X2*: float   # chart-left, right
    Y1*, Y2*: float   # chart-top, bottom
    H1*: float        # bar-height
    H2*, H3*: int     # bar-padding, bar-radius
    H4*: int          # milestone offset
    H5*, H6*: int     # height of x-sub-tic and x-tic
    W1*: int          # milestone and text padding between milestone and text
    S1*: int          # font-size for x-tics
    sx*: D3Scale
    rx*, ry*: D3Scale  # TODO: unified to sx.
    sy*: D3Scale
    mode_xrange*: int
    mode_title*: int
    mode_q1jan*: bool
    mode_from_dtstring*: bool

    fmt_dtstring*: cstring

    log_level*: LOGLEVEL

var cfg* = Config(X1: 200.0, Y1: 50.0, X2: 1000.0, Y2: 500.0,
                  H1: 20.0, H2: 2, H3: 3, H4: 10,
                  H5: 14, H6: 20,
                  W1: 10, S1: 10,
                  mode_xrange: 0, mode_title: 0, mode_q1jan: false,
                  fmt_dtstring: "yyyy/MM/dd hh-mm-ss",
                  mode_from_dtstring: true,
                  log_level: LOGLEVEL.INFO)

# end of file {{{1
# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
