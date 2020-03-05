local game = ...

function game:initialize_hud()

  -- Set up the HUD.
  local hearts_builder = require("hud/hearts")
  local magic_bar_builder = require("hud/magic_bar")
  local amounts_builder = require("hud/amounts")
  local item_icon_builder = require("hud/item_icon")
  
  self.hud = {  -- Array for the hud elements, table for other hud info.
    showing_dialog = false,
    top_left_opacity = 255,
    custom_command_effects = {},
  }

  local menu = hearts_builder:new(self)
  menu:set_dst_position(-104, 4)
  self.hud[#self.hud + 1] = menu

  menu = magic_bar_builder:new(self)
  menu:set_dst_position(7, 5)
  self.hud[#self.hud + 1] = menu

  menu = amounts_builder:new(self)
  menu:set_dst_position(84, 9)
  self.hud[#self.hud + 1] = menu

  menu = item_icon_builder:new(self, 1)
  menu:set_dst_position(27, 5)
  self.hud[#self.hud + 1] = menu
  self.hud.item_icon_1 = menu

  menu = item_icon_builder:new(self, 2)
  menu:set_dst_position(53, 5)
  self.hud[#self.hud + 1] = menu
  self.hud.item_icon_2 = menu

  self:set_hud_enabled(true)

  self:check_hud()
end

function game:quit_hud()

  if self:is_hud_enabled() then
    -- Stop all HUD menus.
    self:set_hud_enabled(false)
  end
  self.hud = nil
end

function game:check_hud()

  local map = self:get_map()
 
  sol.timer.start(self, 50, function()
    self:check_hud()
  end)
end

function game:hud_on_map_changed(map)

  if self:is_hud_enabled() then
    for _, menu in ipairs(self.hud) do
      if menu.on_map_changed ~= nil then
        menu:on_map_changed(map)
      end
    end
  end
end

function game:hud_on_paused()

  if self:is_hud_enabled() then
    for _, menu in ipairs(self.hud) do
      if menu.on_paused ~= nil then
        menu:on_paused()
      end
    end
  end
end

function game:hud_on_unpaused()

  if self:is_hud_enabled() then
    for _, menu in ipairs(self.hud) do
      if menu.on_unpaused ~= nil then
        menu:on_unpaused()
      end
    end
  end
end

function game:is_hud_enabled()
  return self.hud_enabled
end

function game:set_hud_enabled(hud_enabled)

  if hud_enabled ~= self.hud_enabled then
    game.hud_enabled = hud_enabled

    for _, menu in ipairs(self.hud) do
      if hud_enabled then
        sol.menu.start(self, menu)
      else
        sol.menu.stop(menu)
      end
    end
  end
end

function game:get_custom_command_effect(command)

  return self.hud.custom_command_effects[command]
end

-- Make the action (or attack) icon of the HUD show something else than the
-- built-in effect or the action (or attack) command.
-- You are responsible to override the command if you don't want the built-in
-- effect to be performed.
-- Set the effect to nil to show the built-in effect again.
function game:set_custom_command_effect(command, effect)

  if self.hud ~= nil then
    self.hud.custom_command_effects[command] = effect
  end
end

