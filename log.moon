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

import format from string

class T.Logger
    @levels:
        DEBUG: 0
        INFO: 1
        WARN: 2
        ERROR: 3
        FATAL: 4

    new: (@name) =>

    log: (level, ...) =>
        return if level == @@levels.DEBUG and (not db.loaded or not db\get 'debug', false)
        prefix = @@prefixes[level] or 'UNKNOWN'
        msg = '%s.%s: [%s] %s'\format NAME, @name, prefix, format ...
        DEFAULT_CHAT_FRAME\AddMessage msg

import Logger from T

Logger.prefixes = {v, k for k, v in pairs Logger.levels}

for id, level in pairs Logger.levels
    Logger.__base[id\lower!] = (...) => @log level, ...

T.log = Logger('main')
