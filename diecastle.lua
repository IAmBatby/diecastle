function _init()
    controls={}
    controls.left = 0
    controls.right = 1
    controls.up = 2
    controls.down = 3
    controls.a = 4
    controls.b = 5

    tilerowcount = 7
    tilecolumncount = 8

    setabletilerespawncountmax = 15
    tilerespawncountmax = 15

    move={}
    move.x = 0
    move.y = 0
    move.tileindex = 0
    move.valid = true

    debugtext = ""

    playerflip = false
    turncount = 0
    slaincount = 0

    diceprimaryx = 109
    diceprimaryy = 101
    dicesecondaryx = 109
    dicesecondaryy = 77

    bordercolordefault = 10
    bordercolor = bordercolordefault

    inputlockmax = 30
    inputlock = inputlockmax

    enemyspawncount = 0
    setableenemyspawncountmax = 20
    enemyspawncountmax = 0

    diceinventory={}
    tileupdateindex={}

    gameover = false
    gameoversoundcheck = false

    titlescreen = true

    drawcount = 0
    music(-1)
    music(1)
    --StartGame()
end
        
function StartGame()
    tiles={}
    GenerateBackground()
    GenerateLevel()
    music(-1)
    music(0)

    newturnrunning = false

    player={}
    player.tileindex = 36
    player.x = tiles[player.tileindex].x
    player.y = tiles[player.tileindex].y
    player.offsetx = 1
    player.offsety = -2
    player.lerpx = player.x
    player.lerpy = player.y
    player.sprx = 85
    player.spry = 0
    add(tileupdateindex, player.tileindex)

    tiles[player.tileindex].occopation = 1

    --tileedgeindex={}
    for edgeval in all(tiles) do
        --add(tileedgeindex, edgeval)
        edgeval.isedge = true
        if edgeval.x > 14 and edgeval.y > 14 then
            if edgeval.x < 86 and edgeval.y < 98 then
                edgeval.isedge = false
            end
        end
    end

    enemies={}

    GenerateEnemy(1)
end

function _update60()
    if inputlock == inputlockmax then
        if gameover == true then
            if btn(controls.left) or btn(controls.right) or btn(controls.up) or btn(controls.down) or btn(controls.a) or btn(controls.b) then
                gameover = false
                run()
            end
        end
        bordercolor = bordercolordefault
        if newturnrunning == false then
           UpdatePlayer()
        end
        if titlescreen == true then
            if btn(controls.left) or btn(controls.right) or btn(controls.up) or btn(controls.down) or btn(controls.a) or btn(controls.b) then
                titlescreen = false
                music(-1)
                inputlock = 0
                StartGame()
            end
        end
    else
        inputlock += 1
        bordercolor = 7
        if titlescreen == false then
            player.x = lerp(player.x,player.lerpx,0.5)
            player.y = lerp(player.y,player.lerpy,0.5)
            for enemy in all(enemies) do

                enemy.x = lerp(enemy.x, enemy.lerpx, 0.5)
                enemy.y = lerp(enemy.y, enemy.lerpy, 0.5)
            end
            for tile in all(tiles) do
                if tile.value > 0 then
                    tile.lerpup = flr(lerp(tile.lerpup, 0, 0.05))
                else
                    tile.lerpdown = flr(lerp(tile.lerpdown, 0, 0.05))
                end
            end
        end
    end
end

