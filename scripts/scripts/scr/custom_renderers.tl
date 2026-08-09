local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local async = require('openmw.async')

local function capitalizeText(text: string): string
    local capitalizedText: string = ""
    local i: integer = 1
    capitalizedText = text:sub(i, i):upper()
	i = i + 1
    while i <= #text do
        local j = text:find(" ", i)
        if j ~= nil then
            capitalizedText = capitalizedText .. text:sub(i, j) .. text:sub(j + 1, j + 1):upper()
            i = j + 2
		else
			break
        end
    end
	capitalizedText = capitalizedText .. text:sub(i, #text)
    return capitalizedText
end

local interface TextSetArgs
    keys: { string } -- optional argument to restrict what keys can be entered by the user. if empty, any keys are valid; otherwise, only inputs matching the contents of this list are accepted
    lowercase: boolean -- if true, all inputs are automatically cast to lowercase when adding to list
    pretty: boolean -- if true, inputs will be made proper case when displaying to the user. the effect is purely visual
end

-- huge credit to SosnoviyBor on NexusMods for providing their Text Set Settings Renderer, from which this renderer was derived
I.Settings.registerRenderer('textset', function(input: { string }, set: function, args: TextSetArgs): any
    if args == nil then args = {} end
    if input == nil then
        input = {}
        set(input)
    end

    local header = {
        type = ui.TYPE.Flex,
        props = {
            horizontal = true,
        },
        content = ui.content({}),
        external = {
            stretch = 1,
        },
    }

    local inputText: string = ''
    header.content:add {
        template = I.MWUI.templates.box,
        content = ui.content { {
            template = I.MWUI.templates.padding,
            content = ui.content { {
                template = I.MWUI.templates.textNormal,
                props = {
                    text = "Add",
                },
                events = {
                    mouseClick = async:callback(function()
                        -- no empty strings allowed
                        if inputText == "" then return end
						for _, v in ipairs(input) do
							if v == inputText then return end -- we only want one instance of this string in our list
						end
						if args.keys ~= nil and #args.keys > 1 then
							local i: integer = 1
							while i <= #args.keys do
								if args.keys[i] == inputText then break end
								i = i + 1
							end
							if i > #args.keys then return end
						end
                        if args.lowercase ~= nil and args.lowercase == true then inputText = inputText:lower() end
						input[#input + 1] = inputText
                        set(input)
                    end),
                },
            } }
        } },
    }
    header.content:add {
        template = I.MWUI.templates.padding,
        external = {
            grow = 1,
        },
    }
    header.content:add {
        template = I.MWUI.templates.box,
        content = ui.content { {
            template = I.MWUI.templates.padding,
            content = ui.content { {
                template = I.MWUI.templates.textEditLine,
                events = {
                    textChanged = async:callback(function(text: string)
                        inputText = text
                    end),
                } },
            } },
        },
    }

    local body = {
        type = ui.TYPE.Flex,
        content = ui.content({}),
    }

    local function remove(text: string)
		for i, v in ipairs(input) do
			if v == text then
				table.remove(input, i)
			end
		end
    end

    for _, text in ipairs(input) do
        local display: string = text
        if args.pretty == true then display = capitalizeText(text) end
        body.content:add {
            template = I.MWUI.templates.padding,
        }
        body.content:add {
            type = ui.TYPE.Flex,
            props = {
                horizontal = true,
                arrange = ui.ALIGNMENT.Center,
            },
            content = ui.content {
                {
                    template = I.MWUI.templates.box,
                    content = ui.content { {
                        template = I.MWUI.templates.padding,
                        content = ui.content { {
                            template = I.MWUI.templates.textNormal,
                            props = { text = "x" },
                            events = {
                                mouseClick = async:callback(function()
                                    remove(text)
                                    set(input)
                                end),
                            },
                        } },
                    } },
                },
                {
                    template = I.MWUI.templates.padding,
                },
                {
                    template = I.MWUI.templates.textNormal,
                    props = { text = display },
                },
            },
        }
    end

    return {
        type = ui.TYPE.Flex,
        content = ui.content {
            header,
            body,
        },
    }
end)

local interface MultiSelectArgs
    keys: { string } -- the list of values to render for the setting. regardless of our default values, the only buttons that will display on our settings page is what's passed in to this argument
    aliases: { string: string } -- this optional argument contains a table of aliases to display instead of the raw key for our buttons
end

-- input is a table of default values for the specified keys. if the key used is not present in our buttons argument, however, it will not appear in our settings menu
-- buttons will be our supplied list of buttons. this list represents exactly what buttons are rendered in our settings menu; if a key is not present in our buttons list, it will not be rendered even if input contains it
I.Settings.registerRenderer('multiselect', function(input: { string: boolean }, set: function, args: MultiSelectArgs): any
    if input == nil then input = {} end
    if args == nil then args = {} end
	if args.keys ~= nil then
		for _, text in ipairs(args.keys) do
			if input[text] == nil then
				input[text] = false
			end
		end
	end

    local body = {
        type = ui.TYPE.Flex,
		props = {
			horizontal = false,
			arrange = ui.ALIGNMENT.Start,
		},
        content = ui.content({}),
    }

    for _, text in ipairs(args.keys) do
		local alpha: number = 0.5
        local display: string = text
        if args.aliases ~= nil and args.aliases[text] ~= nil then display = args.aliases[text] end
		if input[text] == true then
			alpha = 1.0
		end
		
        body.content:add {
            template = I.MWUI.templates.padding
        }
        body.content:add {
            template = I.MWUI.templates.box,
            content = ui.content { {
                template = I.MWUI.templates.padding,
                content = ui.content { {
                    template = I.MWUI.templates.textNormal,
                    props = { 
						text = capitalizeText(display),
						alpha = alpha,
					},
                } },
            } },
            events = {
                mouseClick = async:callback(function()
					input[text] = input[text] == false
                    set(input)
                end),
            },
        }
    end

    return {
        type = ui.TYPE.Flex,
        content = ui.content {
            body,
        },
    }
end)

local interface MultiNumArgs
    keys: { string } -- each key in this list corresponds to an input for this multinum setting
    integer: boolean -- if true, each of the inputs for this multinum will be rounded to the nearest integer value
    max: { string: number } -- each number in this table is the maximum value that can be set for the setting corresponding to the key
    min: { string: number } -- each number in this table is the minimum value that can be set for the setting corresponding to the key
end

I.Settings.registerRenderer('multinumber', function(input: { string: number } , set: function, args: MultiNumArgs): any
    local lastInput: { string: number} = {}
    if args == nil then args = {} end
	if args.keys ~= nil then
        for _, k in ipairs(args.keys) do
            if input[k] == nil then
                input[k] = 0
            end
        end
	end

    local body = {
        type = ui.TYPE.Flex,
		props = {
			horizontal = false,
			arrange = ui.ALIGNMENT.End,
		},
        content = ui.content({}),
    }

    for _, k in ipairs(args.keys) do
        body.content:add {
            template = I.MWUI.templates.padding
        }
        body.content:add {
            type = ui.TYPE.Flex,
            props = {
                horizontal = true,
                arrange = ui.ALIGNMENT.Center,
            },
            content = ui.content { 
                {
                    template = I.MWUI.templates.padding,
                    content = ui.content { {
                        template = I.MWUI.templates.textNormal,
                        props = {
                            text = capitalizeText(k),
                            textAlignV = ui.ALIGNMENT.Center,
                        },
                    } },
                },
                {
                    template = I.MWUI.templates.padding,
                    props = {},
                },
                {
                    template = I.MWUI.templates.box,
                    props = {},
                    content = ui.content { {
                        template = I.MWUI.templates.padding,
                        content = ui.content { {
                            template = I.MWUI.templates.textEditLine,
                            props = {
                                text = tostring(input[k])
                            },
                            events = {
                                textChanged = async:callback(function(text)
                                    lastInput[k] = tonumber(text)
                                end),
                                focusLoss = async:callback(function()
                                    local num = lastInput[k]
                                    if num == nil then
                                        input[k] = 0
                                        set(input)
                                        return
                                    end
                                    if args.integer == true then
                                        num = math.floor(num + 0.5)
                                    end
                                    if args.min[k] ~= nil and num < args.min[k] then
                                        num = args.min[k]
                                    elseif args.max[k] ~= nil and num > args.max[k] then
                                        num = args.max[k]
                                    end
                                    input[k] = num
                                    set(input)
                                end),
                            },
                        } },
                    } },
                }
            },
        }
    end

    return {
        type = ui.TYPE.Flex,
        content = ui.content {
            body,
        },
    }
end)