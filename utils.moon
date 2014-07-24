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
        return t

T.misc =
    fix_name: (name, realm) ->
        dashindex = name\find '-'
        return name if dashindex and dashindex != name\len!
        return name .. '-' .. realm\gsub '%s', '' if realm
        name = name\sub 1, dashindex - 1 if dashindex
        name .. '-' .. GetRealmName!\gsub '%s', ''
