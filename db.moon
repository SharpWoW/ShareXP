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

{event_manager: em, localization: L} = T

DELIMITER = '.'
DELIMITER_ESCAPED = '\\' .. DELIMITER
DELIMITER_NAME_MATCH = '[^' .. DELIMITER_ESCAPED .. ']+$'
DELIMITER_TOKEN_MATCH = '[^' .. DELIMITER_ESCAPED .. ']+'

local parse_key, extract_name, extract_keys, prepare

class Database
    GET = 0
    SET = 1
    RESET = 2

    -- This will make sure updates are fired for the key
    -- and any parent keys, for example:
    -- send_update(db, 'one.two.three') will fire updates
    -- for:
    -- one
    -- one.two
    -- one.two.three
    send_update = (db, key) ->
        em\fire 'SHAREXP_DB_UPDATED', db, key

    new: (@global_name) =>
        @log = T.Logger 'db.' .. @global_name
        @loaded = false
        @queue = {}
        em\fire 'SHAREXP_DB_CREATED', @

    __call: (...) =>
        @get ...

    enqueue: (method, key, value) =>
        if @loaded
            error L.db_enqueue_loaded
        if method != GET and method != SET and method != RESET
            error L.db_enqueue_invalid tostring method
        @queue[#@queue + 1] = {:method, :key, :value}

    load: =>
        _G[@global_name] = {} if type(_G[@global_name]) != 'table'
        @global = _G[@global_name]
        @loaded = true
        for item in *@queue
            with item
                switch .method
                    when GET
                        @get .key, .value
                    when SET
                        @set .key, .value
                    when RESET
                        @reset .key
        @queue = nil
        em\fire 'SHAREXP_DB_LOADED', @

    -- Probably not needed
    save: =>
        _G[@global_name] = @global

    get: (key, default) =>
        if @loaded
            tbl = parse_key @, key
            name = extract_name key
            prepare tbl, name, default
            tbl[name]._VALUE, tbl[name]._DEFAULT
        else
            @log\warn L.db_get_load, key
            @enqueue GET, key, default
            local entry
            for item in *@queue
                entry = item if item.key == key
            entry.value if entry else default

    get_value: (key, default) =>
        (@get key, default)

    get_default: (key) =>
        if @loaded
            _, default = @get key
            default
        else
            @log\warn L.db_get_default_load, key
            nil

    set: (key, value, silent) =>
        if @loaded
            tbl = parse_key @, key
            name = extract_name key
            prepare tbl, name, value
            tbl[name]._VALUE = value
            send_update @, key unless silent
        else
            @log\warn L.db_set_load, key
            @enqueue SET, key, value

    reset: (key, silent) =>
        if @loaded
            tbl = parse_key @, key
            name = extract_name key
            return if type(tbl[name]) != 'table'
            tbl[name]._VALUE = tbl[name]._DEFAULT
            send_update @, key unless silent
        else
            @log\warn L.db_reset_load, key
            @enqueue RESET, key

T.database = Database NAME .. 'DB'
T.database_char = Database NAME .. 'CharDB'

parse_key = (db, key) ->
    key = key\lower!
    keys = extract_keys key
    t = db.global
    for i = 1, #keys - 1
        t[keys[i]] = {} if type(t[keys[i]]) != 'table'
        t = t[keys[i]]
    t

extract_name = (key) ->
    key\match DELIMITER_NAME_MATCH

extract_keys = (key) ->
    [token for token in key\gmatch DELIMITER_TOKEN_MATCH]

prepare = (tbl, key, default) ->
    if type(tbl[key]) != 'table'
        tbl[key] = { _VALUE: default, _DEFAULT: default }
    else
        default_type = type default
        with tbl[key]
            ._VALUE = default if type(._VALUE) != default_type and default_type != 'nil'
            if type(._DEFAULT) == 'table'
                ._DEFAULT = default unless default_type == 'nil' or equal ._DEFAULT, default
            else
                ._DEFAULT = default if ._DEFAULT != default and default_type != 'nil'
