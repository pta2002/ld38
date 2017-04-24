PI = 3.14159265359

local function sign(n)
    if n < 0 then return -1 end
    if n > 0 then return 1 end
    return 0
end

function love.load()
    pos = 0 -- 0-2Pi
    height = 0 -- Height
    circle_size = 100 -- radius in px
    badies = {}
    score = 0
    dir = 1
    vsp = 0

    player_rx = 10
    px = 0
    rx_sp = 0
    player_ry = 10
    py = 0
    ry_sp = 0

    font = love.graphics.newFont("res/raleway.ttf", 20)
    font_big = love.graphics.newFont("res/raleway.ttf", 38)
    start_fade = 1
    end_fade = 0

    lost = false
    start = true
    particles = {}
    enemies = {}
    bullets = {}
    screenshake = 0
    loseanim = 0
    loseanimtimeout = 0
    spawntimeout = 2
    blink_timer = 0
    blink_hidden = false
    imunity = 0
    lives = 3

    shrink_speed = 3
end

function love.keypressed(key, sc, isrepeat)
    if not lost and not start then
        if not isrepeat and (key == "space" or key == "z") and height == 0 then
            vsp = 125
        elseif not isrepeat and key == "x" then
            table.insert(bullets, {pos=pos, height=height, dir=dir, shot=true})
            screenshake = 0.1
            -- TODO: This is slow on hard drives...
            local shoot_sound = love.audio.newSource("res/shoot.wav")
            shoot_sound:setPitch(love.math.random()+1)
            shoot_sound:play()
        end
    elseif start == true then
        start = false
    elseif lost == true then
        love.event.quit("restart")
    end
end

