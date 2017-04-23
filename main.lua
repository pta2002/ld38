PI = 3.14159265359

function love.load()
    pos = 0 -- 0-2Pi
    height = 0 -- Height
    circle_size = 100 -- radius in px
    badies = {}
    vsp = 0

    player_sprite = love.graphics.newImage("res/player.png")
    player_sprite:setFilter("nearest")
    player_cur = 0 -- Current frame, 0 to 3
end

function love.keypressed(key, sc, isrepeat)
    if not isrepeat and key == "space" and height == 0 then
        vsp = 125
    end
end

function love.update(dt)
    require "lovebird":update()
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        pos = pos + (200/circle_size) * dt
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        pos = pos - (200/circle_size) * dt
    end

    vsp = vsp - 300 * dt
    if height + vsp * dt < 0 then
        height = 0
        vsp = 0
    end
    height = height + vsp * dt

    circle_size = circle_size - 5 * dt
end

function love.draw()
    love.graphics.clear(255, 255, 255)
    love.graphics.setColor(0, 0, 0, 255)

    love.graphics.setLineWidth(4)
    love.graphics.circle("line", love.graphics.getWidth()/2, love.graphics.getHeight()/2, circle_size)

    love.graphics.circle("line", love.graphics.getWidth()/2+math.cos(pos)*(circle_size+height), love.graphics.getHeight()/2+math.sin(pos)*(circle_size+height), 10)
end
