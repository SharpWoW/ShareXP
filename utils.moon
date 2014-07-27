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

{ :GetRealmName } = _G

T.string =
    split: (str, delim) ->
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
    format: (number) ->
        number = tostring number
        return number if number\match '[^%d%.]' -- Only format normal numbers
        left, right = number\match '^(%d+)(.*)' -- We do not want decimals
        len = left\len!
        return number if len < 4
        mod = len % 3
        left = left\sub(1, mod)\gsub('%d$', '%1,') .. left\sub(mod + 1)\gsub '%d%d%d', '%1,'
        (left\sub 1, left\len! - 1) .. right

local equal

T.table =
    equal: (first, second) ->
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
    fix_name: (name, realm) ->
        dashindex = name\find '-'
        return name if dashindex and dashindex != name\len!
        return name .. '-' .. realm\gsub '%s', '' if realm
        name = name\sub 1, dashindex - 1 if dashindex
        name .. '-' .. GetRealmName!\gsub '%s', ''

    decorate: (text, color) ->
        '\127cff%s%s\127r'\format color, text
