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

import Logger, log from T
import decorate from T.misc

{database: db} = T

commands = {}

T.command_manager =
    handle: (message) =>
        name, arg = message\match '^([^%s]+)(.*)'
        return @help! unless name
        name = name\lower!
        local command

        for _, cmd in pairs commands
            for _, alias in pairs cmd[1]
                if name\match '^' .. alias
                    command = cmd
                    break

        return log\error 'Invalid command.' unless command

        args = {}

        if arg
            arg = arg\trim!
            if arg == ""
                arg = nil
            else
                for token in arg\gmatch '[^%s]+'
                    table.insert args, token

        command[2] arg, unpack args

    help: =>
        log\info 'TODO: Add help'

    register: (names, handler) =>
        names = {names} unless type(names) == 'table'
        entry = {names, handler}
        table.insert commands, entry

cm = T.command_manager
register = cm\register

register 'd', (arg) ->
    if arg then T\set_debug arg\match '^[yet]' and true or false else T\toggle_debug!
    log\notice "Debugging #{T\is_debug_enabled! and 'ENABLED' or 'DISABLED'}!"

register 'l', (arg, section, s_arg, ss_arg) ->
    if not arg
        return log\notice 'Logging is %s.', db('log') and 'enabled' or 'disabled'
    elseif arg\match '^[ts]' -- Log [t]oggle/[s]witch
        return db\set 'log', (not db 'log', true)
    elseif arg\match '^[ye]' or arg\match '^on' -- Log [y]es, [e]nable, [on]
        return db\set 'log', true
    elseif arg\match '^[nd]' or arg\match '^of' -- Log [n]o, [d]isable, [of]f
        return db\set 'log', false

    return unless section

    -- If user log level threshold is set high enough (notice)
    -- some log statements may not appear

    if section\match '^l' -- Log [l]evel
        if not s_arg
            level = db 'log.level', Logger.levels.INFO
            return log\notice 'Current log level is %s (%d)',
                Logger\level_to_prefix level, level
        level = s_arg\match '^%d+'
        level = tonumber level
        if not level -- Attempt to parse a text value
            prefix = s_arg\match('^.')\upper!
            for pre, lvl in Logger.levels
                if prefix == pre\match '^%w'
                    level = lvl
                    break
        if type(level) == 'number'
            db\set 'log.level', level
    elseif section\match '^c' -- Log [c]olor
        if not s_arg or not ss_arg
            name_color = Logger.colors.name!
            log\notice decorate('Current name color is %s', name_color), name_color
            for level, func in pairs Logger.colors.levels
                color = func!
                prefix = Logger\level_to_prefix level
                log\notice decorate('Current %s color is %s', color), prefix, color
        elseif s_arg\match '^na' -- [na]me
            db\set 'log.color.name', ss_arg
        else
            prefix_letter = s_arg\match '^.'\upper!
            local level, prefix
            for lvl, pre in pairs Logger.prefixes
                if prefix_letter == pre\match '^%w'
                    level = lvl
                    prefix = pre\lower!
                    break
            db\set 'log.color.level.' .. prefix, ss_arg

for i, v in ipairs {'sharexp', 'sxp'}
    _G['SLASH_' .. NAME\upper! .. i] = '/' .. v

SlashCmdList[NAME\upper!] = (msg, editBox) ->
    cm\handle msg
