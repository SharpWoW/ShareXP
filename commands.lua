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

local Log = T.Log

T.CommandManager = {
    Slash = { "sharexp", "sxp" },
    Commands = {}
}

local CM = T.CommandManager

function CM:Handle(message)
    local name, arg = message:match("^(%w+)(.*)")
    if not name then CM:Help() return end
    name = name:lower()
    local command
    
    for _, cmd in pairs(self.Commands) do
        for _, alias in pairs(cmd[1]) do
            if alias == name then
                command = cmd
                break
            end
        end
    end
    
    if not command then
        T.Log:Error("Invalid command.")
        return
    end

    local args = nil

    if arg then
        arg = arg:trim()
        if arg == "" then
            arg = nil
        else
            args = {}
            for token in arg:gmatch("[^%s]+") do
                table.insert(args, token)
            end
        end
    end

    command[2](arg, args)
end

function CM:Help()
    T.Log:Info("TODO: Add help")
end

function CM:Register(names, handler)
    if type(names) ~= "table" then names = {names} end
    local entry = {names, handler}
    table.insert(self.Commands, entry)
end

CM:Register("debug", function(arg, args)
    if not arg then
        T:ToggleDebug()
    else
        T:SetDebug(arg:match("^[yet]") and true or false)
    end

    Log:Info("Debugging %s!", T:IsDebugEnabled() and "ENABLED" or "DISABLED")
end)

for i, v in ipairs(CM.Slash) do
    _G["SLASH_" .. NAME:upper() .. i] = '/' .. v
end

SlashCmdList[NAME:upper()] = function(msg, editBox)
    CM:Handle(msg)
end
