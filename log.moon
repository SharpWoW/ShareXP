-- Copyright (c) 2014 by Adam Hellberg <sharparam@sharparam.com>.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

NAME, T = ...

db = T.database

import format, upper from string

T.log =
    levels:
        DEBUG: 0
        INFO: 1
        WARN: 2
        ERROR: 3
        FATAL: 4

import log from T

log.prefixes = {v, k for k, v in pairs log.levels}

printf = (...) ->
    DEFAULT_CHAT_FRAME\AddMessage format '%s: %s', NAME, format ...

lprintf = (level, ...) ->
    error "Invalid log level: #{level}" unless log.prefixes[level]
    return if level == log.levels.DEBUG and (not db.loaded or not db\get 'debug', false)
    prefix = log.prefixes[level]
    msg = '[%s] %s'\format prefix, format ...
    printf msg

for id, level in pairs log.levels
    log[id\lower!] = (...) -> lprintf level, ...
