--[[
 ~ Copyright (c) 2014 by Adam Hellberg <sharparam@sharparam.com>.
 ~
 ~ Permission is hereby granted, free of charge, to any person obtaining a copy
 ~ of this software and associated documentation files (the "Software"), to deal
 ~ in the Software without restriction, including without limitation the rights
 ~ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ~ copies of the Software, and to permit persons to whom the Software is
 ~ furnished to do so, subject to the following conditions:
 ~
 ~ The above copyright notice and this permission notice shall be included in
 ~ all copies or substantial portions of the Software.
 ~
 ~ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ~ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ~ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ~ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ~ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ~ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 ~ THE SOFTWARE.
--]]

local NAME, T = ...

local Db = T.Database

local format = string.format
local upper = string.upper

T.Log = {
    Levels = {
        DEBUG = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3,
        FATAL = 4
    },
    Prefixes = {}
}

local Log = T.Log

for k, v in pairs(Log.Levels) do
    Log.Prefixes[v] = k --:lower():gsub("^%w", upper)
end

local function printf(...)
    DEFAULT_CHAT_FRAME:AddMessage(format("%s: %s", NAME, format(...)))
end

local function lprintf(level, ...)
    if not Log.Prefixes[level] then error("Invalid log level: " .. level) end
    if level == Log.Levels.DEBUG and (not Db.Loaded or not Db:Get("debug", false)) then return end
    local prefix = Log.Prefixes[level]
    local msg = ("[%s] %s"):format(prefix, string.format(...))
    printf(msg)
end

for id, level in pairs(Log.Levels) do
    Log[id:lower():gsub("^%w", string.upper)] = function(s, ...) lprintf(level, ...) end
end
