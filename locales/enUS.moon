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

L = {}

mt =
    __call: (key, ...) =>
        @[key]\format ...
    __newindex: (key, value) =>
        if type(value) == 'table'
            setmetatable value, getmetatable @

        rawset @, key, value

setmetatable L, mt

with L
    .common =
        leftclick: 'Left Click'
        enabled: 'enabled'
        disabled: 'disabled'
        name: 'name'
        unknown: 'unknown'
    .actions =
        announce:
            smart: 'Announce XP (Smart)'
    .errors =
        invalid_command: 'Invalid command.'
        comm:
            message_length: 'comm_manager\\send: (%s) message length > %d'
    .comm =
        prefix_registered: 'Registered addon message prefix: %s'
    .commands =
        debug:
            status: 'Debugging %s!'
        db:
            safety_notice: 'For safety reasons, db command is only operable in debug mode.'
            usage: 'Usage: <key> [value]'
            current: 'Value of %s is %s (default: %s)'
            reset: 'Value of %s has been reset to %s'
            invalid: 'Invalid value given, Lua error: %s'
            set: 'Value of %s set to %s'
        log:
            status: 'Logging is %s.'
            current_level: 'Current log level is %s (%d)'
            current_color: 'Current %s color is %s'
            color_usage: 'Usage: enable/disable / name/<level> <color>'
            invalid_prefix: 'Invalid prefix'
    .db =
        errors:
            enqueue_loaded: 'Database.enqueue called when db loaded'
            enqueue_invalid: 'Database.enqueue called with invalid method arg: %s'
            get_load: 'get called before load, returning approximate value for %s'
            get_default_load: 'get_default called before load, returning nil for %s'
            set_load: 'set called before load, queueing set action on %s'
            reset_load: 'reset called before load, queueing reset action on %s'
    .xp =
        invalid_data: 'Invalid data received from %s'
        updated: 'XP updated for %s'
        sent_update: 'Sent XP update to party'
        sent_request: 'Sent XP request to party'
        removing: 'Removing %s from group, no longer present'
        received_update: 'Received XP update from %s:%s'
        received_request: 'Received XP request from %s:%s'

T.localization = L