function love.update(dt)
    if not lost then
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            pos = pos + (200/(circle_size + height)) * dt
            dir = 1
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            pos = pos - (200/(circle_size + height)) * dt
            dir = -1
        end

        vsp = vsp - 300 * dt
        if height + vsp * dt < 0 then
            height = 0
            vsp = 0
        end
        height = height + vsp * dt

   end

    if loseanim > 0 then
        if loseanimtimeout <= 0 then
            for i=0, love.math.random(5, 20) do
                local px = love.math.random(-50, 50) + love.graphics.getWidth()/2
                local py = love.math.random(-50, 50) + love.graphics.getHeight()/2
                local psize = love.math.random(0, 30)
                table.insert(particles, {x=px, y=py, size=psize})
            end
            local explode_sound = love.audio.newSource("res/explode.wav", "static")
            explode_sound:setPitch(love.math.random()*0.2+1)
            explode_sound:play()
            loseanimtimeout = 0.2
        else
            loseanimtimeout = loseanimtimeout - dt
        end
        loseanim = loseanim - dt
    end

    for i,particle in ipairs(particles) do
        particle.size = particle.size - 30 * dt
        if particle.size <= 0 then
            table.remove(particles, i)
        end
    end

    for i, bullet in ipairs(bullets) do
        bullet.pos = math.fmod(bullet.pos + bullet.dir*(400/(circle_size+bullet.height))*dt, 2*PI)
    end

    if screenshake > 0 then
        screenshake = screenshake - dt
    else
        screenshake = 0
    end

    -- TODO: Only run when needed
    pos = math.fmod(pos, 2*PI)

    if imunity > 0 then
        if blink_timer <= 0 then
            blink_hidden = not blink_hidden
            blink_timer = 0.2
        else
            blink_timer = blink_timer - dt
        end
        imunity = imunity - dt
    else
        blink_hidden = false
    end

    if lives <= 0 then
        shrink_speed = 300
    end

    if lost and loseanim <= 0 and end_fade < 1 then
        end_fade = end_fade + dt
    end

    if not lost and not start then
        if start_fade > 0 then
            start_fade = start_fade - dt
        else
            start_fade = 0
        end
        score = score + dt
        for i, enemy in ipairs(enemies) do
            enemy.pos = enemy.pos + enemy.dir*0.3*dt
            local enemyPos = {x=love.graphics.getWidth()/2+math.cos(enemy.pos)*circle_size,y=love.graphics.getHeight()/2+math.sin(enemy.pos)*circle_size}
            local playerPos = {x=love.graphics.getWidth()/2+math.cos(pos)*(circle_size+height), y=love.graphics.getHeight()/2+math.sin(pos)*(circle_size+height)}
            local d = math.pow(playerPos.x - enemyPos.x, 2) + math.pow(playerPos.y - enemyPos.y, 2)
            if imunity <= 0 and math.pow(5-player_rx, 2) <= d and d <= math.pow(5+player_rx, 2) then
                table.remove(enemies, i)
                screenshake = math.max(screenshake, 0.2)
                imunity = 2
                lives = lives - 1
                for i=0, love.math.random(5, 20) do
                    local px = love.math.random(-10, 10) + love.graphics.getWidth()/2+math.cos(pos)*(circle_size+height)
                    local py = love.math.random(-10, 10) + love.graphics.getHeight()/2+math.sin(pos)*(circle_size+height)
                    local psize = love.math.random(0, 10)
                    table.insert(particles, {x=px, y=py, size=psize})
                end
                local explode_sound = love.audio.newSource("res/explode.wav", "static")
                explode_sound:setPitch(love.math.random()*0.2+1)
                explode_sound:play()
            end
        end
        for i2, bullet in ipairs(bullets) do
            local bulletPos = {x=love.graphics.getWidth()/2+math.cos(bullet.pos)*(circle_size+bullet.height),y=love.graphics.getHeight()/2+math.sin(bullet.pos)*(circle_size+bullet.height)}
            local alive = true
            for i, enemy in ipairs(enemies) do
                local enemyPos = {x=love.graphics.getWidth()/2+math.cos(enemy.pos)*circle_size,y=love.graphics.getHeight()/2+math.sin(enemy.pos)*circle_size}
                local d = math.pow(enemyPos.x - bulletPos.x, 2) + math.pow(enemyPos.y - bulletPos.y, 2)
                if math.pow(5, 2) <= d and d <= math.pow(15, 2) then
                    for i=0, love.math.random(5, 20) do
                        local px = love.math.random(-10, 10) + love.graphics.getWidth()/2+math.cos(enemy.pos)*circle_size
                        local py = love.math.random(-10, 10) + love.graphics.getHeight()/2+math.sin(enemy.pos)*circle_size
                        local psize = love.math.random(0, 10)
                        table.insert(particles, {x=px, y=py, size=psize})
                    end
                    screenshake = math.max(screenshake, 0.1)
                    circle_size = circle_size + 30
                    shrink_speed = shrink_speed + 1
                    table.remove(enemies, i)
                    table.remove(bullets, i2)
                    alive = false
                    local explode_sound = love.audio.newSource("res/explode.wav", "static")
                    explode_sound:setPitch(love.math.random()*0.2+1)
                    explode_sound:play()
                end
            end
            if alive and imunity <= 0 then
                local playerPos = {x=love.graphics.getWidth()/2+math.cos(pos)*(circle_size+height), y=love.graphics.getHeight()/2+math.sin(pos)*(circle_size+height)}
                local d = math.pow(playerPos.x - bulletPos.x, 2) + math.pow(playerPos.y - bulletPos.y, 2)
                if math.pow(5-player_rx, 2) <= d and d <= math.pow(5+player_rx, 2) then
                    if not bullet.shot then
                        lives = lives - 1
                        imunity = 2
                        screenshake = 0.2
                        for i=0, love.math.random(5, 20) do
                            local px = love.math.random(-10, 10) + love.graphics.getWidth()/2+math.cos(pos)*(circle_size+height)
                            local py = love.math.random(-10, 10) + love.graphics.getHeight()/2+math.sin(pos)*(circle_size+height)
                            local psize = love.math.random(0, 10)
                            table.insert(particles, {x=px, y=py, size=psize})
                        end
                        local explode_sound = love.audio.newSource("res/explode.wav", "static")
                        explode_sound:setPitch(love.math.random()*0.2+1)
                        explode_sound:play()

                        table.remove(bullets, i2)
                    end
                elseif bullet.shot and d > 20 then
                    bullet.shot = false
                end
            end
        end
        if spawntimeout <= 0 then
            if love.math.random(0,1) == 0 then
                local p = love.math.random() * 2*PI
                while math.abs(pos-p) < 1 do
                    p = love.math.random() * 2*PI
                end
                local d = 0
                if love.math.random(0,1) == 0 then
                    d = -1
                else
                    d = 1
                end
                table.insert(enemies, {pos=p, dir=d})
                for i=0, love.math.random(5, 20) do
                    local px = love.math.random(-10, 10) + love.graphics.getWidth()/2+math.cos(p)*circle_size
                    local py = love.math.random(-10, 10) + love.graphics.getHeight()/2+math.sin(p)*circle_size
                    local psize = love.math.random(0, 10)
                    table.insert(particles, {x=px, y=py, size=psize})
                end
            end
            spawntimeout = 1
        else
            spawntimeout = spawntimeout - dt
        end
        if #enemies == 0 and lives > 0 then
            circle_size = circle_size - shrink_speed*0.5 * dt
        else
            circle_size = circle_size - shrink_speed * dt
        end
        if circle_size <= 5 then
            screenshake = math.max(2, screenshake)
            loseanim = math.max(2, loseanim)
            lost = true
        end
 
    end
