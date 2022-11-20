--equipment_hotkey
--data.lua

local SAVE_MODIFIER = "CONTROL"
local LOAD_MODIFIER = "ALT"

data:extend {
    {
        type = "custom-input",
        name = "equipment_hotkey_save_1",
        key_sequence = SAVE_MODIFIER .. " + 1"
    },
    {
        type = "custom-input",
        name = "equipment_hotkey_save_2",
        key_sequence = SAVE_MODIFIER .. " + 2"
    },
    {
        type = "custom-input",
        name = "equipment_hotkey_save_3",
        key_sequence = SAVE_MODIFIER .. " + 3"
    },
    {
        type = "custom-input",
        name = "equipment_hotkey_save_4",
        key_sequence = SAVE_MODIFIER .. " + 4"
    },
    {
        type = "custom-input",
        name = "equipment_hotkey_load_1",
        key_sequence = LOAD_MODIFIER .. " + 1"
    },
    {
        type = "custom-input",
        name = "equipment_hotkey_load_2",
        key_sequence = LOAD_MODIFIER .. " + 2"
    },
    {
        type = "custom-input",
        name = "equipment_hotkey_load_3",
        key_sequence = LOAD_MODIFIER .. " + 3"
    },
    {
        type = "custom-input",
        name = "equipment_hotkey_load_4",
        key_sequence = LOAD_MODIFIER .. " + 4"
    }
}
