local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local async = require('openmw.async')
local util = require('openmw.util')
local ambient = require('openmw.ambient')

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
    removeText: string -- the text to display for the removal button. defaults to 'x'
    buttonWidth: integer -- optional argument to set the width of the text buttons. defaults to 80. if set to 0, buttons will not have a preset width
end

-- huge credit to SosnoviyBor on NexusMods for providing their Text Set Settings Renderer, from which this renderer was derived
I.Settings.registerRenderer('textset', function(input: { string: boolean }, set: function, args: TextSetArgs): any
    if args == nil then args = {} end
    if input == nil then
        input = {}
        set(input)
    end

    local removeText: string = 'x'
    if args.removeText ~= nil and args.removeText ~= "" then
        removeText = args.removeText
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

    header.content:add({
        template = I.MWUI.templates.box,
        content = ui.content({ {
            template = I.MWUI.templates.padding,
            content = ui.content({ {
                template = I.MWUI.templates.textNormal,
                props = {
                    text = "Add",
                },
                events = {
                    mouseClick = async:callback(function()
                        -- no empty strings allowed
                        if inputText == "" then return end
                        if input[inputText] ~= nil then return end -- we only want one instance of this string in our list
						if args.keys ~= nil and #args.keys >= 1 then -- if our whitelist is not empty, compare the new key against it
							local i: integer = 1
							while i <= #args.keys do
								if args.keys[i] == inputText then break end -- check to make sure the key being inserted exist in our whitelist
								i = i + 1
							end
							if i > #args.keys then return end -- if we did not find the new key in our whitelist, return and do not insert the new key into our set
						end
                        if args.lowercase ~= nil and args.lowercase == true then inputText = inputText:lower() end
						input[inputText] = true
                        set(input)
                    end),
                },
            } }),
        } }),
    })

    header.content:add({
        template = I.MWUI.templates.padding,
        external = {
            grow = 1,
        },
    })

    header.content:add({
        template = I.MWUI.templates.box,
        content = ui.content({ {
            template = I.MWUI.templates.padding,
            content = ui.content({ {
                template = I.MWUI.templates.textEditLine,
                events = {
                    textChanged = async:callback(function(text: string)
                        inputText = text
                    end),
                },
            } }),
        } }),
    })

    local body = {
        type = ui.TYPE.Flex,
        content = ui.content({}),
    }

    local function remove(text: string)
        input[text] = nil
    end

    local buttonWidth: integer = 80
    if args.buttonWidth ~= nil and args.buttonWidth > -1 then
        buttonWidth = args.buttonWidth
    end
    for text in pairs(input) do
        local display: string = text
		local alpha: number = 0.5
        if args.pretty == true then display = capitalizeText(text) end
		if input[text] == true then alpha = 1.0 end
        
        body.content:add({
            template = I.MWUI.templates.padding,
        })

        body.content:add({
            template = I.MWUI.templates.box,
            content = ui.content({ {
                template = I.MWUI.templates.padding,
                content = ui.content({ { 
                    type = ui.TYPE.Flex,
                    props = {
                        horizontal = true,
                        arrange = ui.ALIGNMENT.Center,
                    },
                    content = ui.content({
                        {
                            template = I.MWUI.templates.padding,
                            events = {
                                mouseClick = async:callback(function()
                                    remove(text)
                                    set(input)
                                end),
                            },
                            content = ui.content({ {
                                template = I.MWUI.templates.textNormal,
                                props = {
                                    text = removeText,
                                },
                            } }),
                        },
                        {
                            template = I.MWUI.templates.padding,
                            content = ui.content({ {
                                template = I.MWUI.templates.textNormal,
                                props = {
                                    text = '|',
                                },
                            } }),
                        },
                        {
                            template = I.MWUI.templates.padding,
                            events = {
                                mouseClick = async:callback(function()
			                    	input[text] = input[text] == false
                                    set(input)
                                end),
                            },
                            content = ui.content({
                                {
                                    template = I.MWUI.templates.textNormal,
                                    props = { 
                                        text = display,
                                        alpha = alpha,
                                    },
                                },
                                {
                                    template = I.MWUI.templates.interval,
                                    props = {
                                        position = util.vector2(buttonWidth, 0)
                                    },
                                },
                            }),
                        },
                    }),
                } }),
            } }),
        })
    end

    return {
        type = ui.TYPE.Flex,
        content = ui.content {
            header,
            body,
        },
    }
end)

local interface ButtonLabel
    alpha: number -- opacity of the button label
    color: util.Color -- color of the button label
end

