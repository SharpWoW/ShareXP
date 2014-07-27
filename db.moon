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

-- We import `type` because of possible performance issues
-- if db methods are called from places such as OnUpdate
-- callbacks
import type from _G

-- Same deal with importinhg equal from our table utils
import equal from T.table

DELIMITER = '.'
DELIMITER_ESCAPED = '\\' .. DELIMITER
DELIMITER_NAME_MATCH = '[^' .. DELIMITER_ESCAPED .. ']+$'
DELIMITER_TOKEN_MATCH = '[^' .. DELIMITER_ESCAPED .. ']+'

local check_global, parse_key, extract_name, prepare

class Database
    GET = 0
    SET = 1

    new: (@global_name) =>
        @log = T.Logger 'db.' .. @global_name
        @loaded = false
        @queue = {}

    enqueue: (method, key, value) =>
        if @loaded
            error 'Database.enqueue called when db loaded'
        if method != GET and method != SET
            error 'Database.enqueue called with invalid method arg: ' .. method
        @queue[#@queue + 1] = {:method, :key, :value}

    load: =>
        _G[@global_name] = {} if type(_G[@global_name]) != 'table'
        @global = _G[@global_name]
        @loaded = true
        for item in *@queue
            with item
                switch .method
                    when GET
                        @ .key, .value
                    when SET
                        @set .key, .value
        @queue = nil
        T.event_manager\fire 'SHAREXP_DB_LOADED', @

    -- Probably not needed
    save: =>
        _G[@global_name] = @global

    get: (key, default) =>
        if @loaded
            t = parse_key @, key
            name = extract_name key
            prepare @, name, default, t
            t[name]._VALUE
        else
            @log\warn 'get called before load, returning approximate value for %s', key
            @enqueue GET, key, default
            local entry
            for item in *@queue
                entry = item if item.key == key
            entry.value if entry else default

    set: (key, value) =>
        if @loaded
            t = parse_key @, key
            name = extract_name key
            prepare @, name, value, t
            t[name]._VALUE = value
        else
            @log\warn 'set called before load, queueing set action on %s', key
            @enqueue SET, key, value

    reset: (key) =>
        t = parse_key @, key
        name = extract_name key
        return if type(t[name]) != 'table'
        t[name]._VALUE = t[name]._DEFAULT

T.database = Database NAME .. 'DB'
T.database_char = Database NAME .. 'CharDB'

check_global = (db) ->
    if type(db.global) != 'table'
        error 'Tried to perform a database operation before database loaded'

parse_key = (db, key) ->
    key = key\lower!
    keys = [token for token in key\gmatch DELIMITER_TOKEN_MATCH]
    check_global!
    t = db.global
    for i = 1, #keys - 1
        t[keys[i]] = {} if type(t[keys[i]]) != 'table'
        t = t[keys[i]]
    t

extract_name = (key) ->
    key\match DELIMITER_NAME_MATCH

prepare = (db, key, default, tbl) ->
    check_global!
    tbl = tbl or db.global
    if type(tbl[key]) != 'table'
        tbl[key] = { _VALUE: default, _DEFAULT: default }
    else
        with tbl[key]
            ._VALUE = default if type(._VALUE) != type default
            if type(._DEFAULT) == 'table'
                ._DEFAULT = default unless equal ._DEFAULT, default
            else
                ._DEFAULT = default if ._DEFAULT != default

mt =
    __call: (tbl, key, default) ->
        tbl\get key, default

setmetatable T.database, mt
setmetatable T.database_char, mt
