local I = require('openmw.interfaces')
local storage = require('openmw.storage')
local util = require('openmw.util')
local core = require('openmw.core')

local l10n = core.l10n("SorresCustomRenderers", "en")

I.Settings.registerPage {
    key = 'SettingsSorreCustomRenderersTest',
    l10n = 'SorresCustomRenderers',
    name = 'page_name',
    description = 'page_description',
}

I.Settings.registerGroup {
    page = 'SettingsSorreCustomRenderersTest',
    key = 'SettingsSorreCustomRenderersExamples',
    l10n = 'SorresCustomRenderers',
    name = 'example_group_name',
    description = 'example_group_desc',
    permanentStorage = false,
    settings = {
		{
            key = 'textset',
            renderer = 'textset',
            name = 'text_set_name',
            default = { ["only"] = true, ["these"] = false, ["inputs"] = true, }, -- these values will be automatically added if they aren't already
            argument = { 
                keys = { "only", "these", "inputs", "are", "allowed", }, -- any values entered by the user that don't match one of these values will be ignored. this argument is optional; if absent, any inputs are valid. also affects defaults
				lowercase = true, -- if true, all inputs will be cast to lowercase
                pretty = true, -- if true, list entries will be cast to proper case. visual effect only, does not affect the underlying keys
                removeText = l10n('text_set_remove_text'), -- the string that will be used for the remove button
                buttonWidth = 80, -- positive integer value that sets the width of the toggle button. defaults to 80. this value sets the minimum width of the button; if the button's label is longer than the box is wide, the box will stretch to accommodate it. if set to 0, button width will be defined only by the length of their label
            },
            description = 'text_set_desc',
        },
        {
            key = 'multiselect',
            renderer = 'multiselect',
            name = 'multiselect_name',
            default = { ["this"] = false, ["example"] = true, ["is"] = false, ["for"] = false, ["multiselect"] = true, },  -- default on/off states for our chosen buttons
            argument = {
                keys = { "example", "for", "multiselect", "reallyreallyreallyreallyreallyreallylongexample", }, -- this list defines our collection of toggleable buttons. if any buttons are given a default value that don't appear in this list, they will be ignored
				aliases = { -- this table contains aliases for our buttons, to allow for prettier UI while still retaining descriptive keys for indexing
                    ["this"] = l10n("multiselect_this_alias"),
                    ["example"] = l10n("multiselect_example_alias"),
                    ["is"] = l10n("multiselect_is_alias"),
                },
                buttonWidth = 300, -- positive integer value representing the width of our buttons in pixels. defaults to 80. this value represents the minimum width of each button; if a button's label happens to be too long, the box will stretch to accommodate it. if set to 0, buttons will not have a preset width
                buttonStates = {
                    enabled = {
                        alpha = 1.0, -- a number from 0 to 1 representing the opacity of the text, with 1 being opaque and 0 being transparent
                        --color = util.color.rgb(1, 0, 0), -- rgb value for the label text
                    },
                    disabled = {
                        alpha = 0.5,
                        --color = util.color.rgb(0, 0, 1),
                    },
                    hover = {
                        alpha = 1.0,
                        color = util.color.rgb(1, 1, 1),
                    },
                    interacted = {
                        alpha = 1.0,
                        color = util.color.rgb(1, 0, 0),
                    },
                },
            },
            description = 'multiselect_desc',
        },
        {
            key = 'multiselect2',
            renderer = 'multiselect',
            name = 'multiselect2_name',
            default = { ["this"] = false, ["example"] = true, ["is"] = false, ["for"] = false, ["multiselect"] = true, },  -- default on/off states for our chosen buttons
            argument = {
                keys = { "example", "for", "multiselect", "reallyreallyreallyreallyreallyreallylongexample", }, -- this list defines our collection of toggleable buttons. if any buttons are given a default value that don't appear in this list, they will be ignored
				aliases = { -- this table contains aliases for our buttons, to allow for prettier UI while still retaining descriptive keys for indexing
                    ["this"] = l10n("multiselect2_this_alias"),
                    ["example"] = l10n("multiselect2_example_alias"),
                    ["is"] = l10n("multiselect2_is_alias"),
                },
            },
            description = 'multiselect2_desc',
        },
        {
            renderer = "checkbox",
            key = "checkbox",
            name = "checkbox_name",
            default = true,
            description = "checkbox_desc"
        },
		{
            key = 'multinumber',
            renderer = 'multinumber',
            name = 'multinumber_name',
            default = { num1 = 0.01, num2 = 1.00, }, -- default values for chosen inputs
            argument = { 
                keys = { "num1", "num2" }, -- the name of each of our number inputs for this setting
                --integer = { num1 = false, num2 = true }, -- whether inputs should be integer only, or floating point values
                integer = true, -- the integer argument also supports being passed in as just a boolean value, and will force all inputs for this instance of the renderer to an integer or floating point value
                min = { num1 = -10, num2 = -10, }, -- the minimum allowed input for the given field
                max = { num1 = 10, num2 = 10, }, -- the maximum allowed input for the given field
                aliases = { -- aliases for our keys, to allow displaying prettier text for the end user rather than the key used to index each value
                    ["num1"] = l10n("multinumber_num1_alias"),
                    ["num2"] = l10n("multinumber_num2_alias"),
                },
            },
            description = '',
        },
        {
            renderer = "number",
            key = "number",
            name = "number_name",
            default = 0.01,
            description = "number_desc"
        },
    } as {I.Settings.SettingOptions},
}

return {
	engineHandlers = {
		onInit = function()
            storage.playerSection('SettingsSorreCustomRenderersExamples'):setLifeTime(storage.LIFE_TIME.Temporary as storage.LifeTime)
		end,
        onUpdate = function()
            --local settings = storage.playerSection('SettingsSorreCustomRenderersExamples'):get("multiselect") as { string: boolean }
            --print(settings["example"])
        end,
	}
}