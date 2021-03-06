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

DELIMITER = '\t'
DELIMITER_MATCH = '[^' .. DELIMITER .. ']+'

MAX_MESSAGE_LENGTH = 250

local comm, log, misc

{
    :SendAddonMessage
    :wipe
    :UnitName
    :RegisterAddonMessagePrefix
} = _G

{localization: L} = T

T.comm_manager = do
    class CommManager extends T.CallbackManager
        new: =>
            super!
            @prefix = NAME\upper!

        handle: (message, channel, sender) =>
            return unless message
            message = message\trim!
            return if message == ''
            di = message\find DELIMITER
            kind = di and message\sub(1, di - 1) or message
            kind = kind\lower!

            return unless @handlers[kind]

            args = {}
            if di
                arg = message\sub di + 1
                for token in arg\gmatch DELIMITER_MATCH
                    args[#args + 1] = token

            @fire kind, channel, sender, unpack args

        send: (channel, target, kind, ...) =>
            if channel != 'WHISPER' and channel != 'CHANNEL' and target
                return @send channel, nil, target, kind, ...

            message = kind
            for v in *{...}
                message ..= DELIMITER .. v

            if message\len! > MAX_MESSAGE_LENGTH
                log\warn L.comm_message_length, kind, MAX_MESSAGE_LENGTH

            SendAddonMessage @prefix, message, channel, target

        register_callback: (kind, handler) =>
            kind = kind\lower!
            super kind, handler

        unregister_callback: (kind, handler) =>
            kind = kind\lower!
            super kind, handler

        unregister_callbacks: (kind) =>
            kind = kind\lower!
            super kind

        unregister_all_callbacks: (kind) =>
            kind = kind\lower!
            super kind

    CommManager!

{comm_manager: comm, :log, :misc} = T

T.CHAT_MSG_ADDON = (event, prefix, message, channel, sender) ->
    return if prefix != comm.prefix or channel != 'PARTY'
    fixed_sender = misc.fix_name sender
    player = misc.fix_name UnitName 'player'
    return if fixed_sender == player
    comm\handle message, channel, sender

T.SHAREXP_LOADED = ->
    RegisterAddonMessagePrefix comm.prefix
    log\debug L.comm_prefix_registered, comm.prefix
