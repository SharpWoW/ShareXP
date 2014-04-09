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

assert(type(T.EventManager) == "table", "LOAD ORDER ERROR: main.lua was loaded before events.lua")

local Db = T.Database
local EM = T.EventManager

local Debug

function T:ADDON_LOADED(name)
    if name == NAME then
        Db:Load()
        Debug = Db:Get("debug", false)
        EM:Fire(NAME:upper() .. "_LOADED")
    end
end

function T:DebugCheck()
    if not Debug then return end
    if Debug.Value then _G[NAME] = T end
end

function T:SetDebug(enabled)
    if not Debug then return end
    Debug.Value = enabled
    self:DebugCheck()
end

function T:ToggleDebug()
    self:SetDebug(not Debug.Value)
end

function T:IsDebugEnabled()
    if not Debug then return nil end
    return Debug.Value
end