end

function love.draw()
    love.graphics.clear(255, 255, 255)
    love.graphics.setColor(0, 0, 0, 255)

    love.graphics.setLineWidth(4)

    if screenshake > 0 then
        love.graphics.translate(love.math.random(-5, 5), love.math.random(-5, 5))
    end

    love.graphics.setColor(0, 0, 0, 255*start_fade)
    love.graphics.setFont(font_big)
    love.graphics.printf("welcome to", love.graphics.getWidth()/2-200, love.graphics.getHeight()/2-circle_size-50, 400, 'center')
    love.graphics.setFont(font)
    love.graphics.printf("arrows to move\nz to jump\nx to shoot", love.graphics.getWidth()/2-100, love.graphics.getHeight()/2, 200, 'center')
    love.graphics.printf("made by pta2002 for LD38", love.graphics.getWidth()-400, love.graphics.getHeight()-30, 390, 'right')

    love.graphics.setColor(0, 0, 0, 255*end_fade)
    love.graphics.setFont(font_big)
    love.graphics.printf("game over", love.graphics.getWidth()/2-200, love.graphics.getHeight()/2, 400, 'center')
    love.graphics.setFont(font)
    love.graphics.printf("score: " .. math.floor(score), love.graphics.getWidth()/2-200, love.graphics.getHeight()/2+40, 400, 'center')
    love.graphics.printf("press any key to restart", love.graphics.getWidth()/2-200, love.graphics.getHeight()/2-10, 400, 'center')

    love.graphics.setColor(0, 0, 0, 255)
    if not lost then
        for i=1,lives do
            love.graphics.circle("line", i*30, 25, 10, 40)
        end

        love.graphics.setFont(font)
        love.graphics.print(math.floor(score), love.graphics.getWidth()-100, 10)

        love.graphics.circle("line", love.graphics.getWidth()/2, love.graphics.getHeight()/2, circle_size)
        for i, enemy in ipairs(enemies) do
            love.graphics.push()
            love.graphics.translate(love.graphics.getWidth()/2+math.cos(enemy.pos)*circle_size, love.graphics.getHeight()/2+math.sin(enemy.pos)*circle_size)
            love.graphics.rotate(enemy.pos)
            love.graphics.setColor(255, 255, 255)
            love.graphics.ellipse("fill", 0, 0, 20, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.ellipse("line", 0, 0, 20, 10, 50)
            love.graphics.pop()
        end

        for i, bullet in ipairs(bullets) do
            love.graphics.setColor(255, 255, 255)
            love.graphics.circle("fill", love.graphics.getWidth()/2+math.cos(bullet.pos)*(circle_size+bullet.height), love.graphics.getHeight()/2+math.sin(bullet.pos)*(circle_size+bullet.height), 5)
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle("line", love.graphics.getWidth()/2+math.cos(bullet.pos)*(circle_size+bullet.height), love.graphics.getHeight()/2+math.sin(bullet.pos)*(circle_size+bullet.height), 5)
        end


        if not blink_hidden then
            love.graphics.setColor(255, 255, 255)
            love.graphics.ellipse("fill", love.graphics.getWidth()/2+math.cos(pos)*(circle_size+height), love.graphics.getHeight()/2+math.sin(pos)*(circle_size+height), player_rx, player_ry)
            love.graphics.setColor(0, 0, 0)
            love.graphics.ellipse("line", love.graphics.getWidth()/2+math.cos(pos)*(circle_size+height), love.graphics.getHeight()/2+math.sin(pos)*(circle_size+height), player_rx, player_ry, 50)
        end
    end

    for i,particle in ipairs(particles) do
        -- TODO for post-jam: Use .circle
        love.graphics.ellipse("line", particle.x, particle.y, particle.size, particle.size)
    end
end
