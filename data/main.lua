-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/solarus/documentation/

local quest_manager = require("scripts/quest_manager")
local game_manager = require("scripts/game_manager")
local debug_menu = require("scripts/debug")
local initial_menus_config = require("scripts/menus/initial_menus_config")
local initial_menus = {}

-- Starts the game passed as parameter.
function sol.main.start_game(game)

  -- Skip initial menus if any.
  -- TODO in 1.2
  -- sol.menu.stop(logo_menu)
  -- sol.menu.stop(savegames_menu)

  sol.main.game = game
  game:start()
end

function sol.main:on_started()

  -- Make quest-specific initializations.
  quest_manager:initialize_quest()

  -- If there is a file called "debug" in the write directory,
  -- enable debug features.
  if sol.file.exists("debug") then
    sol.menu.start(self, debug_menu)
  end


  sol.main.load_settings()
  math.randomseed(os.time())

  -- Show the initial menus.
  if #initial_menus_config == 0 then
    return
  end

  for _, menu_script in ipairs(initial_menus_config) do
    initial_menus[#initial_menus + 1] = require(menu_script)
  end

  local on_top = false  -- To keep the debug menu on top.
  sol.menu.start(sol.main, initial_menus[1], on_top)
  for i, menu in ipairs(initial_menus) do
    function menu:on_finished()
      if sol.main.game ~= nil then
        -- A game is already running (probably quick start with a debug key).
        return
      end
      local next_menu = initial_menus[i + 1]
      if next_menu ~= nil then
        sol.menu.start(sol.main, next_menu)
      end
    end
  end
end

-- Event called when the player pressed a keyboard key.
function sol.main:on_key_pressed(key, modifiers)

  local handled = false
  if key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  end

  return handled
end

-- Returns the font to be used for dialogs
-- depending on the specified language (the current one by default).
function sol.language.get_dialog_font(language)
  -- For now the same font is used by all languages.
  return "dialog"
end

-- Returns the font to be used to display text in menus
-- depending on the specified language (the current one by default).
function sol.language.get_menu_font(language)
  -- For now the same font is used by all languages.
  return "minecraftia"
end

function sol.main:on_finished()
  sol.main.save_settings()
end