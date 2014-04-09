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

local DELIMITER = '.'
local DELIMITER_ESCAPED = "\\" .. DELIMITER
local DELIMITER_NAME_MATCH = "[^\\" .. DELIMITER .. "]+$"

T.Database = {
    Loaded = false,
    GlobalName = NAME .. "DB"
}

local Db = T.Database

function Db:Load()
    if type(_G[self.GlobalName]) ~= "table" then
        _G[self.GlobalName] = {}
    end

    self.Global = _G[self.GlobalName]

    self.Loaded = true
    T.EventManager:Fire("SHAREXP_DB_LOADED")
end

-- Probably not needed
function Db:Save()
    _G[self.GlobalName] = self.Global
end

local function CheckGlobal()
    if type(Db.Global) ~= "table" then
        error("Tried to perform a database operation before database loaded")
    end
    --if type(Db.Global) ~= "table" then Db.Global = {} end
end

local function ParseKey(key)
    key = key:lower()
    local keys = {}
    for token in key:gmatch("[^" .. DELIMITER_ESCAPED .. "]+") do
        table.insert(keys, token)
    end
    CheckGlobal()
    local t = Db.Global
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
    tbl = tbl or Db.Global
    if type(tbl[key]) ~= "table" then
        tbl[key] = { Value = default, Default = default }
    else
        if type(tbl[key].Value) ~= type(default) then
            tbl[key].Value = default
        end

        if tbl[key].Default ~= default then
            tbl[key].Default = default
        end
    end
end

function Db:Get(key, default)
    local t = ParseKey(key)
    local name = ExtractName(key)
    Prepare(name, default, t)
    return t[name].Value
end

function Db:Set(key, value)
    local t = ParseKey(key)
    local name = ExtractName(key)
    Prepare(name, value, t)
    t[name].Value = value
end

function Db:Reset(key)
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

setmetatable(Db, mt)
