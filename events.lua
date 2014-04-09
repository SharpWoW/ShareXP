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

assert(type(T.Frame) == "table", "LOAD ORDER ERROR: events.lua loaded before init.lua")

local EVENT_NAME_PATTERN = "^[A-Z_]+$"

local Frame = T.Frame

local wipe = wipe or function(tbl) for k, _ in pairs(tbl) do tbl[k] = nil end end

T.EventManager = {
    Events = {}
}

local EM = T.EventManager

function EM:Handle(frame, event, ...)
    if not self.Events[event] then return end
    for _, handler in pairs(self.Events[event]) do
        handler(T, ...)
    end
end

function EM:Add(event, handler)
    if not self.Events[event] then self.Events[event] = {} end
    table.insert(self.Events[event], handler)
    if not Frame:IsEventRegistered(event) then Frame:RegisterEvent(event) end
end

function EM:Remove(event, handler)
    if not self.Events[event] then return end
    
    for k, h in pairs(self.Events[event]) do
        if h == handler then self.Events[event] = nil end
    end

    if #self.Events[event] == 0 and Frame:IsEventRegistered(event) then
        Frame:UnregisterEvent(event)
    end
end

function EM:RemoveAll(event)
    if not event then
        wipe(self.Events)
        Frame:UnregisterAllEvents()
    else
        if not self.Events[event] then return end
        wipe(self.Events[event])
        if Frame:IsEventRegistered(event) then Frame:UnregisterEvent(event) end
    end
end

function EM:GetHandlers(event)
    if not self.Events[event] then return nil end
    local handlers = {}
    for _, handler in pairs(self.Events[event]) do
        table.insert(handlers, handler)
    end
    return handlers
end

function EM:Fire(event, ...)
    self:Handle(nil, event, ...)
end

Frame:SetScript("OnEvent", function(f, e, ...) EM:Handle(f, e, ...) end)

local mt = {
    __index = function(tbl, key)
        if key:match(EVENT_NAME_PATTERN) then
            return EM:GetHandlers(key)
        else
            return rawget(tbl, key)
        end
    end,
    __newindex = function(tbl, key, value)
        if key:match(EVENT_NAME_PATTERN) then
            EM:Add(key, value)
        else
            rawset(tbl, key, value)
        end
    end
}

setmetatable(T, mt)
