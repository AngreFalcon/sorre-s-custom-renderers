local I = require('openmw.interfaces')
local storage = require('openmw.storage')

I.Settings.registerPage({
   key = 'SettingsSorreCustomRenderersTest',
   l10n = 'SettingsSorreCustomRenderersTest',
   name = 'Sorre\'s Custom Renderers - Examples',
   description = 'Example settings page for Sorre\'s custom renderers.',
})

I.Settings.registerGroup({
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
         default = { ["only"] = true, ["these"] = false, ["inputs"] = true },
         argument = {
            keys = { "only", "these", "inputs", "are", "allowed" },
            lowercase = true,
         },
         description = 'Example use-case of the textset renderer.',
      },
      {
         key = 'multiselect',
         renderer = 'multiselect',
         name = 'Multi Select Renderer',
         default = { ["this"] = false, ["example"] = true, ["is"] = false, ["for"] = false, ["multiselect"] = true },
         argument = {
            keys = { "example", "for", "multiselect" },
            aliases = { ["this"] = "these", ["example"] = "examples", ["is"] = "are" },
         },
         description = 'Example use-case of the multiselect renderer.',
      },
      {
         key = 'multinumber',
         renderer = 'multinumber',
         name = 'Multi Number Renderer',
         default = { num1 = 0.01, num2 = 1.00 },
         argument = {
            keys = { "num1", "num2" },
            integer = false,
            min = { num1 = -10, num2 = -10 },
            max = { num1 = 10, num2 = 10 },
         },
         description = 'Example use-case of the multinumber renderer.',
      },
   },
})

return {
   engineHandlers = {
      onInit = function()
         storage.playerSection('SettingsSorreCustomRenderersExamples'):setLifeTime(storage.LIFE_TIME.Temporary)
      end,
   },
}
