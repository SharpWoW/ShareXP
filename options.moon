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

{database: db, localization: L, :Logger} = T

local panel

checkbox = (label, description, on_click) ->
    with check = CreateFrame 'CheckButton', "#{NAME}Check#{label}", panel, 'InterfaceOptionsCheckButtonTemplate'
        \SetScript 'OnClick', =>
            PlaySound @GetChecked! and 'igMainMenuOptionCheckBoxOn' or 'igMainMenuOptionCheckBoxOff'
            on_click @, @GetChecked! and true or false
        check.label = with _G["#{check\GetName!}Text"]
            \SetText label
        .tooltipText = label
        .tooltipRequirement = description

panel = with CreateFrame 'Frame'
    .name = NAME
    \Hide!
    \SetScript 'OnShow', =>
        title = with @CreateFontString nil, 'ARTWORK', 'GameFontNormalLarge'
            \SetPoint 'TOPLEFT', 16, -16
            \SetText NAME

        minimap = checkbox L.opt_minimap, L.opt_minimap_desc, (checked) =>
            T.broker\set_minimap checked
        minimap\SetPoint 'TOPLEFT', title, 'BOTTOMLEFT', -2, -16
        minimap\SetChecked T.broker\is_minimap_enabled!

        debug = checkbox L.opt_debug, L.opt_debug_desc, (checked) =>
            T\set_debug checked
        debug\SetPoint 'TOPLEFT', minimap, 'BOTTOMLEFT', 0, -8
        debug\SetChecked T\is_debug_enabled!

        loglevel_dropdown = with CreateFrame 'Frame', "#{NAME}LogLevels", @, 'UIDropDownMenuTemplate'
            \SetPoint 'TOPLEFT', debug, 'BOTTOMLEFT', -15, -10
            .initialize = ->
                for name, value in pairs Logger.levels
                    UIDropDownMenu_AddButton
                        text: name
                        value: value
                        func: =>
                            db\set 'log.level', @value
                            .text\SetText L('opt_loglevel', Logger\level_to_prefix(db('log.level', Logger.levels.INFO)))
                        checked: value == db 'log.level', Logger.levels.INFO
            .text = _G["#{\GetName!}Text"]
            .text\SetText L('opt_loglevel', Logger\level_to_prefix(db('log.level', Logger.levels.INFO)))

        @SetScript 'OnShow', =>
            minimap\SetChecked T.broker\is_minimap_enabled!
            debug\SetChecked T\is_debug_enabled!
            loglevel_dropdown.text\SetText L('opt_loglevel', Logger\level_to_prefix(db('log.level', Logger.levels.info)))

InterfaceOptions_AddCategory panel
