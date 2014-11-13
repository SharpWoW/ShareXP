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

logging_enabled = true
logging_level = 1
logging_color_enabled = true
db_loaded = false
debug_enabled = false

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
        return unless logging_enabled -- db 'log', true
        return if level == @@levels.DEBUG and not debug_enabled
        return if level < logging_level and not debug_enabled
        prefix = @@level_to_prefix level
        docolor = logging_color_enabled
        name = docolor and decorate(NAME, @@colors.name) or NAME
        logname = (docolor and @color) and decorate(@name, @color) or @name
        prefix_color = docolor and @@colors.levels[level] or nil
        prefix = (docolor and prefix_color) and decorate(prefix, prefix_color) or prefix

        -- Tostring any LocaleStrings
        args = {...}
        for i = 1, #args
            arg = args[i]
            args[i] = tostring(arg) if type(arg) == 'table' and type(arg.__class) == 'table' and arg.__class.__name == 'LocaleString'

        msg = '%s.%s: [%s] %s'\format name, logname, prefix, format unpack args
        DEFAULT_CHAT_FRAME\AddMessage msg

import Logger from T

Logger.prefixes = {v, k for k, v in pairs Logger.levels}

with Logger
    .colors =
        name: '00FF00' -- -> db 'log.color.name', '00FF00'
        levels:
            [.levels.DEBUG]: '008000' -- -> db 'log.color.level.debug',  '008000' -- Green
            [.levels.INFO]: 'FFFFFF'  -- -> db 'log.color.level.info',   'FFFFFF' -- White
            [.levels.WARN]: 'FFD700' --  -> db 'log.color.level.warn',   'FFD700' -- Gold
            [.levels.ERROR]: 'FF0000' -- -> db 'log.color.level.error',  'FF0000' -- Red
            [.levels.FATAL]: 'FF0000' -- -> db 'log.color.level.fatal',  'FF0000' -- Red
            [.levels.NOTICE]: '00FFFF' -- -> db 'log.color.level.notice', '00FFFF' -- Cyan

for id, level in pairs Logger.levels
    Logger.__base[id\lower!] = (...) => @log level, ...

log = Logger('main')

T.log = log

load_db = (event, database) ->

T.SHAREXP_DB_CREATED = (event, database) ->
    db = database if database.global_name == 'ShareXPDB'

T.SHAREXP_DB_LOADED = (event, database) ->
    return unless database.global_name == db.global_name
    logging_enabled = db 'log', logging_enabled
    logging_level = db 'log.level', logging_level
    logging_color_enabled = db 'log.color', logging_color_enabled
    db_loaded = true
    debug_enabled = db 'debug', debug_enabled
    for level, color in pairs Logger.colors.levels
        prefix = Logger\level_to_prefix(level)\lower!
        Logger.colors.levels[level] = db "log.color.level.#{prefix}", color

T.SHAREXP_DB_UPDATED = (event, db, key) ->
    return unless db.global_name == 'ShareXPDB'
    switch key
        when 'debug'
            debug_enabled = db 'debug'
        when 'log'
            value = db 'log'
            logging_enabled = value
            log\notice L.log_status_changed, value and L.enabled or L.disabled
        when 'log.color'
            value = db 'log.color'
            logging_color_enabled = value
            log\notice L.log_coloring_changed, value and L.enabled or L.disabled
        when 'log.level'
            value = db 'log.level'
            logging_level = value
            log\notice L.log_level_changed, Logger\level_to_prefix value
        when 'log.color.name'
            color = db 'log.color.name'
            Logger.colors.name = color
            msg = L.log_color_changed L.name\gsub('^.', upper), color
            log\notice decorate(msg, color)
        else
            prefix = key\match '^log%.color%.level%.(%w+)$'
            if prefix
                prefix = prefix\upper!
                level = Logger\prefix_to_level prefix
                color = db key
                Logger.colors.levels[level] = color
                msg = L.log_color_changed prefix, color
                log\notice decorate(msg, color)
