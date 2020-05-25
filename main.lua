push = require 'push'


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
    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
      fullscreen = false,
      resizable = false,
      vsync = true
  })
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
-- begin rendering at virtual resolution
push:apply('start')

-- condensed onto one line from last example
-- note we are now using virtual width and height now for text placement
love.graphics.printf('Hello Pong!', 0, VIRTUAL_HEIGHT / 2 - 6, VIRTUAL_WIDTH, 'center')

-- end rendering at virtual resolution
push:apply('end')

-- start testing
    -- love.graphics.printf(
    --     'Hello Pong!',          -- text to render
    --     0,                      -- starting X (0 since we're going to center it based on width)
    --     WINDOW_HEIGHT / 2 - 6,  -- starting Y (halfway down the screen)
    --     WINDOW_WIDTH,           -- number of pixels to center within (the entire screen here)
    --     'center')               -- alignment mode, can be 'center', 'left', or 'right'
end