local interface ButtonStates
    enabled: ButtonLabel
    disabled: ButtonLabel
    hover: ButtonLabel
    interacted: ButtonLabel
end

local interface MultiSelectArgs
    keys: { string } -- the list of values to render for the setting. regardless of our default values, the only buttons that will display on our settings page is what's passed in to this argument
    aliases: { string: string } -- this optional argument contains a table of aliases to display instead of the raw key for our buttons
    buttonWidth: integer -- optional argument to set the width of the multiselect buttons. defaults to 80
    buttonStates: ButtonStates -- optional argument for setting opacity and color of button label in various states of interaction
end

local function updateButton(state: ButtonLabel, element: ui.Element)
    element.layout.props.textColor = state.color
    element.layout.props.alpha = state.alpha
    element:update()
end

local function unpackButtonStates(userData: ButtonStates, defaultState: ButtonLabel): ButtonStates
    local states: ButtonStates = {}

    -- the button states argument is optional and therefore may be empty or absent entirely. to avoid indexing issues, check to make sure each value is not nil before attempting to use it
    states.disabled = {}
    if userData ~= nil and userData.disabled ~= nil then
        states.disabled.color = userData.disabled.color
        states.disabled.alpha = userData.disabled.alpha
    end
    states.disabled.color = states.disabled.color or defaultState.color
    states.disabled.alpha = states.disabled.alpha or 0.5

    states.enabled = {}
    if userData ~= nil and userData.enabled ~= nil then
        states.enabled.color = userData.enabled.color
        states.enabled.alpha = userData.enabled.alpha
    end
    states.enabled.color = states.enabled.color or defaultState.color
    states.enabled.alpha = states.enabled.alpha or defaultState.alpha

    states.hover = {}
    if userData ~= nil and userData.hover ~= nil then
        states.hover.color = userData.hover.color
        states.hover.alpha = userData.hover.alpha
    end
    states.hover.color = states.hover.color or defaultState.color
    states.hover.alpha = states.hover.alpha or ((states.enabled.alpha + states.disabled.alpha) / 2)

    states.interacted = {}
    if userData ~= nil and userData.interacted ~= nil then
        states.interacted.color = userData.interacted.color
        states.interacted.alpha = userData.interacted.alpha
    end
    states.interacted.color = states.interacted.color or states.hover.color
    states.interacted.alpha = states.interacted.alpha or states.hover.alpha

    return states
end

