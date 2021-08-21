local GamemodeConfigScene = Scene:extend()

GamemodeConfigScene.title = "Gamemode Configuration"

local selected_mode = {}
local mode_config = {}
local new_config = {}
local optioncount = 1

function GamemodeConfigScene:new(gamemode)
    selected_mode = gamemode
    mode_config = gamemode:provideSettings() or {}
    optioncount = #mode_config

    self.highlight = 1

    for i, j in pairs(mode_config) do
        new_config[j[1]] = config.gamemodesettings[selected_mode.hash][j[1]] or 1
    end

    DiscordRPC:update({
		details = "In menus",
		state = "Configuring "..selected_mode.name,
	})
end

function GamemodeConfigScene:save()
    config.gamemodesettings[selected_mode.hash] = new_config
end

function GamemodeConfigScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(
		backgrounds["game_config"],
		0, 0, 0,
		0.5, 0.5
	)

	love.graphics.setFont(font_3x5_4)
	love.graphics.print(string.upper(selected_mode.name).." SETTINGS", 80, 40)
    love.graphics.setFont(font_3x5_2)

    if #mode_config == 0 then
        love.graphics.print("This mode does not offer any settings.\n"..
                            "Press Backspace to return to mode select.", 40, 100)
        return
    end

    love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.rectangle("fill", 25, 98 + self.highlight * 20, 170, 22)

    for i, option in ipairs(mode_config) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(option[2], 40, 100 + i * 20, 150, "left")

        if #option[3] <= 4 then
            for j, setting in ipairs(option[3]) do
                love.graphics.setColor(1, 1, 1, new_config[option[1]] == j and 1 or 0.5)
                love.graphics.printf(setting, 100 + 110 * j, 100 + i * 20, 100, "center")
            end
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(option[3][new_config[option[1]]], -- what an indexer
                                100 + 110 * 1, 100 + i * 20, 100, 'center')
        end
	end
end

function GamemodeConfigScene:onInputPress(e)
    if e.input == "menu_back" or e.scancode == "delete" or e.scancode == "backspace" then
        scene = ModeSelectScene()
    elseif e.input == "menu_decide" then
        playSE("mode_decide")
        self:save()
        saveConfig()
        scene = ModeSelectScene()
    end

    if #mode_config == 0 then return end

    if e.input == "up" or e.scancode == "up" then
        playSE("cursor")
        self.highlight = Mod1(self.highlight-1, optioncount)
    elseif e.input == "down" or e.scancode == "down" then
        playSE("cursor")
        self.highlight = Mod1(self.highlight+1, optioncount)
    elseif e.input == "left" or e.scancode == "left" then
        playSE("cursor_lr")
        local option = mode_config[self.highlight]
        new_config[option[1]] = Mod1(new_config[option[1]]-1, #option[3])
    elseif e.input == "right" or e.scancode == "right" then
        playSE("cursor_lr")
        local option = mode_config[self.highlight]
        new_config[option[1]] = Mod1(new_config[option[1]]+1, #option[3])
    end
end

return GamemodeConfigScene
