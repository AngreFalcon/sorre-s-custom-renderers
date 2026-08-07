local I = require('openmw.interfaces')
local storage = require('openmw.storage')

I.Settings.registerPage {
    key = 'SettingsSorreCustomRenderersTest',
    l10n = 'SettingsSorreCustomRenderersTest',
    name = 'Sorre\'s Custom Renderers - Examples',
    description = 'Example settings page for Sorre\'s custom renderers.',
}

I.Settings.registerGroup {
    page = 'SettingsSorreCustomRenderersTest',
    key = 'SettingsSorreCustomRenderersExamples',
    l10n = 'SettingsSorreCustomRenderersExamples',
    name = 'Example Settings',
    description = 'Examples for Sorre\'s custom renderers.',
    permanentStorage = false,
    settings = {
		{
            key = 'textset',
            renderer = 'textset',
            name = 'Text Set Renderer',
            default = { "only", "these", "inputs", }, -- these values will be automatically added if they aren't already
            argument = { 
                keys = { "only", "these", "inputs", "are", "allowed", }, -- any values entered by the user that don't match one of these values will be ignored. this argument is optional; if absent, any inputs are valid. also affects defaults
				lowercase = true, -- if true, all inputs will be cast to lowercase
            },
            description = 'Example use-case of the textset renderer.',
        },
        {
            key = 'multiselect',
            renderer = 'multiselect',
            name = 'Multi Select Renderer',
            default = { ["this"] = false, ["example"] = true, ["is"] = false, ["for"] = false, ["multiselect"] = true, },  -- default on/off states for our chosen buttons
            argument = {
                keys = { "example", "for", "multiselect", }, -- this list defines our collection of toggleable buttons. if any buttons are given a default value that don't appear in this list, they will be ignored
				aliases = { ["this"] = "these", ["example"] = "examples", ["is"] = "are", }, -- this table contains aliases for our buttons, to allow for prettier UI while still retaining descriptive keys for indexing
            },
            description = 'Example use-case of the multiselect renderer.',
        },
		{
            key = 'multinumber',
            renderer = 'multinumber',
            name = 'Multi Number Renderer',
            default = { num1 = 0.01, num2 = 1.00, }, -- default values for chosen inputs
            argument = { 
                keys = { "num1", "num2" }, -- the name of each of our number inputs for this setting
                integer = false, -- whether inputs should be integer only, or floating point values
                min = { num1 = -10, num2 = -10, }, -- the minimum allowed input for the given field
                max = { num1 = 10, num2 = 10, }, -- the maximum allowed input for the given field
            },
            description = 'Example use-case of the multinumber renderer.',
        },
    } as {I.Settings.SettingOptions},
}

return {
	engineHandlers = {
		onInit = function()
            storage.playerSection('SettingsSorreCustomRenderersExamples'):setLifeTime(storage.LIFE_TIME.Temporary as storage.LifeTime)
		end,
	}
}