-- input is a table of default values for the specified keys. if the key used is not present in our buttons argument, however, it will not appear in our settings menu
-- buttons will be our supplied list of buttons. this list represents exactly what buttons are rendered in our settings menu; if a key is not present in our buttons list, it will not be rendered even if input contains it
I.Settings.registerRenderer('multiselect', function(input: { string: boolean }, set: function, args: MultiSelectArgs): any
    local buttonWidth: integer = 80
    local buttonHeld: boolean = false
    local states: ButtonStates
    if input == nil then input = {} end
    if args == nil then args = {} end
    if type(input) == "boolean" then
        local default = input as boolean
        input = { default = default }
    end
	if args.keys ~= nil then
		for _, text in ipairs(args.keys) do
            input[text] = input[text] or input.default or false
		end
	end
    if args.buttonWidth ~= nil then
        buttonWidth = args.buttonWidth
    end

    local body = {
        type = ui.TYPE.Flex,
		props = {
			horizontal = false,
			arrange = ui.ALIGNMENT.Start,
		},
        content = ui.content({}),
    }
    
    for _, key in ipairs(args.keys) do
        local buttonDefault: ButtonLabel = {}
        local label: string = key

        if args.aliases ~= nil and args.aliases[key] ~= nil then label = args.aliases[key] end

        local buttonText = ui.create({
            template = I.MWUI.templates.textNormal,
            props = {
		    	text = label,
		    },
        },{})

        -- before modifying label color or alpha, get its original values. this is helpful in case no text color or alpha is provided for the renderer
        buttonDefault.color = (buttonText.layout.props.textColor as util.Color)
        buttonDefault.alpha = (buttonText.layout.props.alpha as number) or 1.0
        states = unpackButtonStates(args.buttonStates, buttonDefault)

        -- set text label based on initial state of button
        if input[key] == true then
            buttonText.layout.props.textColor = states.enabled.color
            buttonText.layout.props.alpha = states.enabled.alpha
        else
            buttonText.layout.props.textColor = states.disabled.color
            buttonText.layout.props.alpha = states.disabled.alpha
		end

        body.content:add({
            template = I.MWUI.templates.padding,
        })
        body.content:add({
            type = ui.TYPE.Flex,
            props = {
                horizontal = true,
                propagateEvents = false,
            },
            content = ui.content({ {
                template = I.MWUI.templates.box,
                content = ui.content({ {
                    template = I.MWUI.templates.padding,
                    content = ui.content({ {
                        template = I.MWUI.templates.padding,
                        content = ui.content({
                            buttonText,
                            {
                                template = I.MWUI.templates.interval,
                                props = {
                                    position = util.vector2(buttonWidth, 0)
                                },
                            },
                        }),
                    } }),
                }, }),
            } }),
            events = {
                mouseClick = async:callback(function()
                    ambient.playSound('menu click', {})
                end),
                mousePress = async:callback(function()
                    buttonHeld = true
                    updateButton(states.interacted, buttonText)
                end),
                mouseRelease = async:callback(function()
                    updateButton(states.hover, buttonText)
                    buttonHeld = false
					input[key] = input[key] == false
                end),
                focusGain = async:callback(function()
                    if buttonHeld == false then
                        updateButton(states.hover, buttonText)
                    end
                end),
                focusLoss = async:callback(function()
                    if buttonHeld == false then
                        if input[key] == true then
                            updateButton(states.enabled, buttonText)
                        else
                            updateButton(states.disabled, buttonText)
                        end
                    end
                    set(input)
                end),
            },
        })
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
    integer: { string: boolean } -- decide on a key-to-key basis whether user inputs should be rounded to an integer or left a floating point value
    max: { string: number } -- each number in this table is the maximum value that can be set for the setting corresponding to the key
    min: { string: number } -- each number in this table is the minimum value that can be set for the setting corresponding to the key
    aliases: { string: string } -- this optional argument contains a table of aliases to display instead of the raw key for our buttons
end

I.Settings.registerRenderer('multinumber', function(input: { string: number }, set: function, args: MultiNumArgs): any
    local lastInput: { string: number } = {}
    if args == nil then args = {} end
    if input == nil then input = {} end
    if type(input) == "number" then
        local default = input as number
        input = { default = default }
    end
	if args.keys ~= nil then
        for _, k in ipairs(args.keys) do
            input[k] = input[k] or input.default or 0
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

    for _, key in ipairs(args.keys) do
        local label: string = key
        local min: number = nil
        local max: number = nil
        local integer: boolean = nil

        if args.aliases ~= nil and args.aliases[key] ~= nil then label = args.aliases[key] end
        if type(args.min) == "number" then
            min = args.min as number
        elseif type(args.min) == "userdata" and args.min ~= nil then
            min = args.min[key]
        end
        if type(args.max) == "number" then
            max = args.max as number
        elseif type(args.max) == "userdata" and args.max ~= nil then
            max = args.max[key]
        end
        if type(args.integer) == "boolean" then
            integer = args.integer as boolean
        elseif type(args.integer) == "userdata" and args.integer ~= nil then
            integer = args.integer[key]
        end

        if min ~= nil and input[key] < min then
            input[key] = min
            set(input)
        elseif max ~= nil and input[key] > max then
            input[key] = max
            set(input)
        elseif integer == true then
            input[key] = math.floor(input[key] + 0.5)
        end
        
        body.content:add({
            template = I.MWUI.templates.padding,
        })
        body.content:add({
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
                            text = label,
                            textAlignV = ui.ALIGNMENT.Center,
                        },
                    } },
                },
                {
                    template = I.MWUI.templates.padding,
                },
                {
                    template = I.MWUI.templates.box,
                    content = ui.content { {
                        template = I.MWUI.templates.padding,
                        content = ui.content { {
                            template = I.MWUI.templates.textEditLine,
                            props = {
                                text = tostring(input[key]),
                                size = util.vector2(80, 0) -- credit to SosnoviyBor on Nexus mods for making the recommendation to adjust the width of this text edit field to more closely mirror the number renderer
                            },
                            events = {
                                textChanged = async:callback(function(text)
                                    lastInput[key] = tonumber(text)
                                end),
                                focusLoss = async:callback(function()
                                    local num = lastInput[key]
                                    if num == nil then
                                        return
                                    end
                                    if min ~= nil and num < min then
                                        num = min
                                    elseif max ~= nil and num > max then
                                        num = max
                                    elseif integer == true then
                                        num = math.floor(num + 0.5)
                                    end
                                    input[key] = num
                                    set(input)
                                end),
                            },
                        } },
                    } },
                },
            },
        })
    end

    return {
        type = ui.TYPE.Flex,
        content = ui.content {
            body,
        },
    }
end)