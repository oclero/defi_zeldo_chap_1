local item = ...

function item:on_created()

  self:set_savegame_variable("possession_sword")
  self:set_sound_when_picked(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
  if item:get_variant() == 3 then
  self:get_game():set_value("get_master_sword",true)
  end
end
