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

local DELIMITER = ';'

T.CommManager = {
    Prefix = NAME:upper(),
    Handlers = {}
}

local Comm = T.CommManager
local Log = T.Log
local Misc = T.Misc

function Comm:Handle(message, channel, sender)
    if not message then return end
    message = message:trim()
    if message == "" then return end
    local di = message:find(DELIMITER)
    local kind = di and message:sub(1, di - 1) or message
    kind = kind:lower()
    
    if not self.Handlers[kind] then return end

    local arg, args
    if di then
        arg = message:sub(di + 1)
        args = {}
        for token in arg:gmatch("[^" .. DELIMITER .. "]+") do
            table.insert(args, token)
        end
    end

    for _, handler in pairs(self.Handlers[kind]) do
        handler(channel, sender, arg, args)
    end
end

--[[
function Comm:Send(channel, target, kind, ...)
    local message = kind
    local args = {...}
    for _, v in ipairs(args) do
        message = message .. ';' .. v
    end
    SendAddonMessage(self.Prefix, message, channel, target)
end
]]

function Comm:Send(channel, ...)
    local target
    local args = {...}
    if channel == "WHISPER" or channel == "CHANNEL" then
        target = args[1]
    end
    local msgIndex = target and 2 or 1
    local message
    for i = msgIndex, #args do
        message = (message and (message .. ';') or '') .. args[i]
    end
    SendAddonMessage(self.Prefix, message, channel, target)
end

function Comm:Add(kind, handler)
    kind = kind:lower()
    if not self.Handlers[kind] then self.Handlers[kind] = {} end
    table.insert(self.Handlers[kind], handler)
end

function Comm:Remove(kind, handler)
    kind = kind:lower()
    if not self.Handlers[kind] then return end
    for k, h in pairs(self.Handlers[kind]) do
        if h == handler then self.Handlers[kind] = nil end
    end
end

function Comm:RemoveAll(kind)
    kind = kind:lower()
    if not self.Handlers[kind] then return end
    wipe(self.Handlers[kind])
end

function T:CHAT_MSG_ADDON(prefix, message, channel, sender)
    if prefix ~= Comm.Prefix or channel ~= "PARTY" then return end
    local fixedSender = Misc.FixName(sender)
    local player = Misc.FixName(UnitName("player"))
    if fixedSender == player then return end
    Comm:Handle(message, channel, sender)
end

function T:SHAREXP_LOADED()
    RegisterAddonMessagePrefix(Comm.Prefix)
end
