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

{database: db, localization: L, :log, :number, xp_manager: xp} = T

{:IsControlKeyDown, :IsShiftKeyDown, :LibStub} = _G

ldb = LibStub\GetLibrary 'LibDataBroker-1.1'
icon = LibStub\GetLibrary 'LibDBIcon-1.0'

data =
    type: 'data source'
    label: NAME
    icon: "Interface\\AddOns\\#{NAME}\\icon.tga"
    tocname: NAME
    text: L.b_text_empty

click_handlers =
    none:
        LeftButton: ->
            data = xp\get_self!
            current_xp = number.format data.current_xp
            max_xp = number.format data.max_xp
            T.chat\send L.chat_xp_report data.level,
                    current_xp, max_xp, data.percentage

tooltip_visible = false

obj = ldb\NewDataObject "Broker_#{NAME}", data

obj.OnTooltipShow = =>
    if xp\has_data!
        @AddLine L.b_header_xp
        @AddLine ' ' -- Separator
        for name, data in pairs xp.data
            with data
                left = '%s [%d]'\format .friendly_name, .current_level
                right = '%s/%s (%d%%)'\format number.format(.current_xp), number.format(.max_xp), .percentage
                @AddDoubleLine left, right, 1, 1, 1, 1, 1, 1
    else
        @AddLine L.b_header_empty!
    @AddLine ' ' -- Separator
    @AddDoubleLine L.leftclick!, L.b_announce_smart!, 0, 1, 0, 0, 1, 0

obj.OnClick = (button) =>
    mod = ((IsControlKeyDown! and 'ctrl') or (IsShiftKeyDown! and 'shift')) or 'none'
    return unless click_handlers[mod]
    func = click_handlers[mod][button]
    func! if func

update = ->
    GameTooltip\ClearLines!
    obj.OnTooltipShow GameTooltip
    GameTooltip\Show!
    tooltip_visible = true

obj.OnEnter = =>
    GameTooltip\SetOwner @, 'ANCHOR_NONE'
    GameTooltip\SetPoint 'TOPLEFT', @, 'BOTTOMLEFT'
    update!

obj.OnLeave = =>
    GameTooltip\Hide!
    tooltip_visible = false

icon_settings_table = setmetatable {},
    __index: (key) =>
        db "broker.minimap.#{key}"
    __newindex: (key, value) =>
        db\set "broker.minimap.#{key}", value

T.SHAREXP_DB_LOADED = (event, database) ->
    return unless database.global_name == db.global_name
    -- Set minimap icon defaults
    db 'broker.minimap.lock', false
    db 'broker.minimap.hide', true
    icon\Register NAME, obj, icon_settings_table

T.SHAREXP_XP_UPDATED = ->
    obj.text = "#{NAME}: Allan please add updating text"
    update! if tooltip_visible

T.broker =
    set_minimap: (enabled) =>
        -- Invert `enabled` since we're setting the 'hide' key
        db\set 'broker.minimap.hide', not enabled
        if enabled then icon\Show NAME else icon\Hide NAME

    reset_minimap: =>
        db\reset 'broker.minimap.hide'
        if db 'broker.minimap.hide' then icon\Show NAME else icon\Hide NAME

    toggle_minimap: =>
        @set_minimap db 'broker.minimap.hide'

    is_minimap_enabled: =>
        not db 'broker.minimap.hide'
