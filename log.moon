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

import decorate from T.misc

{localization: L} = T

import format, upper from string

local db

class T.Logger
    @levels:
        DEBUG: 0
        INFO: 1
        WARN: 2
        ERROR: 3
        FATAL: 4
        NOTICE: 5

    @level_to_prefix: (level) =>
        @prefixes[level] or L.unknown\upper!

    @prefix_to_level: (prefix) =>
        prefix = prefix\upper!
        @levels[prefix] or -1

    new: (@name, @color) =>

    log: (level, ...) =>
        if not db then return print level, ... -- Emergency fallback
        return unless db 'log', true
        return if level == @@levels.DEBUG and (not db.loaded or not db 'debug', false)
        return if level < db 'log.level', @@levels.INFO
        prefix = @@level_to_prefix level
        docolor = db 'log.color', true
        prefix_color = (docolor and @@colors.levels[level]) and @@colors.levels[level]! or nil
        msg = '%s.%s: [%s] %s'\format docolor and decorate(NAME, @@colors.name!) or NAME,
            (docolor and @color) and decorate(@name, @color) or @name,
            (docolor and prefix_color) and decorate(prefix, prefix_color) or prefix,
            format ...
        DEFAULT_CHAT_FRAME\AddMessage msg

import Logger from T

Logger.prefixes = {v, k for k, v in pairs Logger.levels}

with Logger
    .colors =
        name: -> db 'log.color.name', '00FF00'
        levels:
            [.levels.DEBUG]:  -> db 'log.color.level.debug',  '008000' -- Green
            [.levels.INFO]:   -> db 'log.color.level.info',   'FFFFFF' -- White
            [.levels.WARN]:   -> db 'log.color.level.warn',   'FFD700' -- Gold
            [.levels.ERROR]:  -> db 'log.color.level.error',  'FF0000' -- Red
            [.levels.FATAL]:  -> db 'log.color.level.fatal',  'FF0000' -- Red
            [.levels.NOTICE]: -> db 'log.color.level.notice', '00FFFF' -- Cyan

for id, level in pairs Logger.levels
    Logger.__base[id\lower!] = (...) => @log level, ...

log = Logger('main')

T.log = log

load_db = (database) =>
    db = database if database.global_name == 'ShareXPDB'

T.SHAREXP_DB_CREATED = load_db
T.SHAREXP_DB_LOADED = load_db

T.SHAREXP_DB_UPDATED = (db, key) =>
    return unless db.global_name == 'ShareXPDB'
    return unless key\match '^log'
    switch key
        when 'log'
            log\notice L.log_status_changed, db('log') and L.enabled or L.disabled
        when 'log.color'
            log\notice L.log_coloring_changed, db('log.color') and L.enabled or L.disabled
        when 'log.level'
            log\notice L.log_level_changed, Logger\level_to_prefix db 'log.level'
        when 'log.color.name'
            color = Logger.colors.name!
            msg = L 'log_color_changed', L.name\gsub('^.', upper), color
            log\notice decorate(msg, color)
        else
            prefix = key\match '^log%.color%.level%.(%w+)$'
            if prefix
                prefix = prefix\upper!
                level = Logger\prefix_to_level prefix
                color = Logger.colors.levels[level]!
                msg = L 'log_color_changed', prefix, color
                log\notice decorate(msg, color)
