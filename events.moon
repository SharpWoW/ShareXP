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

L = T.localization

assert type(T.frame) == 'table', L 'loaderror', 'events.moon', 'init.moon'

EVENT_NAME_PATTERN = '^[A-Z_]+$'

import frame from T

local wipe
wipe = wipe or (tbl) -> for k, _ in pairs tbl do tbl[k] = nil

T.event_manager =
    events: {}

    handle: (frame, event, ...) =>
        return unless @events[event]
        for _, handler in pairs @events[event] do handler(T, ...)

    add: (event, handler) =>
        @events[event] = {} unless @events[event]
        @events[event][#@events[event] + 1] = handler
        frame\RegisterEvent event unless frame\IsEventRegistered event

    remove: (event, handler) =>
        return unless @events[event]

        for k, h in pairs @events[event]
            @events[event] = nil if h == handler

        if #@events[event] == 0 and frame\IsEventRegistered event
            frame\UnregisterEvent event

    remove_all: (event) =>
        if event
            wipe @events
            frame\UnregisterAllEvents!
        else
            return unless @events[event]
            wipe @events[event]
            frame\UnregisterEvent event if frame\IsEventRegistered event

    get_handlers: (event) =>
        if @events[event] then [h for h in *@events[event]] else nil

    fire: (event, ...) =>
        @handle nil, event, ...

em = T.event_manager

frame\SetScript 'OnEvent', (f, e, ...) -> em\handle f, e, ...

mt =
    __index: (tbl, key) ->
        if key\match EVENT_NAME_PATTERN
            em\get_handlers key
        else
            rawget tbl, key

    __newindex: (tbl, key, value) ->
        if key\match EVENT_NAME_PATTERN
            em\add key, value
        else
            rawset tbl, key, value

setmetatable T, mt
