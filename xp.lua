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
local Misc = T.Misc

local Comm = T.CommManager

T.XPManager = {
    MaxLevels = {
        [0] = 60, -- Classic/Vanilla
        [1] = 70, -- TBC
        [2] = 80, -- WotLK
        [3] = 85, -- Cataclysm
        [4] = 90, -- MoP
        [5] = 100 -- WoD
    },
    MaxLevel = 255,
    Data = {}
}

local XP = T.XPManager

local function IsAnyNil(...)
    for i = 1, select('#', ...) do
        if type((select(i, ...))) == nil then return true end
    end
    return false
end

function XP:Update(name, currentLevel, maxLevel, currentXp, maxXp)
    name = Misc.FixName(name)
    currentLevel = tonumber(currentLevel)
    maxLevel = tonumber(maxLevel)
    currentXp = tonumber(currentXp)
    maxXp = tonumber(maxXp)
    if IsAnyNil(currentLevel, maxLevel, currentXp, maxXp) then
        Log:Error("Invalid data received from %s", name)
        return
    end
    if not self.Data[name] then
        self.Data[name] = {}
        local realm = name:match("-(.+)$")
        local localRealm = GetRealmName():gsub("%s", "")
        self.Data[name].FriendlyName = (realm == localRealm) and name:match("(.+)-") or name
    end
    local data = self.Data[name]
    data.CurrentLevel = currentLevel
    data.MaxLevel = maxLevel
    data.CurrentXP = currentXp
    data.MaxXP = maxXp
    T.EventManager:Fire("SHAREXP_XP_UPDATED")
    Log:Debug("XP updated for %s", data.FriendlyName)
end

function XP:SendXP()
    local lvl = UnitLevel("player")
    local xp = UnitXP("player")
    local maxXp = UnitXPMax("player")
    Comm:Send('PARTY', 'xpupdate', lvl, self.MaxLevel, xp, maxXp)
    Log:Debug("Sent XP update to party")
end

function XP:RequestXP()
    Comm:Send('PARTY', 'xprequest')
end

function XP:CheckGroup()
    local num = GetNumSubgroupMembers(LE_PARTY_CATEGORY_HOME)
    local group = {}
    for i = 1, num do
        local unit = "party" .. i
        local name, realm = UnitName(unit)
        name = Misc.FixName(name, realm)
        group[name] = true
    end
    for k, _ in pairs(self.Data) do
        if not group[k] then
            Log:Debug("Removing %s from group, no longer present", k)
            self.Data[k] = nil
        end
    end
end

Comm:Add('xpupdate', function(channel, sender, arg, args)
    -- args[1]: current level
    -- args[2]: max level
    -- args[3]: current xp
    -- args[4]: max xp
    Log:Debug("Received XP update from %s:%s", channel, sender)
    XP:Update(sender, args[1], args[2], args[3], args[4])
end)

Comm:Add('xprequest', function(channel, sender, arg, args)
    Log:Debug("Received XP request from %s:%s", channel, sender)
    XP:SendXP()
end)

function T:PLAYER_ENTERING_WORLD()
    XP:SendXP()
    if IsInGroup() then XP:RequestXP() end
end

function T:PLAYER_XP_UPDATE()
    XP:SendXP()
end

function T:GROUP_ROSTER_UPDATE()
    XP:SendXP()
    XP:CheckGroup()
end

function T:SHAREXP_LOADED()
    local expansionLevel = GetExpansionLevel()
    local maxLvl = XP.MaxLevels[expansionLevel]
    XP.MaxLevel = maxLvl
end
