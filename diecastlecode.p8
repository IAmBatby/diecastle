


function _init()
        StartGame()
end
        
function _Update()
    turncount = 0
    turnstate = 0

    if turnstate == 0 then

    end
    if turnstate == 1 then

    end
    if turnstate == 2 then

    end    
end

function _Draw()
        sspr(84,0,12,12,40,52)
    end
    
    function StartGame()
        GenerateBackground()
        GenerateLevel()
        player={}
        player.x = 0
        player.y = 0
        player.sprtopx = 85
        player.sprtopy = 0
        player.sprbotx = 94
        player.sprboty = 11
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
    
    rectfill(4,4,101,125,10) -- Level Yellow Border
    rectfill(5,5,100,124,0) -- Level Background
    rectfill(108,4,121,100,10) -- Dice Inventory Secondary Border
    rectfill(108,101,109,101,10) -- Dice Inventory Secondary Border
    rectfill(120,101,121,101,10) -- Dice Inventory Secondary Border
    rectfill(109,5,120,100,0) -- Dice Inventory Secondary Background
    rectfill(108,107,121,119,10) -- Dice Inventory Primary Border
    rectfill(108,106,109,106,10) -- Dice Inventory Primary Border
    rectfill(120,106,121,106,10) -- Dice Inventory Primary Border
    rectfill(109,107,120,118, 0) -- Dice Inventory Primary Background
end

function GenerateLevel()
    tiles={}
    
    lvlsprx = 0
    lvlspry = 0
    
    for j=0, 9 do
        for i=0, 7 do
            --sspr(lvlsprx, lvlspry, 12, 12, 5 + (i * 12), 5 + (j * 12))
            add(tiles, NewTile(5 + (i * 12), 5 + (j * 12)))
        end
    end
    
    --Destroying a few random tiles
    for val in all(tiles) do
        g = flr(rnd(tiles - 1))
        if flr(rnd(30)) == 3 then
        --rectfill(tiles[g].x,tiles[g].y,tiles[g].x + 11,tiles[g].y + 11)
        DestroyTile(g)
        end
    end
end

function NewTile(x,y)
    tile={}
    tile.x = x
    tile.y = y
    tile.value = flr(rnd(7)) + 1
    tile.sprite = tile.value
    tile.occopation = 0
    sspr( (tile.value * 12) - 12, 0, 12, 12, tile.x, tile.y)
    return(tile)
    
    end
    
    function DestroyTile(x)
    rectfill(tiles[x].x,tiles[x].y,tiles[x].x + 11, tiles[x].y + 11)
    del(tiles, tiles[x])
end