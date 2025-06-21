local moonshine = require 'moonshine'

local speedLeft = 5
local speedRight = 5
local paddleYLeft = (720 / 2) - 100
local paddleYRight = (720 / 2) - 100

local paddleMargin = 40

local paused = False

local ballX = 1280 / 2
local ballY = 720 / 2
local ballSpeed = 5;
local ballMovementX = 1;
local ballMovementY = 1;

local scoreLeft = 0;
local scoreRight = 0;

local font = nil
local fpsFont = nil
local difficultyFont = nil

local scene = "Menu"

local logo = nil

local pressEnterFont = nil

local speedProgressionRate = 0.1

local difficulty = "normal"
local difficulties = {"easy", "normal", "hard"}
local speedRates = {0.035, 0.1, 0.35}
local ballSpeeds = {2, 5, 8}
local diffIndex = 2

local wallSound = nil
local paddleSound = nil
local pointSound = nil

local shotDir = nil

local shotDuration = 5
local shotTicks = shotDuration * love.timer.getFPS()
local ticksFromShot = 0
local currShot = nil
local shotted = false -- gets reset after we've dealt with the screenshot. why do you NEED to wait until the next frame???

function exists(thing) return thing == nil end -- possible because lua is stupid and returns nil instead of throwing error when trying to get value

function love.graphics._effectCodeToGLSL(code) return code end

function love.load()
    love.window.setMode(1280, 720)
    love.graphics.setBackgroundColor(0.05, 0.05, 0.05)
    love.window.setTitle("Pong - "..scene)
    font = love.graphics.newFont("bit5x3.ttf", 250)
    fpsFont = love.graphics.newFont("bit5x3.ttf", 15)
    pressEnterFont = love.graphics.newFont("bit5x3.ttf", 100)
    difficultyFont = love.graphics.newFont("bit5x3.ttf", 60)
    logo = love.graphics.newImage("images/logo.png")

    wallSound = love.audio.newSource("sounds/wall.wav", "static")
    paddleSound = love.audio.newSource("sounds/paddle.wav", "static")
    pointSound = love.audio.newSource("sounds/point.wav", "static")
    --shader = love.graphics.newShader("vcr.fs")
    --shader:send("iChannel", love.graphics.getCanvas())
    --shader:send("iResolution", {5, 5, 5})
    --love.graphics.setShader(shader)
    effect = moonshine(moonshine.effects.crt)
    effect.chain(moonshine.effects.chromasep)
    effect.chain(moonshine.effects.boxblur)
    effect.chain(moonshine.effects.pixelate)
    effect.chain(moonshine.effects.scanlines)
    effect.chain(moonshine.effects.filmgrain)
    effect.chain(moonshine.effects.desaturate)
    effect.chain(moonshine.effects.vignette)
    effect.chromasep.radius = 2
    effect.pixelate.size = {2, 2}
    effect.scanlines.opacity = 0.2
    effect.desaturate.tint = {100, 100, 100}
    effect.disable("desaturate")
    effect.filmgrain.size = 17
end

-- success, valueOrErrormsg = runFile( name )
local function runFile(name)
	local ok, chunk, err = pcall(love.filesystem.load, name) -- load the chunk safely
	if not ok    then  return false, "Failed loading code: "..chunk  end
	if not chunk then  return false, "Failed reading file: "..err    end

	local ok, value = pcall(chunk) -- execute the chunk safely
	if not ok then  return false, "Failed calling chunk: "..tostring(value)  end

	return true, value -- success!
end

function goToMenu()
    width, height, flags = love.window.getMode()
    scene = "Menu"
    effect.disable("desaturate")
    paused = false
    ballX = width / 2
    ballY = height / 2
    paddleYLeft = (height / 2) - 100
    paddleYRight = (height / 2) - 100
    ballMovementX = 1;
    ballMovementY = 1;
    scoreLeft = 0;
    scoreRight = 0;
    speedLeft = 5
    speedRight = 5
    ballSpeed = ballSpeeds[diffIndex]
end

function changeDiff(dir)
    love.audio.play(wallSound)
    if dir == -1 then
        diffIndex = diffIndex - 1
        if diffIndex < 1 then
            diffIndex = #difficulties
        end
        difficulty = difficulties[diffIndex]
    end
    if dir == 1 then
        diffIndex = diffIndex + 1
        if diffIndex > #difficulties then
            diffIndex = 1
        end
        difficulty = difficulties[diffIndex]
    end
