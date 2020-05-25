push = require "push"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text
  -- and graphics; try removing this function to see the difference!
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- 'retro-looking' font object we can use for text
  smallFont = love.graphics.newFont("font.ttf", 8)

  -- set love2d active font to smallFont object
  love.graphics.setFont(smallFont)

  push:setupScreen(
    VIRTUAL_WIDTH,
    VIRTUAL_HEIGHT,
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    {
      fullscreen = false,
      resizable = false,
      vsync = true
    }
  )
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
  -- begin rendering at virtual resolution
  push:apply("start")

  -- clear the screen with a specific color; in this case, a color similar
  -- to some versions of the original Pong
  love.graphics.clear(40, 45, 52, 255)

  -- draw welcome text toward the top of the screen
  love.graphics.printf("Hello Pong!", 0, 20, VIRTUAL_WIDTH, "center")

  -- end rendering at virtual resolution
  push:apply("end")

  -- start testing
  -- love.graphics.printf(
  --     'Hello Pong!',          -- text to render
  --     0,                      -- starting X (0 since we're going to center it based on width)
  --     WINDOW_HEIGHT / 2 - 6,  -- starting Y (halfway down the screen)
  --     WINDOW_WIDTH,           -- number of pixels to center within (the entire screen here)
  --     'center')               -- alignment mode, can be 'center', 'left', or 'right'
end
