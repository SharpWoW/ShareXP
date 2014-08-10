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

EVENT_NAME_PATTERN = '^[A-Z_]+$'

frame = CreateFrame 'Frame'

T.event_manager = do
    class EventManager extends T.CallbackManager
        handle: (frame, event, ...) =>
            @fire event, ...

        get_handlers: (event) =>
            if @handlers[event] then [h for h in *@handlers[event]] else nil

        callback_initialized: (event) =>
            frame\RegisterEvent event unless frame\IsEventRegistered event

        callback_cleared: (event) =>
            frame\UnregisterEvent event if frame\IsEventRegistered event

        callbacks_cleared: =>
            frame\UnregisterAllEvents!

    EventManager!

em = T.event_manager

frame\SetScript 'OnEvent', em\handle

mt =
    __index: (tbl, key) ->
        if key\match EVENT_NAME_PATTERN
            em\get_handlers key
        else
            rawget tbl, key

    __newindex: (tbl, key, value) ->
        if key\match EVENT_NAME_PATTERN
            if value == nil
                em\unregister_callbacks key
            else
                em\register_callback key, value
        else
            rawset tbl, key, value

setmetatable T, mt
