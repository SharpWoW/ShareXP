return {
    whitelist_globals = {
        ["broker.moon"] = {
            "GameTooltip"
        },
        ["chat.moon"] = {
            "IsInGroup", "IsInRaid", "SendChatMessage",
            "LE_PARTY_CATEGORY_INSTANCE"
        },
        ["commands.moon"] = {
            "SlashCmdList"
        },
        ["events.moon"] = {
            "CreateFrame"
        },
        ["log.moon"] = {
            "DEFAULT_CHAT_FRAME"
        },
        ["options.moon"] = {
            "CreateFrame", "InterfaceOptions_AddCategory", "PlaySound",
            "UIDropDownMenu_AddButton"
        }
    }
}
