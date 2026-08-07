local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local async = require('openmw.async')

local function capitalizeText(text: string): string
	local capitalizedText: string = ""
	for i = 1, (#text) do
		local char = text:sub(i,i)
		local prevChar = text:sub(#capitalizedText, #capitalizedText)
		if i == 1 then
			capitalizedText = char:upper()
		elseif prevChar ~= nil and prevChar == " " then
			capitalizedText = capitalizedText .. char:upper()
		else
			capitalizedText = capitalizedText .. char
		end
	end
	return capitalizedText
end

-- huge credit to SosnoviyBor on NexusMods for providing their Text Set Settings Renderer, from which this renderer was derived
I.Settings.registerRenderer('textset', function(input: { string }, set: function, arguments: { string }): any
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
						if arguments ~= nil then
							local i: integer = 1
							while i <= #arguments do
								if arguments[i] == inputText then break end
								i = i + 1
							end
							if i > #arguments then return end
						end
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
                    props = { text = capitalizeText(text) },
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
    keys: { string }
end

-- input is a table of default values for the specified keys. if the key used is not present in our buttons argument, however, it will not appear in our settings menu
-- buttons will be our supplied list of buttons. this list represents exactly what buttons are rendered in our settings menu; if a key is not present in our buttons list, it will not be rendered even if input contains it
I.Settings.registerRenderer('multiselect', function(input: { string: boolean }, set: function, args: MultiSelectArgs): any
    if input == nil then input = {} end
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
						text = capitalizeText(text),
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
    keys: { string }
    integer: boolean
    max: { string: number }
    min: { string: number }
end

I.Settings.registerRenderer('multinumber', function(input: { string: number } , set: function, args: MultiNumArgs): any
    local lastInput: { string: number} = {}
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