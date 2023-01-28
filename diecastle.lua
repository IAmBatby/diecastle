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

    tilerespawncountmax = 16

    move={}
    move.x = 0
    move.y = 0
    move.tileindex = 0
    move.valid = true

    debugtext = ""

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
    enemyspawncountmax = 5

    diceinventory={}
    tileupdateindex={}

    gameover = false
    gameoversoundcheck = false

    StartGame()
end
        
function StartGame()
    GenerateBackground()
    GenerateLevel()

    music(0)

    newturnrunning = false

    player={}
    player.x = 42
    player.y = 50
    player.sprtopx = 96
    player.sprtopy = 0
    player.sprbotx = 94
    player.sprboty = 11
    player.tileindex = 36
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
                run()
            end
        end
        bordercolor = bordercolordefault
        if newturnrunning == false then
           UpdatePlayer()
        end
    else
        inputlock += 1
        bordercolor = 7
    end
end

function UpdatePlayer()
    if btn(controls.left) then
        if Move(0, player.tileindex).valid == true then
            player.y += move.y
            player.x += move.x
            player.tileindex += move.tileindex
            NewTurn()
        end
    end
    if btn(controls.right) then
        if Move(1, player.tileindex).valid == true then
            player.y += move.y
            player.x += move.x
            player.tileindex += move.tileindex
            NewTurn()
        end
    end
    if btn(controls.up) then
        if Move(2, player.tileindex).valid == true then
            player.y += move.y
            player.x += move.x
            player.tileindex += move.tileindex
            NewTurn()
        end
    end
    if btn(controls.down) then
        if Move(3, player.tileindex).valid == true then
            player.y += move.y
            player.x += move.x
            player.tileindex += move.tileindex
            NewTurn()
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

            if dirup == true then
                if dirleft == true then
                    if enemyval.ypreference == true then
                        if Move(2, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    else
                        if Move(0, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    end

                elseif dirright == true then
                    if enemyval.ypreference == true then
                        if Move(2, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    else
                        if Move(1, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    end

                else
                    if Move(2, enemyval.tileindex).valid == true then
                        enemyval.x += move.x
                        enemyval.y += move.y
                        enemyval.tileindex += move.tileindex
                    end
                end

            elseif dirdown == true then
                if dirleft == true then
                    if enemyval.ypreference == true then
                        if Move(3, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    else
                        if Move(0, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    end
                elseif dirright == true then
                    if enemyval.ypreference == true then
                        if Move(3, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    else
                        if Move(1, enemyval.tileindex).valid == true then
                            enemyval.x += move.x
                            enemyval.y += move.y
                            enemyval.tileindex += move.tileindex
                        end
                    end
                else
                    if Move(3, enemyval.tileindex).valid == true then
                        enemyval.x += move.x
                        enemyval.y += move.y
                        enemyval.tileindex += move.tileindex
                    end
                end
            elseif dirleft == true then
                if Move(0, enemyval.tileindex).valid == true then
                    enemyval.x += move.x
                    enemyval.y += move.y
                    enemyval.tileindex += move.tileindex
                end
            elseif dirright == true then
                if Move(1, enemyval.tileindex).valid == true then
                    enemyval.x += move.x
                    enemyval.y += move.y
                    enemyval.tileindex += move.tileindex
                end
            end

            if enemyval.tileindex == player.tileindex then
                gameover = true
            end

            add(tileupdateindex, enemyval.tileindex)
        end
    end

    if enemyspawncount == enemyspawncountmax then
        GenerateEnemy(1)
        sfx(10)
    end
    if #enemies == 0 then
        GenerateEnemy(1)
        sfx(10)
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

function Move(movedirection, movetileindex)
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

    return(move)
end

function GenerateBackground()
    bgsprx = 112
    bgspry = 16

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
    tiles={}
    
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
    --enemyspawncount = 0
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
        enemy.x = tiles[randomnumber].x + 1
        enemy.y = tiles[randomnumber].y - 3
        enemy.sprx = 108
        enemy.spry = 0
        enemy.ypreference = true
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
        for tilescounttest in all(tiles) do
            if tiles[tilescount].value == diceinventory[1].value then
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

function _draw()
    cls()
    GenerateBackground()

    for drawval in all(tiles) do
        if drawval.value != 0 then
            sspr(12, 0, 12, 12, drawval.x, drawval.y)
            sspr((drawval.value * 12), drawval.valueupdatedthisturn * 12, 12, 12, drawval.x, drawval.y)
        else
            sspr(0, 0, 12, 12, drawval.x, drawval.y)
        end
    end

    --for drawedgeval in all(tileedgeindex) do
        --rectfill(drawedgeval.x + 5, drawedgeval.y + 5, drawedgeval.x + 7, drawedgeval.y + 7, 12)
    --end

    for enemiesval in all(enemies) do
        sspr(enemiesval.sprx, enemiesval.spry, 12, 12, enemiesval.x, enemiesval.y)
    end

    for diceinventoryval in all(diceinventory) do
        sspr( 12, 0, 12, 12, diceinventoryval.x, diceinventoryval.y)
        sspr(diceinventoryval.value * 12, 12, 12,12, diceinventoryval.x, diceinventoryval.y)
    end

    sspr(player.sprtopx,player.sprtopy,12,12,player.x,player.y)
    --rectfill(tiles[player.tileindex].x, tiles[player.tileindex].y, tiles[player.tileindex].x + 11, tiles[player.tileindex].y + 11, 5)
    if turncount > 9 then
        turntext = "TURN:"..tostr("0")..tostr(turncount)
    elseif turncount > 99 then
        turntext = "TURN:"..tostr(turncount)
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
end