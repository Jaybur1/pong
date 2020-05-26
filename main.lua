-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
push = require "push"

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods

Class = require "class"

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require "Paddle"

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require "Ball"

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

  -- set a title to our app window
  love.window.setTitle("Pong")

  -- "seed" the RNG so that calls to random are always random
  -- use the current time, since that will vary on startup every time
  math.randomseed(os.time())

  -- 'retro-looking' font object we can use for text
  smallFont = love.graphics.newFont("font.ttf", 8)

  -- larger font for the scoring
  largeFont = love.graphics.newFont("font.ttf", 32)

  -- set love2d active font to smallFont object
  love.graphics.setFont(smallFont)

  -- set up our sound effects; later, we can just index this table and
  -- call each entry's `play` method

  sounds = {
    ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
    ["score"] = love.audio.newSource("sounds/score.wav", "static"),
    ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static")
  }

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

  -- either going to be 1 or 2; whomever is scored on gets to serve the
  -- following turn
  servingPlayer = 1

  -- init score
  player1Score = 0
  player2Score = 0

  -- init players paddles
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

  -- place a ball in the middle of the screen
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

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
  if gameState == "serve" then
    -- before switching to play, initialize ball's velocity based
    -- on player who last scored
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end
  elseif gameState == "play" then
    -- detect ball collision with paddles, reversing dx if true and
    -- slightly increasing it, then altering the dy based on the position of collision
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
      sounds["paddle_hit"]:play()
    end

    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
      sounds["paddle_hit"]:play()
    end

    -- detect upper and lower screen boundary collision and reverse if collided
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      sounds["wall_hit"]:play()
    end

    -- -4 to account for the ball's size
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
      sounds["wall_hit"]:play()
    end

    -- if we reach the left or right edge of the screen,
    -- go back to start and update the score
    if ball.x < 0 then
      servingPlayer = 1
      player2Score = player2Score + 1
      sounds["score"]:play()
      -- if we've reached a score of 10, the game is over; set the
      -- state to done so we can show the victory message
      if player2Score == 10 then
        winningPlayer = 2
        gameState = "done"
      else
        gameState = "serve"
        -- places the ball in the middle of the screen, no velocity
        ball:reset()
      end
    end

    if ball.x > VIRTUAL_WIDTH then
      servingPlayer = 2
      player1Score = player1Score + 1
      sounds["score"]:play()

      if player1Score == 10 then
        winningPlayer = 1
        gameState = "done"
      else
        gameState = "serve"
        ball:reset()
      end
    end
  end

  -- player 1 movement
  if love.keyboard.isDown("w") then
    player1.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown("s") then
    player1.dy = PADDLE_SPEED
  else
    player1.dy = 0
  end

  -- player 2 movement
  if love.keyboard.isDown("up") then
    player2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown("down") then
    player2.dy = PADDLE_SPEED
  else
    player2.dy = 0
  end

  -- update our ball based on its DX and DY only if we're in play state;
  -- scale the velocity by dt so movement is framerate-independent
  if gameState == "play" then
    ball:update(dt)
  end

  player1:update(dt)
  player2:update(dt)
end

function love.keypressed(key)
  if key == "escape" then
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    love.event.quit()
  elseif key == "enter" or key == "return" then
    if gameState == "start" then
      gameState = "serve"
    elseif gameState == "serve" then
      gameState = "play"
    elseif gameState == "done" then
      -- game is simply in a restart phase here, but will set the serving
      -- player to the opponent of whomever won for fairness!
      gameState = "serve"

      ball:reset()

      -- reset scores to 0
      player1Score = 0
      player2Score = 0

      -- decide serving player as the opposite of who won
      if winningPlayer == 1 then
        servingPlayer = 2
      else
        servingPlayer = 1
      end
    end
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
  love.graphics.clear(115 / 255, 27 / 255, 135 / 255, 50 / 100)

  displayScore()

  if gameState == "start" then
    love.graphics.setFont(smallFont)
    love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press Enter to begin!", 0, 20, VIRTUAL_WIDTH, "center")
  elseif gameState == "serve" then
    love.graphics.setFont(smallFont)
    love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press Enter to serve!", 0, 20, VIRTUAL_WIDTH, "center")
  elseif gameState == "play" then
    -- no UI messages to display in play
  elseif gameState == "done" then
    -- UI messages
    love.graphics.setFont(largeFont)
    love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press Enter to restart!", 0, 50, VIRTUAL_WIDTH, "center")
  end
  -- render first paddle (left side)
  player1:render()

  -- render second paddle (right side)
  player2:render()

  -- render the ball
  ball:render()

  -- show fps indicator
  displayFPS()

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

--[[
  renders the current FPS
]]
function displayFPS()
  -- simple FPS display across all states

  love.graphics.setFont(smallFont)
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
  -- draw score on the left and right center of the screen
  -- need to switch font to draw before actually printing
  love.graphics.setFont(largeFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end
