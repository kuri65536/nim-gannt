# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import svg_js_stub


proc marker_arrow*(cont: SvgParent): void =  # {{{1
    cont.path("M0 0 L5 5 L0 10")


proc marker_milestone*(cont: SvgParent): void =  # {{{1
    cont.path("M0 5 L5 10 L10 0")

# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
