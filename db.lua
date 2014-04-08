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

assert(type(T.EventManager) == "table", "LOAD ORDER ERROR: db.lua was loaded before events.lua")

local DELIMITER = '.'
local DELIMITER_NAME_MATCH = "[^\\" .. DELIMITER .. "]+$"

T.DB = {
    GlobalName = NAME .. "DB"
}

local DB = T.DB

function DB:Load()
    if type(_G[self.GlobalName]) ~= "table" then
        _G[self.GlobalName] = {}
    end

    local temp

    if self.Global then
        temp = self.Global
    end

    self.Global = _G[self.GlobalName]

    if type(temp) == "table" then
        for k, v in pairs(temp) do
            self.Global[k] = v
        end
    end
end

-- Probably not needed
function DB:Save()
    _G[self.GlobalName] = self.Global
end

local function CheckGlobal()
    if type(DB.Global) ~= "table" then DB.Global = {} end
end

local function ParseKey(key)
    key = key:lower()
    local keys = T.String:Split(key, DELIMITER)
    CheckGlobal()
    local t = DB.Global
    for i = 1, #keys - 1 do
        if type(t[keys[i]]) ~= "table" then
            t[keys[i]] = {}
        end
        t = t[keys[i]]
    end
    return t
end

local function ExtractName(key)
    return key:match(DELIMITER_NAME_MATCH)
end

local function Prepare(key, default, tbl)
    CheckGlobal()
    tbl = tbl or DB.Global
    if type(tbl[key]) ~= "table" then
        tbl[key] = { Value = default, Default = default }
    end
end

function DB:Get(key, default)
    local t = ParseKey(key)
    local name = ExtractName(key)
    Prepare(name, default, t)
    return t[name].Value
end

function DB:Set(key, value)
    local t = ParseKey(key)
    local name = ExtractName(key)
    Prepare(name, value, t)
    t[name].Value = value
end

function DB:Reset(key)
    local t = ParseKey(key)
    local name = ExtractName(key)
    if type(t[name]) ~= "table" then return end
    t[name].Value = t[name].Default
end

local mt = {
    __call = function(tbl, key, default)
        return tbl:Get(key, default)
    end
}

setmetatable(DB, mt)
