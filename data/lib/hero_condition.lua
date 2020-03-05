local condition_manager = {}
local in_command_pressed = false
local in_command_release = false
local sword_level = 0

condition_manager.timers = {
  electrocution = nil,
  cursed = nil
}

function condition_manager:initialize(game)
  local hero = game:get_hero()
  hero.condition = {
    electrocution = false,
    cursed = false
  }

  function hero:is_condition_active(condition)
    return hero.condition[condition]
  end

    function hero:set_condition(condition, active)
        hero.condition[condition] = active
    end

  function hero:on_taking_damage(in_damage)
    local damage = in_damage

    if damage == 0 then
      return
    end

    local shield_level = game:get_ability('shield')
    local tunic_level = game:get_ability('tunic')

    local protection_divider = tunic_level * math.ceil(shield_level / 2)
    if protection_divider == 0 then
      protection_divider = 1
    end
    damage = math.floor(damage / protection_divider)

    if damage < 1 then
      damage = 1
    end

    game:remove_life(damage)
  end

  function hero:start_electrocution(delay, damage)
    if hero:is_condition_active('electrocution') then
      return
    end

    hero:freeze()
    hero:set_animation("electrocuted")
    sol.audio.play_sound("shock")

    hero:set_condition('electrocution', true)
    condition_manager.timers['electrocution'] = sol.timer.start(hero, delay, function()
      hero:stop_electrocution(damage)
    end)
  end

  function hero:start_cursed(delay)
    if hero:is_condition_active('cursed') and condition_manager.timers['cursed'] ~= nil then
      condition_manager.timers['cursed']:stop()
    end

    hero:set_condition('cursed', true)
    sword_level = game:get_ability("sword")
    game:set_ability("sword", 0)
    game:start_dialog("_cursed")

    condition_manager.timers['cursed'] = sol.timer.start(hero, delay, function()
      hero:stop_cursed()
    end)
  end

  function hero:stop_electrocution(damage)
    if hero:is_condition_active('electrocution') and condition_manager.timers['electrocution'] ~= nil then
      condition_manager.timers['electrocution']:stop()
    end

    hero:unfreeze()
    hero:set_animation("walking")
    hero:start_hurt(damage)
    hero:set_condition('electrocution', false)
  end

  function hero:stop_cursed()
    if hero:is_condition_active('cursed') and condition_manager.timers['cursed'] ~= nil then
      condition_manager.timers['cursed']:stop()
    end

    hero:set_condition('cursed', false)
    game:set_ability("sword", sword_level)
  end
end

return condition_manager
