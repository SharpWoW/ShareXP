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

DELIMITER = ';'

local comm, log, misc

T.comm_manager =
    prefix: NAME\upper!
    handlers: {}

    handle: (message, channel, sender) =>
        return unless message
        message = message\trim!
        return if message == ''
        di = message\find DELIMITER
        kind = di and message\sub 1, di - 1 or message
        kind = kind\lower!

        return unless @handlers[kind]

        local arg, args
        if di
            arg = message\sub di + 1
            args = {}
            for token in arg\gmatch '[^' .. DELIMITER .. ']+'
                args[#args + 1] = token

        for _, handler in pairs @handlers[kind]
            handler channel, sender, arg, args

    send: (channel, target, kind, ...) =>
        if channel != 'WHISPER' and channel != 'CHANNEL' and target
            return @send channel, nil, target, kind, ...

        message = kind
        args = {...}
        for v in *args
            message ..= ';' .. v

        SendAddonMessage @prefix, message, channel, target

    add: (kind, handler) =>
        kind = kind\lower!
        @handlers[kind] = {} unless @handlers[kind]
        @handlers[kind][#@handlers[kind] + 1] = handler

    remove: (kind, handler) =>
        kind = kind\lower!
        return unless @handlers[kind]
        for i = #@handlers[kind], 1, -1
            h = @handlers[kind][i]
            @handlers[kind][i] = nil if h == handler

    remove_all: (kind) =>
        kind = kind\lower!
        return unless @handlers[kind]
        wipe @handlers[kind]

{comm_manager: comm, :log, :misc} = T

T.CHAT_MSG_ADDON = (prefix, message, channel, sender) =>
    return if prefix != comm.prefix or channel != 'PARTY'
    fixed_sender = misc.fix_name sender
    player = misc.fix_name UnitName 'player'
    return if fixed_sender == player
    comm\handle mesage, channel, sender

T.SHAREXP_LOADED = =>
    RegisterAddonMessagePrefix comm.prefix
    log\debug 'Registered addon message prefix: %s', comm.prefix
