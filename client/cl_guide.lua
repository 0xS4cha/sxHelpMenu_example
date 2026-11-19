-- Guide made with the exports only, without the builder.
-- Three pages switched with the page key. It stays open until HideGuide is called,
-- or hides itself after Config.Guide.duration when it is above 0.
-- ShowGuideFromTick shows it only while it is called every tick.

local GUIDE_ID = 'example_guide'

local function buildGuide(duration)
    return {
        id = GUIDE_ID,
        position = Example.GetPosition(Config.Guide.position),
        duration = duration or Config.Guide.duration,
        header = { subtitle = 'sxHelpMenu', title = 'Guide', watermark = 'Help' },
        pages = {
            {
                title = 'Welcome',
                icon = 'hand',
                rows = {
                    { type = 'text', label = 'Server', value = 'Los Santos', icon = 'map-pin' },
                    { type = 'text', label = 'Status', value = 'Online', icon = 'wifi', tone = 'safe' },
                    { type = 'bar', label = 'Players', value = #GetActivePlayers(), max = 64, display = ('%d / 64'):format(#GetActivePlayers()) },
                },
            },
            {
                title = 'Controls',
                icon = 'keyboard',
                rows = {
                    { type = 'text', label = 'Next page', value = 'R', icon = 'arrow-right', tone = 'accent' },
                    { type = 'text', label = 'Phone', value = 'Up arrow', icon = 'smartphone' },
                    { type = 'text', label = 'Inventory', value = 'Tab', icon = 'backpack' },
                },
                footer = { label = 'Bindings', items = { { value = 'Settings', icon = 'settings' } } },
            },
            {
                title = 'Tips',
                icon = 'lightbulb',
                header = { subtitle = 'sxHelpMenu', title = 'Tips', watermark = 'Tips' },
                rows = {
                    { type = 'slider', label = 'Driving', value = 7.5, max = 10 },
                    { type = 'slider', label = 'Shooting', value = 4.2, max = 10, tone = 'warning' },
                    { type = 'slider', label = 'Stamina', value = 2.1, max = 10, tone = 'danger' },
                },
            },
        },
    }
end

local function showGuide(duration)
    return exports.sxHelpMenu:Show(buildGuide(duration))
end

-- Call it every tick: the first call sends the guide, the next ones only keep it alive
-- with its id, and sxHelpMenu hides it when the calls stop.
local function showGuideFromTick()
    if exports.sxHelpMenu:ShowThisFrame(GUIDE_ID) then return end
    exports.sxHelpMenu:ShowThisFrame(buildGuide(0))
end

local function hideGuide()
    return exports.sxHelpMenu:Hide(GUIDE_ID)
end

local function isGuideVisible()
    return exports.sxHelpMenu:IsVisible(GUIDE_ID)
end

exports('ShowGuide', showGuide)
exports('ShowGuideFromTick', showGuideFromTick)
exports('HideGuide', hideGuide)
exports('IsGuideVisible', isGuideVisible)

RegisterCommand(Config.Guide.command, function()
    if isGuideVisible() then
        hideGuide()
        return
    end
    showGuide()
end, false)

RegisterCommand(Config.PositionCommand, function(_, args)
    local position = args[1]
    local valid = {}
    for _, name in ipairs(exports.sxHelpMenu:GetPositions()) do
        valid[name] = true
    end

    if not position or not valid[position] then
        TriggerEvent('chat:addMessage', {
            args = { 'sxHelpMenu', ('Positions: %s'):format(table.concat(exports.sxHelpMenu:GetPositions(), ', ')) },
        })
        return
    end

    Example.SetPosition(position)
    ExampleVehicle.SetPosition(position)
    if exports.sxHelpMenu:IsVisible(GUIDE_ID) then
        exports.sxHelpMenu:Update(GUIDE_ID, { position = position })
    end
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.Guide.command, 'Shows or hides the sxHelpMenu guide')
TriggerEvent('chat:addSuggestion', '/' .. Config.PositionCommand, 'Moves the example menus', {
    { name = 'position', help = 'top-left, top, top-right, left, center, right, bottom-left, bottom, bottom-right' },
})
