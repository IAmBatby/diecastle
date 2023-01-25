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

    StartGame()
end
        
function StartGame()
    GenerateBackground()
    GenerateLevel()

    music(0)
    player={}
    player.x = 42
    player.y = 50
    player.sprtopx = 96
    player.sprtopy = 0
    player.sprbotx = 94
    player.sprboty = 11
    player.tileindex = 36
    tiles[player.tileindex].occopation = 1
    playerturn = true

    enemies={}

    GenerateEnemy(1)
    --GenerateDice(false, 5)
    --GenerateDice(false, 4)
    --GenerateDice(false, 1)
    --GenerateDice(false, 3)
    --GenerateDice(false, 6)
    --GenerateDice(false, 1)
    --GenerateDice(false, 1)
    --GenerateDice(false, 1)
    --GenerateDice(false, 1)
    --GenerateDice(false, 1)
end

function GenerateBackground()
    bgsprx = 0
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
    tile.value = flr(rnd(3)) + flr(rnd(3)) + flr(rnd(2)) + 1
    tile.sprite = tile.value
    tile.occopation = 0
    if tile.value == 1 or 2 or 3 then
        if flr(rnd(2)) == 1 then
            tile.value += 1
        end
    end
    return(tile)
    
end
    
function DestroyTile(x)
    rectfill(tiles[x].x,tiles[x].y,tiles[x].x + 11, tiles[x].y + 11)
    del(tiles, tiles[x])
end

function GenerateEnemy(amount)
    enemyspawncount = 0
    for i=1, amount do
        p = flr(rnd(#tiles))
        if p == 0 then
            p = 1
        end
        if tiles[p].occopation == 0 and tiles[p].value != 0 then
            enemy={}
            enemy.x = tiles[p].x + 1
            enemy.y = tiles[p].y - 3
            enemy.sprx = 108
            enemy.spry = 0
            enemy.ypreference = true
            enemy.tileindex = p
            add(enemies,enemy)
        end
    end
end

function GenerateDice(random, notrandomvalue)
    if #diceinventory < 9 then
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

function ConsumeDice(positiveornegative)
    consumevalue = positiveornegative
    consumed = false
    if #diceinventory != 0 then
        debugtext = "consuming"
        tilescount = 1
        tilevaluecount = 0
        for tilescounttest in all(tiles) do
            if tiles[tilescount].value == diceinventory[1].value then
                tilevaluecount = tiles[tilescount].value + consumevalue
                if tilevaluecount != 7 then
                    tiles[tilescount].value += consumevalue
                    debugtext = "Changing Dice Value"
                    if consumevalue == 1 then
                        sfx(6)
                    elseif consumevalue == -1 then
                        sfx(13)
                    end
                end
            end
            consumed = true
            tilescount += 1
        end
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
    end
end

function GameState(z)
    playerturn = false
    UpdateTiles()

    for tilei in all(tileupdateindex) do
        del(tileupdateindex, tilei)
    end
    add(tileupdateindex, player.tileindex)
    --Enemy Turn
    running = running
    print(running)
    if z == 1 then
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

    if tiles[player.tileindex].value <= 0 then
        gameover = true
    end
end

function UpdateTiles()
    countj = 1
    for diceval in all(tileupdateindex) do
        if tiles[tileupdateindex[countj]].value != 7 then
            tiles[tileupdateindex[countj]].value -= 1
            if tiles[tileupdateindex[countj]].value == 0 then
                sfx(12)
            end
        end
        countj += 1
    end

    if  countz == #enemies then
        countz -= 1
    end
    if tiles[player.tileindex].value <= 0 then
        gameover = true
    end
    inputlock = 0
    turncount += 1
    sfx(9)
    playerturn = true
end

function _update60()
    if inputlock == inputlockmax then
        if gameover == true then
            if btn(controls.left) or btn(controls.right) or btn(controls.up) or btn(controls.down) or btn(controls.a) or btn(controls.b) then
                run()
            end
        end
        bordercolor = bordercolordefault
        if playerturn == true then
            if btn(controls.left) then
                if Move(0, player.tileindex).valid == true then
                    player.y += move.y
                    player.x += move.x
                    player.tileindex += move.tileindex
                    GameState(1)
                end
            end
            if btn(controls.right) then
                if Move(1, player.tileindex).valid == true then
                    player.y += move.y
                    player.x += move.x
                    player.tileindex += move.tileindex
                    GameState(1)
                end
            end
            if btn(controls.up) then
                if Move(2, player.tileindex).valid == true then
                    player.y += move.y
                    player.x += move.x
                    player.tileindex += move.tileindex
                    GameState(1)
                end
            end
            if btn(controls.down) then
                if Move(3, player.tileindex).valid == true then
                    player.y += move.y
                    player.x += move.x
                    player.tileindex += move.tileindex
                    GameState(1)
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
    else
        inputlock += 1
        bordercolor = 7
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

function _draw()
    cls()
    GenerateBackground()

    counti = 1
    for drawval in all(tiles) do
        sspr((tiles[counti].value * 12), 0, 12, 12, tiles[counti].x, tiles[counti].y)
        counti += 1
    end

    counth = 1
    for drawval2 in all(enemies) do
        sspr(enemies[counth].sprx, enemies[counth].spry, 12, 12, enemies[counth].x, enemies[counth].y)
        counth += 1
    end

    countk = 1
    for drawval3 in all(diceinventory) do
        sspr(diceinventory[countk].value * 12, 0, 12,12, diceinventory[countk].x, diceinventory[countk].y)
        countk += 1
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
        music(-1)
        sfx(8)
        debugtext = ""
        rectfill(0,0,128,128,8)
        print("GAME", 54, 48,7)
        print("OVER", 54, 56, 7)
    end
end