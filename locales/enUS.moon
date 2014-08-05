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

L =
    -- General
    loaderror: 'LOAD ORDER ERROR: %s loaded before %s'
    leftclick: 'Left Click'
    enabled: 'enabled'
    disabled: 'disabled'
    name: 'name'
    unknown: 'unknown'
    invalid_command: 'Invalid command.'
    debug_status: 'Debugging %s!'

    -- Broker
    b_text_empty: "#{NAME}: No data"
    b_announce_smart: 'Announce XP (Smart)'
    b_header_xp: 'XP data for party'
    b_header_empty: 'No data at the moment'
    b_minimap_status: 'Minimap icon is now %s.'

    -- Comm module
    comm_message_length: 'comm_manager\\send: (%s) message length > %d'
    comm_prefix_registered: 'Registered addon message prefix: %s'

    -- Database
    db_safety_notice: 'For safety reasons, db command is only operable in debug mode.'
    db_usage: 'Usage: <key> [value]'
    db_current: 'Value of %s is %s (default: %s)'
    db_reset: 'Value of %s has been reset to %s'
    db_invalid: 'Invalid value given, Lua error: %s'
    db_set: 'Value of %s set to %s'
    db_enqueue_loaded: 'Database.enqueue called when db loaded'
    db_enqueue_invalid: 'Database.enqueue called with invalid method arg: %s'
    db_get_load: 'get called before load, returning approximate value for %s'
    db_get_default_load: 'get_default called before load, returning nil for %s'
    db_set_load: 'set called before load, queueing set action on %s'
    db_reset_load: 'reset called before load, queueing reset action on %s'

    -- Log
    log_status: 'Logging is %s.'
    log_status_changed: 'Logging %s.'
    log_color_changed: '%s color changed to %s.'
    log_coloring_changed: 'Log coloring %s.'
    log_level_changed: 'Logging level changed to %s.'
    log_current_level: 'Current log level is %s (%d)'
    log_current_color: 'Current %s color is %s'
    log_color_usage: 'Usage: enable/disable / name/<level> <color>'
    log_invalid_prefix: 'Invalid prefix'
    
    -- XP
    xp_invalid_data: 'Invalid data received from %s'
    xp_updated: 'XP updated for %s'
    xp_sent_update: 'Sent XP update to party'
    xp_sent_request: 'Sent XP request to party'
    xp_removing: 'Removing %s from group, no longer present'
    xp_received_update: 'Received XP update from %s:%s'
    xp_received_request: 'Received XP request from %s:%s'

setmetatable L,
    __index: (key) => "L.#{key}"
    __call: (key, ...) =>
        @[key]\format ...

T.localization = L
