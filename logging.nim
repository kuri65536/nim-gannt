# Copyright (c) 2018, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import jsffi

type
  LOGLEVEL* = enum
    DEBUG = 10
    INFO = 20
    WARNING = 30
    ERROR = 40

  Console = ref object of RootObj

var log {.importc: "console", nodecl.}: Console
var level_cur: LOGLEVEL = LOGLEVEL.DEBUG

proc call_debg(console: Console) {.importcpp: "#.debug(#)", varargs.}
proc call_info(console: Console) {.importcpp: "#.info(#)", varargs.}
proc call_warn(console: Console) {.importcpp: "#.log(#)", varargs.}
proc call_eror(console: Console) {.importcpp: "#.error(#)", varargs.}


proc setLevel*(n: LOGLEVEL) =  # {{{1
    level_cur = n


proc debg*(fmt: string) =  # {{{1
    if level_cur > LOGLEVEL.DEBUG:
        return
    log.call_debg(fmt)


proc info*(fmt: string) =  # {{{1
    if level_cur > LOGLEVEL.INFO:
        return
    log.call_info(fmt)


proc warn*(fmt: string) =  # {{{1
    if level_cur > LOGLEVEL.WARNING:
        return
    log.call_warn(fmt)


proc eror*(fmt: string) =  # {{{1
    if level_cur > LOGLEVEL.ERROR:
        return
    log.call_eror(fmt)


proc debg*(fmt: cstring) =  # {{{1
    debg($(fmt))


proc info*(fmt: cstring) =  # {{{1
    info($(fmt))


proc warn*(fmt: cstring) =  # {{{1
    warn($(fmt))


proc eror*(fmt: cstring) =  # {{{1
    eror($(fmt))

# vi: ft=nim:et:ts=4:sw=4:tw=80:nowrap:fdm=marker
