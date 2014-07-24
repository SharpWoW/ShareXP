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

import log from T

T.command_manager = do
    class CommandManager
        commands = {}

        handle: (message) =>
            name, arg = message\match '^(%w+)(.*)'
            return @help! unless name
            name = name\lower!
            local command

            for _, cmd in pairs commands
                for _, alias in pairs cmd[1]
                    if alias == name
                        command = cmd
                        break

            return log\error 'Invalid command.' unless command

            local args

            if arg
                arg = arg\trim!
                if arg == ""
                    arg = nil
                else
                    args = {}
                    for token in arg\gmatch '[^%s]+'
                        table.insert args, token

            command[2] arg, args

        help: =>
            log\info 'TODO: Add help'

        register: (names, handler) =>
            names = {names} unless type(names) == 'table'
            entry = {names, handler}
            table.insert commands, entry

    CommandManager()

cm = T.command_manager
register = cm\register

register 'debug', (arg, args) ->
    if arg then T\set_debug arg\match '^[yet]' and true or false else T\toggle_debug!
    log\info "Debugging #{T\is_debug_enabled! and 'ENABLED' or 'DISABLED'}!"

for i, v in ipairs {'sharexp', 'sxp'}
    _G['SLASH_' .. NAME\upper! .. i] = '/' .. v

SlashCmdList[NAME\upper!] = (msg, editBox) ->
    cm\handle msg