end

function goToGame()
    love.audio.play(paddleSound)
        for i, f in ipairs(love.filesystem.getDirectoryItems("scripts")) do
            if string.find(f, ".lua") then
                runFile("scripts/"..f)
            end
        end
    scene = "Game"
    speedProgressionRate = speedRates[diffIndex]
end

function love.keypressed(key, scancode)
    width, height, flags = love.window.getMode()
    if scene == "Menu" then
        dir = 1
        if key == "left" or key == "a" then
            dir = -1
        end
        if key == "left" or key == "a" or key == "right" or key == "d" then
            changeDiff(dir)
        end
    end
    if key == "escape" and scene == "Game" then
        paused = not paused
        if paused then
            effect.enable("desaturate")
        else
            effect.disable("desaturate")
        end
    end
    if key == "return" and scene == "Menu" then
        goToGame()
    end
    if key == "backspace" and scene == "Game" and paused then
        goToMenu()
    end
    if key == "f2" then
        Now = os.date('%d-%m-%Y %H-%M-%S') --get the date/time
        love.window.showMessageBox("awfawfawf", Now..".png", "info")
        love.graphics.captureScreenshot(Now..".png")
        shotDir = love.filesystem.getSaveDirectory().."/"..Now..".png"
        ticksFromShot = 0
        shotTicks = shotDuration * love.timer.getFPS()
        --shotted = true
    end
end

function dashLine( p1, p2, dash, gap )
	local dy, dx	= p2.y - p1.y, p2.x - p1.x
	local an, st	= math.atan2( dy, dx ), dash + gap
	local len		= math.sqrt( dx*dx + dy*dy )
	local nm		= ( len - dash ) / st
	love.graphics.push()
	love.graphics.translate( p1.x, p1.y )
	love.graphics.rotate( an )
	for i = 0, nm do
		--love.graphics.setColor(i*255/nm,255*(nm-i)/nm,0)
        love.graphics.setLineWidth(4)
		love.graphics.line( i * st, 0, i * st + dash, 0 )
		end
    love.graphics.line( nm * st, 0, nm * st + dash,0 )
    love.graphics.pop()
end

function dottedLine(x, y, height)
    local newY = height/6
    for i=0, height/6 do
        love.graphics.line(x, y, x, newY)
        newY = newY + (height / 6) + 5
    end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function love.errorhandler(msg)
    msg = tostring(msg)
    love.window.showMessageBox("Fatal Error", msg, "error")
    love.window.close()
end

function love.gamepadpressed(joystick, button)
    width, height, flags = love.window.getMode()
    if scene == "Menu" then
        dir = 1
        if button == "dpleft" then
            dir = -1
        end
        if button == "dpleft" or button == "dpright" then
            changeDiff(dir)
        end
    end
    if button == "a" and scene == "Menu" then
        goToGame()
    end
    if button == "start" and scene == "Game" then
        paused = not paused
        if paused then
            effect.enable("desaturate")
        else
            effect.disable("desaturate")
        end
    end
    if button == "b" and paused then
        goToMenu()
    end
end

local actualShotted = false

