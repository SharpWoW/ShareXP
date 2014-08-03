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

import remove from table

class T.CallbackManager
    new: =>
        @handlers = {}

    register_callback: (id, func) =>
        @handlers[id] = {} unless type(@handlers[id]) == 'table'
        hdlrs = @handlers[id]
        hdlrs[#hdlrs + 1] = func
        @callback_initialized id if #hdlrs == 1

    unregister_callback: (id, func) =>
        return unless type(@handlers[id]) == 'table'
        hdlrs = @handlers[id]
        for i = #hdlrs, 1, -1
            remove hdlrs, i if hdlrs[i] == func

        -- This takes care of nil'ing the table and
        -- calling the cleared method
        if #hdlrs == 0
            @unregister_callbacks id

    unregister_callbacks: (id) =>
        return unless type(@handlers[id]) == 'table'
        @handlers[id] = nil
        @callback_cleared id

    unregister_all_callbacks: =>
        for id, _ in pairs @handlers
            @unregister_callbacks id
        @handlers = {}
        @callbacks_cleared!

    fire: (id, ...) =>
        return unless type(@handlers[id]) == 'table'
        hdlrs = @handlers[id]
        return if #hdlrs == 0
        for func in *hdlrs
            func id, ...

    -- The following methods can be overridden in inheriting
    -- classes to perform special operations when callbacks
    -- are initialized or destroyed

    -- Called the first time a callback id is registered
    callback_initialized: (id) =>

    -- Called when the last handler for a specific callback id
    -- is removed
    callback_cleared: (id) =>

    -- Called when there are no callbacks registered anymore
    -- i.e. `handlers` table is empty
    callbacks_cleared: =>
