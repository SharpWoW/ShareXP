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

{
    comm_manager: comm
    event_manager: em
    localization: L
    :log
    misc:
        :fix_name, :is_any_nil
} = T

{
    :GetExpansionLevel, :GetRealmName, :GetNumSubgroupMembers
    :IsInGroup
    :LE_PARTY_CATEGORY_HOME
    :next
    :UnitLevel, :UnitName, :UnitXP, :UnitXPMax
} = _G

T.xp_manager =
    max_levels:
        [0]: 60  -- Classic/Vanilla
        [1]: 70  -- TBC
        [2]: 80  -- WotLK
        [3]: 85  -- Cataclysm
        [4]: 90  -- MoP
        [5]: 100 -- WoD
    max_level: 255 -- Placeholder/fallback value replaced at load
    data: {}

    has_data: =>
        next(@data) != nil

    update: (name, current_level, max_level, current_xp, max_xp) =>
        name = fix_name name
        current_level = tonumber current_level
        max_level = tonumber max_level
        current_xp = tonumber current_xp
        max_xp = tonumber max_xp

        if is_any_nil current_level, max_level, current_xp, max_xp
            return log\error L.xp.invalid_data, name

        unless @data[name]
            @data[name] = {}
            realm = name\match '-(.+)$'
            local_realm = GetRealmName!\gsub '%s', ''
            @data[name].friendly_name = (realm == local_realm) and name\match('(.+)-') or name

        data = with @data[name]
            .current_level = current_level
            .max_level = max_level
            .current_xp = current_xp
            .max_xp = max_xp
        em\fire 'SHAREXP_XP_UPDATED'
        log\debug L.xp_updated, data.friendly_name

    send_xp: =>
        lvl = UnitLevel 'player'
        xp = UnitXP 'player'
        max_xp = UnitXPMax 'player'
        comm\send 'PARTY', 'xpupdate', lvl, @max_level, xp, max_xp
        log\debug L.xp_sent_update

    request_xp: =>
        comm\send 'PARTY', 'xprequest'
        log\debug L.xp_sent_request

    check_group: =>
        num = GetNumSubgroupMembers LE_PARTY_CATEGORY_HOME
        group = {}
        for i = 1, num
            unit = 'party' .. i
            name, realm = UnitName unit
            name = fix_name name, realm
            group[name] = true

        for k, _ in pairs @data
            unless group[k]
                log\debug L.xp_removing, k
                @data[k] = nil
                em\fire 'SHAREXP_XP_UPDATED'

xp = T.xp_manager

comm\register_callback 'xpupdate', (kind, channel, sender, ...) ->
    -- ARGS:
    -- 1: current level
    -- 2: max level
    -- 3: current xp
    -- 4: max xp
    log\debug L.xp_received_update, channel, sender
    xp\update sender, ...

comm\register_callback 'xprequest', (kind, channel, sender) ->
    log\debug L.xp_received_request, channel, sender
    xp\send_xp!

T.PLAYER_ENTERING_WORLD = ->
    xp\send_xp!
    xp\request_xp! if IsInGroup!

T.PLAYER_XP_UPDATE = ->
    xp\send_xp!

T.GROUP_ROSTER_UPDATE = ->
    xp\send_xp!
    xp\check_group!

T.SHAREXP_LOADED = ->
    expansion_level = GetExpansionLevel!
    max_lvl = xp.max_levels[expansion_level]
    xp.max_level = max_lvl