function love.draw()
    love.window.setTitle("Pong - "..scene)
    width, height, flags = love.window.getMode()
    love.graphics.setFont(font)
    ticksFromShot = ticksFromShot + 1
    if ticksFromShot >= shotTicks then
        shotDir = nil
        currShot = nil
    end
    if actualShotted then
        currShot = love.graphics.newImage(shotDir)
        shotted = false
        actualShotted = false
    end
    
    effect(function ()
        if scene == "Game" then
            scores = ""..scoreLeft.." "..scoreRight
            love.graphics.print(scores, (width / 2) - (font:getWidth(scores) / 2), 50)

            love.graphics.rectangle("fill", paddleMargin, paddleYLeft, 50, 200)
            love.graphics.rectangle("fill", width - (50 + paddleMargin), paddleYRight, 50, 200)

            love.graphics.rectangle("fill", ballX, ballY, 10, 10)
            dashLine({x=width / 2, y=0}, {x=width / 2, y=height}, 8, 8)
            if paused then
                --effect.disable("desaturate")
                love.graphics.print("PAUSED", (width / 2) - (font:getWidth("PAUSED") / 2), (height / 2) - (font:getHeight() / 2))
                --effect.enable("desaturate")
            end
            if not paused then
                sticks = love.joystick.getJoysticks()
                for i, joystick in ipairs(sticks) do
                    if i == 1 then
                        paddleYLeft = paddleYLeft + (joystick:getGamepadAxis("lefty") * speedLeft)
                        if love.joystick.getJoystickCount() == 1 then
                            paddleYRight = paddleYRight + (joystick:getGamepadAxis("righty") * speedRight)
                        end
                        if joystick:isGamepadDown("dpup") then
                            paddleYLeft = paddleYLeft - speedLeft
                        end
                        if joystick:isGamepadDown("dpdown") then
                            paddleYLeft = paddleYLeft + speedLeft
                        end
                    end
                    if i == 2 then
                        paddleYRight = paddleYRight - (joystick:getGamepadAxis("lefty") * speedRight)
                        if joystick:isGamepadDown("dpup") then
                            paddleYRight = paddleYRight - speedRight
                        end
                        if joystick:isGamepadDown("dpdown") then
                            paddleYRight = paddleYRight + speedRight
                        end
                    end
                end
                if love.keyboard.isDown("w") then
                    paddleYLeft = paddleYLeft - speedLeft
                end
                if love.keyboard.isDown("s") then
                    paddleYLeft = paddleYLeft + speedLeft
                end
                if love.keyboard.isDown("up") then
                    paddleYRight = paddleYRight - speedRight
                end
                if love.keyboard.isDown("down") then
                    paddleYRight = paddleYRight + speedRight
                end
                ballX = ballX + (ballSpeed * ballMovementX)
                ballY = ballY + (ballSpeed * ballMovementY)
                
                if ballY > height - 10 or ballY < 0 then
                    love.audio.play(wallSound)
                    ballMovementY = 0 - ballMovementY;
                    ballSpeed = ballSpeed + speedProgressionRate
                    speedLeft = speedLeft + speedProgressionRate
                    speedRight = speedRight + speedProgressionRate
                end
                if CheckCollision(paddleMargin, paddleYLeft, 50, 200, ballX, ballY, 10, 10) then
                    love.audio.play(paddleSound)
                    ballMovementX = 1
                    ballSpeed = ballSpeed + speedProgressionRate
                    speedLeft = speedLeft + speedProgressionRate
                    speedRight = speedRight + speedProgressionRate
                end
                if CheckCollision(1280 - (50 + paddleMargin), paddleYRight, 50, 200, ballX, ballY, 10, 10) then
                    love.audio.play(paddleSound)
                    ballMovementX = -1
                    ballSpeed = ballSpeed + speedProgressionRate
                    speedLeft = speedLeft + speedProgressionRate
                    speedRight = speedRight + speedProgressionRate
                end
                if ballX < 0 then
                    love.audio.play(pointSound)
                    scoreRight = scoreRight + 1
                    ballX = width / 2
                end
                if ballX > width then
                    love.audio.play(pointSound)
                    scoreLeft = scoreLeft + 1
                    ballX = width / 2
                end
            end
        elseif scene == "Menu" then
            love.graphics.draw(logo, (width / 2) - (logo:getWidth() / 2), 100)
            love.graphics.setFont(difficultyFont)
            --love.graphics.print("diffIndex="..diffIndex, 0, 20)
            if difficulty == nil then
                difficulty = difficulties[diffIndex]
            end
            --if not difficulty == nil then
                local diffSelTxt = "< "..difficulties[diffIndex].." >"
                love.graphics.print(diffSelTxt, (width / 2) - (difficultyFont:getWidth(diffSelTxt) / 2), (height / 2) + 30)
            --end
            love.graphics.setFont(pressEnterFont)
            love.graphics.print("PRESS ENTER TO PLAY", (width / 2) - (pressEnterFont:getWidth("PRESS ENTER TO PLAY") / 2), height - (pressEnterFont:getHeight() + 50))
        end
    end)
    love.graphics.setFont(fpsFont)
    love.graphics.print("FPS: "..love.timer.getFPS(), 2, 2)
    if shotDir == nil then
        shotDir = ""
    end
    if not currShot == nil then
        love.graphics.draw(currShot, 0, 40 + fpsFont:getHeight(), 0, currShot:getWidth() * 0.3, currShot:getHeight() * 0.3)
    end
    actualShotted = shotted
    love.graphics.print(shotDir, 0, 40)
end