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

{:GetRealmName, :LARGE_NUMBER_SEPERATOR} = _G

T.string =
    split: (str, delim using nil) ->
        return nil unless str
        t = {}
        if delim then
            return {str} unless str\find delim
            pattern = '(.-)' .. delim .. '()'
            local lastpos
            for part, pos in str\gmatch pattern
                t[#t + 1] = part
                lastpos = pos
            t[#t + 1] = str\sub lastpos
        else
            for token in str\gmatch '[^%s]+'
                t[#t + 1] = token
        t

T.number =
    -- Format function courtesy of SDPhantom from WoWInterface
    -- http://www.wowinterface.com/forums/showpost.php?p=270917&postcount=11
    format: (number using LARGE_NUMBER_SEPERATOR) ->
        number = tostring number
        number\gsub '^(%d)(%d+)', (pre, post) ->
            pre .. post\reverse!\gsub('(%d%d%d)', '%1' .. LARGE_NUMBER_SEPERATOR)\reverse!

local equal

T.table =
    equal: (first, second using equal) ->
        first_type = type first
        second_type = type second
        return false if first_type != 'table' or second_type != 'table'
        for k, v in pairs first
            if type(k) == 'table'
                error 'Comparison with tables as keys not yet implemented'
            if type(v) == 'table'
                return false unless equal v, second[k]
            else
                return false if v != second[k]
        true

import equal from T.table

T.misc =
    fix_name: (name, realm using GetRealmName) ->
        dashindex = name\find '-'
        return name if dashindex and dashindex != name\len!
        return name .. '-' .. realm\gsub '%s', '' if realm
        name = name\sub 1, dashindex - 1 if dashindex
        name .. '-' .. GetRealmName!\gsub '%s', ''

    decorate: (text, color using nil) ->
        '|cff%s%s|r'\format color, text

    -- This basically just calls loadstring on a text
    -- representation of a Lua object like a number,
    -- string or table
    deserialize: (str) ->
        func = assert loadstring 'return ' .. str
        setfenv func, {} -- Don't give access to anything
        pcall func