function MoveCheck(movedirection, movetileindex)
    move.y = 0
    move.x = 0
    move.tileindex = 0
    move.valid = true
        if movedirection == 0 and tiles[movetileindex].x != tiles[1].x then -- Left
            move.x = -12
            move.tileindex = -1
        elseif movedirection == 1 and tiles[movetileindex].x != tiles[#tiles].x then -- Right
            move.x = 12
            move.tileindex = 1
        elseif movedirection == 2 and tiles[movetileindex].y != tiles[1].x then -- Up
            move.y = -12
            move.tileindex = -8
        elseif movedirection == 3 and tiles[movetileindex].y != tiles[#tiles].y then --Down
            move.y = 12
            move.tileindex = 8
        else
            move.valid = false
        end
        if move.valid then
            return(move)
        else
            move={}
            move.x = 0
            move.y = 0
            move.tileindex = 0
            move.valid = true
            return(move)
        end
end

function Move(move)
    player.lerpx += move.x
    player.lerpy += move.y
    player.tileindex += move.tileindex
    if btn(0) then
        playerflip = false
    elseif btn(1) then
        playerflip = true
    end
end

function MoveEnemy(move, enemy)
    enemy.lerpy += move.y 
    enemy.lerpx += move.x
    enemy.tileindex += move.tileindex
end

function UpdatePlayer()
    for i=0,3 do
        if btn(i) then
            if MoveCheck(i, player.tileindex).valid == true then
                Move(move, true)
                NewTurn()
            end
        end
    end
    if btn(controls.a) then
        ConsumeDice(1)
        inputlock = 0
    end
    if btn(controls.b) then
        ConsumeDice(-1)
        inputlock = 0
    end
end

function NewTurn()
    newturnrunning = true
    UpdateTiles()

    if tiles[player.tileindex].value <= 0 then
        gameover = true
    end

    for tilei in all(tileupdateindex) do
        del(tileupdateindex, tilei)
    end

    add(tileupdateindex, player.tileindex)

    enemyspawncountmax = flr(setableenemyspawncountmax - (turncount / 5))
    if enemyspawncountmax < 1 then
        enemyspawncountmax = 1
    end
    tilerespawncountmax = flr(setabletilerespawncountmax + (turncount / 3))
    if tilerespawncountmax > 50 then
        tilerespawncountmax = 25
    end

    UpdateEnemies()
end

function UpdateTiles()
    
    for forresetingpalette in all(tiles) do
        forresetingpalette.valueupdatedthisturn = 1
    end
    --Lowering Values
    i = 1
    for loweringdiceval in all(tileupdateindex) do
        if tiles[tileupdateindex[i]].value != 7 and tiles[tileupdateindex[i]].value != 0 and tiles[tileupdateindex[i]].valueupdatedthisturn == 1 then
            tiles[tileupdateindex[i]].value -= 1
            if tiles[tileupdateindex[i]].value == 0 then
                tiles[tileupdateindex[i]].lerpup = 12
                tiles[tileupdateindex[i]].lerpup = 12
                sfx(12)
            end
            tiles[tileupdateindex[i]].valueupdatedthisturn = 3
        end
        i += 1
    end

    --Repawning Tiles
    for diceval2 in all(tiles) do
        if diceval2.value == 0 then
            if diceval2.respawncount == tilerespawncountmax then
                diceval2.value = TileValueRoll()
                sfx(15)
                diceval2.respawncount = 0
            else
                diceval2.respawncount += 1
            end
        end
    end      

    if tiles[player.tileindex].value <= 0 then
        gameover = true
    end
    inputlock = 0
    turncount += 1
    sfx(9)
    newturnrunning = false
end

function UpdateEnemies()
    if #enemies > 0 then
        for enemyval in all(enemies) do
            dirup = false
            dirdown = false
            dirleft = false
            dirright = false

            --If Player is to the right of the enemy
            if tiles[player.tileindex].x > tiles[enemyval.tileindex].x then
                dirright = true
            end
            --If Player is to the left of the enemy
            if tiles[player.tileindex].x < tiles[enemyval.tileindex].x then
                dirleft = true
            end
            --If Player is below the enemy
            if tiles[player.tileindex].y > tiles[enemyval.tileindex].y then
                dirdown = true
            end
            --If Player is above the enemy
            if tiles[player.tileindex].y < tiles[enemyval.tileindex].y then
                dirup = true
            end
            
            if dirup then
                if dirleft then
                    if enemyval.ypreference then
                        if MoveCheck(2, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    else
                        if MoveCheck(0, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    end
                elseif dirright then
                    if enemyval.ypreference then
                        if MoveCheck(2, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    else
                        if MoveCheck(1, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    end

                else
                    if MoveCheck(2, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                end
            elseif dirdown then
                if dirleft then
                    if enemyval.ypreference then
                        if MoveCheck(3, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    else
                        if MoveCheck(0, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    end
                elseif dirright then
                    if enemyval.ypreference then
                        if MoveCheck(3, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    else
                        if MoveCheck(1, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                    end
                else
                    if MoveCheck(3, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
                end
            elseif dirleft then
                if MoveCheck(0, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
            elseif dirright then
                if MoveCheck(1, enemyval.tileindex).valid then MoveEnemy(move, enemyval) end
            end

            if enemyval.tileindex == player.tileindex then
                gameover = true
            end

            add(tileupdateindex, enemyval.tileindex)
        end
    end

    if enemyspawncount >= enemyspawncountmax then
        GenerateEnemy(1)
        enemyspawncount = 0
    end
    if #enemies == 0 then
        GenerateEnemy(1)
    else
        enemyspawncount += 1
    end

    countz = 1

    --if  countz == #enemies then
        --countz -= 1
    --end

    if #enemies != 0 then
        for enemytwoval in all(enemies) do
            if tiles[enemies[countz].tileindex].value <= 0 then
                del(enemies, enemies[countz])
                slaincount += 1
                sfx(5)
                sfx(11)
                GenerateDice(true)
            else
            countz += 1
            end
        end
    end
end

function GenerateBackground()
    bgsprx = 112
    bgspry = 0

    --Drawing tiled brick background 8x8
    for j=0, 8 do
        for i=0,8 do
            sspr(bgsprx, bgspry, 16, 16, i * 16,j * 16)
        end
    end
    
    rectfill(4,4,101,113,bordercolor) -- Level Yellow Border
    rectfill(5,5,100,112,0) -- Level Background

    rectfill(108,4,121,88,bordercolor) -- Dice Inventory Secondary Border
    rectfill(108,89,109,89,bordercolor) -- Dice Inventory Secondary Border
    rectfill(120,89,121,89,bordercolor) -- Dice Inventory Secondary Border
    rectfill(109,5,120,88,0) -- Dice Inventory Secondary Background

    rectfill(108,101,121,113,bordercolor) -- Dice Inventory Primary Border
    rectfill(108,100,109,100,bordercolor) -- Dice Inventory Primary Border
    rectfill(120,100,121,100,bordercolor) -- Dice Inventory Primary Border
    rectfill(109,101,120,112, 0) -- Dice Inventory Primary Background

    rectfill(4,117,42,125,bordercolor) -- Textbox 1 Border
    rectfill(5,118,41,124,0) -- Textbox 1 Background

    rectfill(63,117,101,125,bordercolor) -- Textbox 2 Border
    rectfill(64,118,100,124,0) -- Textbox 2 Background
end

function GenerateLevel()
    lvlsprx = 0
    lvlspry = 0
    
    for j=0, tilecolumncount do
        for i=0, tilerowcount do
            add(tiles, GenerateTile(5 + (i * 12), 5 + (j * 12)))
        end
    end
end

function GenerateTile(x,y)
    tile={}
    tile.x = x
    tile.y = y
    tile.lerpup = 12
    tile.lerpdown = 12
    tile.value = TileValueRoll()
    tile.sprite = tile.value
    tile.occopation = 0
    tile.respawncount = 0
    tile.valueupdatedthisturn = 1
    tile.isedge = true

    --If a tile is a lower value we roll a 50-50 chance of raising it's value, this is a balance choice to generally create higher value tiles
    if tile.value == 1 or 2 or 3 then
        if flr(rnd(2)) == 1 then
            tile.value += 1
        end
    end

    return(tile)
    
end

function TileValueRoll()
    value = flr(rnd(3)) + flr(rnd(3)) + flr(rnd(2)) + 1
    return(value)
end

--Unused as I prefer destroyed tiles to just be a type of tile rather than being nonexistent. this way the tiles array is always consistent with the board.
function DestroyTile(x)
    rectfill(tiles[x].x,tiles[x].y,tiles[x].x + 11, tiles[x].y + 11)
    del(tiles, tiles[x])
end

function GenerateEnemy(amount)
    enemyspawncount = 0
    for i=1, amount do
        foundvalidspawn = false
        while foundvalidspawn == false do
            randomnumber = flr(rnd(#tiles))
            if randomnumber == 0 then
                randomnumber = 1
            end
            randomtile = tiles[randomnumber]
            if randomtile.occopation == 0 and randomtile.value != 0 and randomtile.isedge == true and randomtile.x != tiles[player.tileindex].y and randomtile.y != tiles[player.tileindex].y then
                foundvalidspawn = true
            end
        end
        enemy={}
        enemy.x = tiles[randomnumber].x
        enemy.y = tiles[randomnumber].y
        enemy.lerpx = enemy.x
        enemy.lerpy = enemy.y
        if flr(rnd(2)) == 1 then
            enemy.offsetx = 1
            enemy.offsety = -2
            enemy.sprx = 97
            enemy.spry = 0
            enemy.ypreference = true
        else
            enemy.offsetx = 1
            enemy.offsety = 2
            enemy.sprx = 97
            enemy.spry = 12
            enemy.ypreference = false
        end
        sfx(10)
        enemy.tileindex = randomnumber
        add(enemies,enemy)
        add(tileupdateindex, enemy.tileindex)
    end
end

function GenerateDice(random, notrandomvalue)
    if #diceinventory < 8 then
        dice={}
        dice.x = 0
        dice.y = 0
        dice.value = 0
        if random == true then
            newdicenumber = flr(rnd(7))
            if newdicenumber == 0 then
                newdicenumber = 1
            end
            dice.value = newdicenumber
        else
            dice.value = notrandomvalue
        end

        if #diceinventory == 0 then
            dice.x = diceprimaryx
            dice.y = diceprimaryy
        else
            dice.x = dicesecondaryx
            dice.y = dicesecondaryy - (12 * (#diceinventory - 1))
        end
        add(diceinventory, dice)
    end
end

function ConsumeDice(consumevalue)
    --consumevalue = positiveornegative
    consumed = false -- this seems useless ngl

    --Updating Affected Tiles
    if #diceinventory != 0 then
        tilescount = 1
        wasitemuseless = true
        for tilescounttest in all(tiles) do
            if tiles[tilescount].value == diceinventory[1].value then
                wasitemuseless = false
                if (tiles[tilescount].value + consumevalue) != 7 then
                    tiles[tilescount].value += consumevalue
                    if consumevalue == 1 then
                        sfx(6)
                        tiles[tilescount].valueupdatedthisturn = 2
                    elseif consumevalue == -1 then
                        sfx(13)
                        tiles[tilescount].valueupdatedthisturn = 3
                    end
                    if tiles[tilescount].value == 0 then
                        if tiles[tilescount] == tiles[player.tileindex] then
                            gameover = true
                        end
                        sfx(12)
                    end
                end
            end
            if wasitemuseless == true then
                sfx(14)
            end
            consumed = true
            tilescount += 1
        end

        --Updating Inventory
        if consumed == true then
            del(diceinventory, diceinventory[1])

            if #diceinventory != 0 then
                if #diceinventory > 1 then
                    dicecount = 1
                    for dicecounttest in all(diceinventory) do
                            diceinventory[dicecount].y += 12
                            dicecount += 1
                    end
                end
                diceinventory[1].x = diceprimaryx
                diceinventory[1].y = diceprimaryy
            end
        end
    else
        sfx(14)
    end
end

function _update()
   
end
function lerp(a, b, t)
	return a + (b - a) * t
end

function _draw()
    cls()
    if titlescreen == false then
        
        if turncount > 99 then
            pal(2,0,1)
            pal(12,0,1)
        elseif turncount > 74 then
            pal(2,140,1)
            pal(12,131,1)
        elseif turncount > 49 then
            pal(2,130,1)
            pal(12,5,1)
        elseif turncount > 24 then
            pal(2,131,1)
            pal(12,134,1)
        else
            pal(2,1,1)
            pal(12,13,1)
        end
        GenerateBackground()

        --TILES
        for drawval in all(tiles) do
            if drawval.value == 0 then
                sspr(72, 0, 12, 12, drawval.x + (drawval.lerpdown / 2) + 5, drawval.y + (drawval.lerpdown / 2) + 5,drawval.lerpdown,drawval.lerpdown)
                sspr((drawval.value * 12), drawval.valueupdatedthisturn * 12, 12, 12, drawval.x, drawval.y)
            else
                if drawval.lerpup == 0 then
                sspr(72, 0, 12, 12, drawval.x, drawval.y,12 - drawval.lerpup,12 - drawval.lerpup)
                sspr((drawval.value * 12), drawval.valueupdatedthisturn * 12, 12, 12, drawval.x, drawval.y)
                else
                    sspr(72, 0, 12, 12, drawval.x +(drawval.lerpup / 2) + 5, drawval.y + (drawval.lerpup / 2) + 5,12 - drawval.lerpup,12 - drawval.lerpup)
                    --sspr((drawval.value * 12), drawval.valueupdatedthisturn * 12, 12, 12, drawval.x, drawval.y)
                end
            end
        end

        --ENEMIES
        for enemiesval in all(enemies) do
            if enemiesval.x < player.x then
                sspr(enemiesval.sprx - 2, enemiesval.spry, 12, 12, enemiesval.x + enemiesval.offsetx, enemiesval.y + enemiesval.offsety, 12, 12, true)
            else
                sspr(enemiesval.sprx, enemiesval.spry, 12, 12, enemiesval.x + enemiesval.offsetx, enemiesval.y + enemiesval.offsety)
            end
        end

        --DICE INVENTORY
        for diceinventoryval in all(diceinventory) do
            sspr( 72, 0, 12, 12, diceinventoryval.x, diceinventoryval.y)
            sspr(diceinventoryval.value * 12, 12, 12,12, diceinventoryval.x, diceinventoryval.y)
        end

        --PLAYER
        if playerflip == true then
            sspr(player.sprx,player.spry,12,12,(player.x + player.offsetx) - 1,player.y + player.offsety, 12, 12,playerflip)
        else
            sspr(player.sprx,player.spry,12,12,player.x + player.offsetx,player.y + player.offsety, 12, 12,playerflip)
        end

        --TEXT
        if turncount > 99 then
            turntext = "TURN:"..tostr(turncount)
        elseif turncount > 9 then
            turntext = "TURN:"..tostr("0")..tostr(turncount)
        else
            turntext = "TURN:"..tostr("00")..tostr(turncount)
        end
        print(turntext, 7, 119, 7)

        if slaincount > 9 then
            slaintext = "SLAIN:"..tostr(0)..tostr(slaincount)
        elseif slaincount > 99 then
            slaintext = "SLAIN:"..tostr(slaincount)
        else
            slaintext = "SLAIN:"..tostr("00")..tostr(slaincount)
        end
        print(slaintext, 65, 119, 7)

        if gameover then
            if gameoversoundcheck == false then
                sfx(8)
                gameoversoundcheck = true
            end
            music(-1)
            debugtext = ""
            rectfill(0,0,128,128,8)
            print("GAME", 54, 48,7)
            print("OVER", 54, 56, 7)
        end
    else
        sspr(0, 51, 128, 76, 0, 59)
        sspr(82,24,45,27,41,12)
        print("PRESS ANY KEY", 38, 43, 7)
        print("TO BEGIN", 47, 50, 7)
    end
end