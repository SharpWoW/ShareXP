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

assert type(T.event_manager) == 'table', L.loaderror 'main.moon', 'events.moon'

{database: db, event_manager: em} = T

T.ADDON_LOADED = (event, name) ->
    return if name != NAME
    db\load!

    if db 'debug', false
        _G[NAME] = T
        T.log\debug L.debug_exported

    em\fire NAME\upper! .. '_LOADED'

T.set_debug = (enabled) =>
    db\set 'debug', enabled
    if enabled
        _G[NAME] = T
        T.log\debug L.debug_exported
    else
        _G[NAME] = nil

T.reset_debug = =>
    db\reset 'debug'

T.toggle_debug = =>
    @set_debug not @is_debug_enabled!

T.is_debug_enabled = =>
    db 'debug', false
