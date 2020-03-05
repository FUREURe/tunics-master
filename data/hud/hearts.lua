-- Hearts view used in game screen and in the savegames selection screen.

local hearts = {}

function hearts:new(game)

  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(game)

  return object
end

function hearts:initialize(game)

  self.game = game
  self.surface = sol.surface.create(71, 25)
  self.dst_x = 0
  self.dst_y = 0
  self.empty_heart_sprite = sol.sprite.create("hud/empty_heart")
  self.nb_max_hearts_displayed = game:get_max_life() / 4
  self.nb_current_hearts_displayed = game:get_life()
  self.all_hearts_img = sol.surface.create("hud/hearts.png")
  self.hearts_title_img = sol.surface.create("hearts_title.png",true)
end

function hearts:on_started()

  -- This function is called when the HUD starts or
  -- was disabled and gets enabled again.
  -- Unlike other HUD elements, the timers were canceled because they
  -- are attached to the menu and not to the game
  -- (this is because the hearts are also used in the savegame menu).
  self.danger_sound_timer = nil
  self:check()
  self:rebuild_surface()
  self.hearts_title_img:draw_region(0, 0, 44, 10, self.surface, 14, 0)
end

-- Checks whether the view displays the correct info
-- and updates it if necessary.
function hearts:check()

  local need_rebuild = false

  -- Maximum life.
  local nb_max_hearts = self.game:get_max_life() / 4
  if nb_max_hearts ~= self.nb_max_hearts_displayed then
    need_rebuild = true

    if nb_max_hearts < self.nb_max_hearts_displayed then
      -- Decrease immediately if the max life is reduced.
      self.nb_current_hearts_displayed = self.game:get_life()
    end

    self.nb_max_hearts_displayed = nb_max_hearts
  end

  -- Current life.
  local nb_current_hearts = self.game:get_life()
  if nb_current_hearts ~= self.nb_current_hearts_displayed then

    need_rebuild = true
    if nb_current_hearts < self.nb_current_hearts_displayed then
      self.nb_current_hearts_displayed = self.nb_current_hearts_displayed - 1
    else
      self.nb_current_hearts_displayed = self.nb_current_hearts_displayed + 1
      if self.game:is_started()
          and self.nb_current_hearts_displayed % 4 == 0 then
        sol.audio.play_sound("heart")
      end
    end
  end

  -- If we are in-game, play a sound if the life is low.
  if self.game:is_started() then

    if self.game:get_life() <= self.game:get_max_life() / 4
        and not self.game:is_suspended() then
      need_rebuild = true

      if self.danger_sound_timer == nil then
        self.danger_sound_timer = sol.timer.start(self, 250, function()
          self:repeat_danger_sound()
        end)
        self.danger_sound_timer:set_suspended_with_map(true)
      end
    end
  end

  -- Redraw the surface only if something has changed.
  if need_rebuild then
    self:rebuild_surface()
  end

  -- Schedule the next check.
  sol.timer.start(self, 50, function()
    self:check()
  end)
end

function hearts:repeat_danger_sound()

  if self.game:get_life() <= self.game:get_max_life() / 4 then

    sol.audio.play_sound("danger")
    self.danger_sound_timer = sol.timer.start(self, 750, function()
      self:repeat_danger_sound()
    end)
    self.danger_sound_timer:set_suspended_with_map(true)
  else
    self.danger_sound_timer = nil
  end
end

function hearts:rebuild_surface()

	self.surface:clear()

	self.hearts_title_img:draw_region(0, 0, 44, 10, self.surface, 14, 0)
  
	-- Display the hearts.
	for i = 0, self.nb_max_hearts_displayed - 1 do
		local x, y = (i % 10) * 8, math.floor(i / 10) * 8 + 10
		self.empty_heart_sprite:draw(self.surface, x, y)
		if i < math.floor(self.nb_current_hearts_displayed / 4) then
		-- This heart is full.
		self.all_hearts_img:draw_region(21, 0, 8, 7, self.surface, x, y)
		end
	end

	-- Last fraction of heart.
	local i = math.floor(self.nb_current_hearts_displayed / 4)
	local remaining_fraction = self.nb_current_hearts_displayed % 4
	if remaining_fraction ~= 0 then
		local x, y = (i % 10) * 8, math.floor(i / 10) * 8 + 10
		self.all_hearts_img:draw_region((remaining_fraction - 1) * 7, 0, 7, 7, self.surface, x, y)
	end
end

function hearts:set_dst_position(x, y)
  self.dst_x = x
  self.dst_y = y
end

function hearts:on_draw(dst_surface)

  local x, y = self.dst_x, self.dst_y
  local width, height = dst_surface:get_size()
  if x < 0 then
    x = width + x
  end
  if y < 0 then
    y = height + y
  end

  -- Everything was already drawn on self.surface.
  self.surface:draw(dst_surface, x, y)
end

return hearts

