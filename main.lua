push = require "push"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200
--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text
  -- and graphics; try removing this function to see the difference!
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- "seed" the RNG so that calls to random are always random
  -- use the current time, since that will vary on startup every time
  math.randomseed(os.time())

  -- 'retro-looking' font object we can use for text
  smallFont = love.graphics.newFont("font.ttf", 8)

  -- larger font for the scoring
  scoreFont = love.graphics.newFont("font.ttf", 12)

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

  -- init score
  player1Score = 0
  player2Score = 0

  -- init players positions
  player1Y = 30
  player2Y = VIRTUAL_HEIGHT - 50

  -- velocity and position variables for our ball when play starts
  ballX = VIRTUAL_WIDTH / 2 - 2
  ballY = VIRTUAL_HEIGHT / 2 - 2
  -- math.random returns a random value between the left and right number
  ballDX = math.random(2) == 1 and 100 or -100
  ballDY = math.random(-50, 50)

  -- game state variable used to transition between different parts of the game
  -- (used for beginning, menus, main game, high score list, etc.)
  -- we will use this to determine behavior during render and update
  gameState = "start"
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
  -- player 1 movement
  if love.keyboard.isDown("w") then
    -- add negative paddle speed to current Y scaled by deltaTime
    player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
  elseif love.keyboard.isDown("s") then
    -- add positive paddle speed to current Y scaled by deltaTime
    player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
  end

  --player 2 movment
  if love.keyboard.isDown("up") and player2Y >= 0 then
    player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
  elseif love.keyboard.isDown("down") then
    player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
  end
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
  -- love.graphics.clear(40, 45, 52, 255)

  -- draw welcome text toward the top of the screen
  love.graphics.printf("Hello Pong!", 0, 20, VIRTUAL_WIDTH, "center")

  -- draw score on the left and right center of the screen
  -- need to switch font to draw before actually printing
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  -- render first paddle (left side)
  love.graphics.rectangle("fill", 10, player1Y, 5, 20)

  -- render second paddle (right side)
  love.graphics.rectangle("fill", VIRTUAL_WIDTH - 10, player2Y, 5, 20)

  -- render the ball
  love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
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
