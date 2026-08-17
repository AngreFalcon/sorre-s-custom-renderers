local I = require('openmw.interfaces')
local storage = require('openmw.storage')
local util = require('openmw.util')
local core = require('openmw.core')

local l10n = core.l10n("SorresCustomRenderers", "en")

I.Settings.registerPage({
   key = 'SettingsSorreCustomRenderersTest',
   l10n = 'SorresCustomRenderers',
   name = 'page_name',
   description = 'page_description',
})

I.Settings.registerGroup({
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
         default = { ["only"] = true, ["these"] = false, ["inputs"] = true },
         argument = {
            keys = { "only", "these", "inputs", "are", "allowed" },
            lowercase = true,
            pretty = true,
            removeText = l10n('text_set_remove_text'),
            buttonWidth = 80,
         },
         description = 'text_set_desc',
      },
      {
         key = 'multiselect',
         renderer = 'multiselect',
         name = 'multiselect_name',
         default = { ["this"] = false, ["example"] = true, ["is"] = false, ["for"] = false, ["multiselect"] = true },
         argument = {
            keys = { "example", "for", "multiselect", "reallyreallyreallyreallyreallyreallylongexample" },
            aliases = {
               ["this"] = l10n("multiselect_this_alias"),
               ["example"] = l10n("multiselect_example_alias"),
               ["is"] = l10n("multiselect_is_alias"),
            },
            buttonWidth = 300,
            buttonStates = {
               enabled = {
                  alpha = 1.0,

               },
               disabled = {
                  alpha = 0.5,

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
         default = { ["this"] = false, ["example"] = true, ["is"] = false, ["for"] = false, ["multiselect"] = true },
         argument = {
            keys = { "example", "for", "multiselect", "reallyreallyreallyreallyreallyreallylongexample" },
            aliases = {
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
         description = "checkbox_desc",
      },
      {
         key = 'multinumber',
         renderer = 'multinumber',
         name = 'multinumber_name',
         default = { num1 = 0.01, num2 = 1.00 },
         argument = {
            keys = { "num1", "num2" },

            integer = true,
            min = { num1 = -10, num2 = -10 },
            max = { num1 = 10, num2 = 10 },
            aliases = {
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
         description = "number_desc",
      },
   },
})

return {
   engineHandlers = {
      onInit = function()
         storage.playerSection('SettingsSorreCustomRenderersExamples'):setLifeTime(storage.LIFE_TIME.Temporary)
      end,
      onUpdate = function()


      end,
   },
}
