--=============================================================
--  KILLER MANSION  ·  Thornfield Manor
--  Global script — board alignment, key reshuffle, ghost sight,
--  round tracking and killer removal.
--
--  On load this positions every scripting zone over its room by
--  measuring the board, so the board can be moved, rotated in 90-degree
--  steps or rescaled and the zones will follow. If anything drifts,
--  click "Align to board" on the control block.
--=============================================================

BOARD_NICK   = "Thornfield Manor"
CONTROL_NICK = "Haunted Controls"

GRID = 20

-- If the plan comes out mirrored front-to-back, flip this and re-align.
ROW0_IS_FAR = true

-- Room rectangles in grid cells: c,r = top-left of the largest rectangle
-- that fits inside the room; w,h = its size; cc,cr = the centre cell where
-- that room's Key Card is dealt.
ROOMS = {
    { id="Kitchen", name="Kitchen", c=15, r=15, w=5, h=5, cc=17, cr=17 },
    { id="Guestroom", name="Guestroom", c=0, r=15, w=3, h=5, cc=1, cr=17 },
    { id="Parlour", name="Parlour", c=0, r=0, w=4, h=6, cc=1, cr=2 },
    { id="Library", name="Library", c=15, r=8, w=5, h=5, cc=17, cr=10 },
    { id="Study", name="Study", c=6, r=0, w=4, h=5, cc=8, cr=2 },
    { id="DiningRoom", name="Dining Room", c=10, r=14, w=2, h=6, cc=11, cr=17 },
    { id="Conservatory", name="Conservatory", c=17, r=0, w=3, h=6, cc=18, cr=2 },
    { id="Lounge", name="Lounge", c=5, r=15, w=3, h=5, cc=6, cr=17 },
    { id="Ballroom", name="Ballroom", c=0, r=8, w=6, h=5, cc=2, cr=10 },
    { id="Bedroom", name="Bedroom", c=12, r=0, w=3, h=6, cc=13, cr=2 },
}

FOYER = { id="Foyer", name="Foyer", c=8, r=8, w=4, h=5, cc=9, cr=10 }

ROOM_ORDER = {}
for i, v in ipairs(ROOMS) do ROOM_ORDER[i] = v.id end

--=============================================================
--  State
--=============================================================
zoneGUID     = {}      -- room id -> scripting zone GUID
GHOSTS       = {}      -- player colour -> true
currentRound = 1
killerSlayer = nil     -- seat colour of whoever drove the killer off
slayerTurns  = 0       -- completed turns by that player since

function onLoad(saved)
    if saved and saved ~= "" then
        local ok, s = pcall(function() return JSON.decode(saved) end)
        if ok and s then
            zoneGUID     = s.zoneGUID or {}
            GHOSTS       = s.GHOSTS or {}
            currentRound = s.currentRound or 1
            killerSlayer = s.killerSlayer
            slayerTurns  = s.slayerTurns or 0
            TRACK        = s.TRACK
            nextTrackId  = s.nextTrackId or 1
            KILLER_HP    = s.KILLER_HP or 8
        end
    end
    Wait.time(function()
        -- Build the panel FIRST. If anything below fails, the controls are
        -- still there and the failure is visible instead of silent.
        buildUI()
        buildButtons()

        local ok, err = pcall(function()
            indexZones()
            alignZones(true)
        end)
        if not ok then
            broadcastToAll("Setup error during align — use the Align to board button.", {1,0.5,0.3})
            print("Killer Mansion setup error: " .. tostring(err))
        end

        broadcastToAll("Killer Mansion ready. Controls are the panel at the top-left of your screen.", {0.72,0.82,0.94})
    end, 1)
end

function onSave()
    return JSON.encode({ zoneGUID=zoneGUID, GHOSTS=GHOSTS,
                         currentRound=currentRound, killerSlayer=killerSlayer, slayerTurns=slayerTurns,
                         TRACK=TRACK, nextTrackId=nextTrackId, KILLER_HP=KILLER_HP })
end

function findByNick(nick)
    for _, o in ipairs(getAllObjects()) do
        if o.getName() == nick then return o end
    end
    return nil
end

function indexZones()
    zoneGUID = {}
    for _, o in ipairs(getAllObjects()) do
        if o.type == "Scripting" then
            local n = o.getName()
            for _, R in ipairs(ROOMS) do
                if n == R.id then zoneGUID[R.id] = o.getGUID() end
            end
            if n == FOYER.id then zoneGUID[FOYER.id] = o.getGUID() end
        end
    end
end

function zoneOf(id)
    local g = zoneGUID[id]
    return g and getObjectFromGUID(g) or nil
end

--=============================================================
--  Click plumbing
--  Object buttons call back as (object, playerColour, altClick).
--  Screen-panel buttons call back as (player, value, elementId).
--  This works out who clicked either way.
--=============================================================
SEAT_COLOURS = {
    White=true, Brown=true, Red=true, Orange=true, Yellow=true, Green=true,
    Teal=true, Blue=true, Purple=true, Pink=true, Grey=true, Black=true
}

function clickerColour(a, b)
    if type(b) == "string" and SEAT_COLOURS[b] then return b end
    if type(a) == "table" or type(a) == "userdata" then
        local ok, col = pcall(function() return a.color end)
        if ok and type(col) == "string" and SEAT_COLOURS[col] then return col end
    end
    if type(b) == "string" and b ~= "" then return b end
    return nil
end

--=============================================================
--  Alignment — everything is derived from the board's own bounds,
--  so no hand-typed coordinates and no guessing at TTS units.
--=============================================================
function cellToWorld(board, col, row)
    local b  = board.getBounds()
    local cw = b.size.x / GRID
    local cd = b.size.z / GRID
    local x  = b.center.x - b.size.x / 2 + (col + 0.5) * cw
    local z
    if ROW0_IS_FAR then
        z = b.center.z + b.size.z / 2 - (row + 0.5) * cd
    else
        z = b.center.z - b.size.z / 2 + (row + 0.5) * cd
    end
    return { x = x, y = b.center.y + b.size.y / 2 + 0.2, z = z }, cw, cd
end

-- The TTS board mesh is not square, and until a real image loads there is no
-- aspect ratio to derive one from. Measure the board and stretch it back to a
-- square footprint so one grid cell is the same size along X and Z.
function squareUpBoard(board)
    local b = board.getBoundsNormalized()
    local s = board.getScale()
    if b.size.x <= 0.01 or b.size.z <= 0.01 or s.x <= 0 or s.z <= 0 then
        broadcastToAll("Could not measure the board. Is the image imported?", {1,0.6,0.2})
        return false
    end

    local perX = b.size.x / s.x        -- world units per unit of scale
    local perZ = b.size.z / s.z
    if perX <= 0.001 or perZ <= 0.001 then return false end

    local wantZ = b.size.x / perZ      -- keep the current width, match the depth to it
    if wantZ <= 0 or wantZ > 1000 then
        broadcastToAll("Board measurement looks wrong; leaving its size alone.", {1,0.6,0.2})
        return false
    end
    if math.abs(wantZ - s.z) < 0.005 then return false end

    board.setLock(false)
    board.setScale({ s.x, s.y, wantZ })
    board.setLock(true)
    return true
end

DECK_ROW = { "Draw Deck", "Ghost Deck", "Key Deck",
             "Allegiance Deck", "Character Cards", "Killer Cards" }

-- Spread the decks in a row just off the board's near edge, so they never
-- land on top of the plan whatever size the board ends up.
function layoutDecks(board)
    local b = board.getBounds()
    local z = b.center.z - b.size.z / 2 - 4.5
    local y = b.center.y + b.size.y / 2 + 1.2
    local gap = math.max(3.2, b.size.x / 7)
    local x0 = b.center.x - gap * (#DECK_ROW - 1) / 2

    for i, nick in ipairs(DECK_ROW) do
        local d = findByNick(nick)
        if d ~= nil then
            d.setPositionSmooth({ x0 + (i - 1) * gap, y, z })
            d.setRotationSmooth({ 0, 180, 180 })
        end
    end

    -- dice sit to the left of the deck row
    local dice = { {"Movement d6", -2.6}, {"Killer d10", -1.1} }
    for _, v in ipairs(dice) do
        local o = findByNick(v[1])
        if o ~= nil then o.setPositionSmooth({ x0 + v[2] * gap / 2 - gap, y, z }) end
    end

    -- pawns start in the Foyer
    local pawns = {}
    for _, o in ipairs(getAllObjects()) do
        if o.getName():match(" pawn$") then pawns[#pawns+1] = o end
    end
    for i, o in ipairs(pawns) do
        local col = FOYER.c + ((i - 1) % FOYER.w)
        local row = FOYER.r + math.floor((i - 1) / FOYER.w)
        local p = cellToWorld(board, col, row)
        o.setPositionSmooth({ p.x, p.y + 1.5, p.z })
    end
end

-- Prints what TTS actually reports, so a misbehaving board can be diagnosed
-- instead of guessed at.
function btnDiagnose()
    local board = findByNick(BOARD_NICK)
    if board == nil then
        broadcastToAll("No object named '" .. BOARD_NICK .. "'.", {1,0.4,0.3})
        return
    end
    local b  = board.getBounds()
    local bn = board.getBoundsNormalized()
    local s  = board.getScale()
    indexZones()
    local n = 0
    for _ in pairs(zoneGUID) do n = n + 1 end

    local L = {
        "--- BOARD ---",
        "name       : " .. tostring(board.getName()),
        "type       : " .. tostring(board.type),
        "scale      : " .. string.format("%.2f, %.2f, %.2f", s.x, s.y, s.z),
        "bounds     : " .. string.format("%.2f x %.2f x %.2f", b.size.x, b.size.y, b.size.z),
        "normalised : " .. string.format("%.2f x %.2f x %.2f", bn.size.x, bn.size.y, bn.size.z),
        "square?    : " .. (math.abs(bn.size.x - bn.size.z) < 0.05 and "yes" or "NO"),
        "cell size  : " .. string.format("%.3f x %.3f", b.size.x / GRID, b.size.z / GRID),
        "zones found: " .. n .. " of " .. (#ROOMS + 1),
    }
    print(table.concat(L, "\n"))
    broadcastToAll("Board report printed to chat.", {0.72,0.82,0.94})
end

function alignZones(quiet)
    local board = findByNick(BOARD_NICK)
    if board == nil then
        broadcastToAll("No object named '" .. BOARD_NICK .. "'. Rename the board and align again.", {1,0.4,0.3})
        return
    end

    if squareUpBoard(board) then
        if not quiet then
            broadcastToAll("Board squared up.", {0.7,0.85,1})
        end
        Wait.time(function() placeZones(board, quiet) end, 0.5)
        return
    end
    placeZones(board, quiet)
end

function placeZones(board, quiet)
    indexZones()

    local all = {}
    for _, R in ipairs(ROOMS) do all[#all+1] = R end
    all[#all+1] = FOYER

    local snaps, placed = {}, 0
    for _, R in ipairs(all) do
        local z = zoneOf(R.id)
        local _, cw, cd = cellToWorld(board, 0, 0)
        local pos = cellToWorld(board, R.c + R.w / 2 - 0.5, R.r + R.h / 2 - 0.5)
        if z ~= nil then
            z.setPosition(pos)
            z.setRotation({0, 0, 0})
            z.setScale({ cw * R.w, 3, cd * R.h })
            placed = placed + 1
        end
        local sp = cellToWorld(board, R.cc, R.cr)
        snaps[#snaps+1] = { position = sp, rotation = {0,0,0}, rotation_snap = true }
    end

    Global.setSnapPoints(snaps)

    layoutDecks(board)

    -- park the control block clear of the board's left edge, so it can never
    -- end up hidden underneath a board that got scaled up
    local ctrl = findByNick(CONTROL_NICK)
    if ctrl ~= nil then
        local b = board.getBounds()
        ctrl.setLock(false)
        ctrl.setPosition({ b.center.x - b.size.x / 2 - 3.5,
                           b.center.y + b.size.y / 2 + 0.6,
                           b.center.z })
        ctrl.setRotation({0, 0, 0})
        ctrl.setLock(true)
    end

    if not quiet then
        broadcastToAll(placed .. " of " .. #all .. " room zones aligned.", {0.7,0.85,1})
    end
    if placed < #all then
        broadcastToAll("Missing zones. Each scripting zone must be named exactly as its room.", {1,0.7,0.3})
    end
end

--=============================================================
--  Keys — gather all ten, reshuffle, deal one face-down per room
--=============================================================
KEY_PILE_NICK = "Key Deck"

-- Every Key Card in the scene: loose ones sitting in rooms, plus the reserve
-- pile. The pile is just whatever did not fit on the board, so it drains from
-- 3 spares to 0 as keys are collected, with no bookkeeping.
-- Cards sitting in the Foyer are collected Keys and are left alone. The Foyer
-- is the found-keys area: it is the door you are unlocking, and it is never
-- dealt into, so nothing there is part of the hidden layout.
function foyerGUIDs()
    local held, z = {}, zoneOf(FOYER.id)
    if z ~= nil then
        for _, o in ipairs(z.getObjects()) do held[o.getGUID()] = true end
    end
    return held
end

function allKeyObjects()
    local out, safe = {}, foyerGUIDs()
    for _, o in ipairs(getAllObjects()) do
        if not safe[o.getGUID()] then
            local ok, tagged = pcall(function() return o.hasTag("KeyCard") end)
            if ok and tagged then
                out[#out+1] = o
            elseif o.type == "Deck" and o.getName() == KEY_PILE_NICK then
                out[#out+1] = o
            end
        end
    end
    return out
end

function foundKeyCount()
    local n, z = 0, zoneOf(FOYER.id)
    if z ~= nil then
        for _, o in ipairs(z.getObjects()) do
            local ok, t = pcall(function() return o.hasTag("KeyCard") end)
            if ok and t and o.getName() == "Key" then n = n + 1 end
        end
    end
    return n
end

function btnReshuffleKeys()
    local board = findByNick(BOARD_NICK)
    if board == nil then broadcastToAll("Board not found.", {1,0.4,0.3}) return end

    local objs = allKeyObjects()
    if #objs == 0 then
        broadcastToAll("No Key Cards found. They must be tagged KeyCard.", {1,0.7,0.3})
        return
    end

    broadcastToAll("The house rearranges itself...", {0.72,0.72,1})

    -- stack everything on one spot so it merges into a single deck
    local bb = board.getBounds()
    local drop = { x = bb.center.x - bb.size.x / 2 - 4,
                   y = bb.center.y + bb.size.y / 2 + 3,
                   z = bb.center.z }
    for i, o in ipairs(objs) do
        o.setLock(false)
        o.setPositionSmooth({ drop.x, drop.y + i * 0.3, drop.z })
        o.setRotationSmooth({ 0, 180, 180 })
    end

    Wait.time(function() collectAndDeal(drop) end, 2.5)
end

function collectAndDeal(drop)
    local deck, loose = nil, 0
    for _, o in ipairs(getAllObjects()) do
        local p = o.getPosition()
        if math.abs(p.x - drop.x) < 4 and math.abs(p.z - drop.z) < 4 then
            if o.type == "Deck" then deck = o
            elseif o.type == "Card" then loose = loose + 1 end
        end
    end

    if deck == nil then
        broadcastToAll("The Key Cards did not merge into a deck. Nudge them together and reshuffle.", {1,0.6,0.2})
        return
    end
    if loose > 0 then
        broadcastToAll(loose .. " Key Card(s) did not join the pile — check the Foyer.", {1,0.7,0.3})
    end

    deck.setName(KEY_PILE_NICK)
    deck.shuffle()
    Wait.time(function() dealKeys(deck) end, 1)
end

function dealKeys(deck)
    local board = findByNick(BOARD_NICK)
    local held = deck.getQuantity()
    if held < #ROOMS then
        broadcastToAll("Only " .. held .. " Key Cards for " .. #ROOMS ..
                       " rooms — some rooms will be empty.", {1,0.7,0.3})
    end

    for i, R in ipairs(ROOMS) do
        Wait.time(function()
            if deck ~= nil and not deck.isDestroyed() and deck.getQuantity() > 0 then
                local p = cellToWorld(board, R.cc, R.cr)
                deck.takeObject({
                    position = { p.x, p.y + 1.5, p.z },
                    rotation = { 0, 180, 180 },
                    smooth   = true
                })
            end
        end, i * 0.25)
    end

    Wait.time(function()
        local left = 0
        local d = findByNick(KEY_PILE_NICK)
        if d ~= nil and not d.isDestroyed() then
            local ok, q = pcall(function() return d.getQuantity() end)
            left = (ok and q and q > 0) and q or 0
        end
        local found = foundKeyCount()
        broadcastToAll(#ROOMS .. " rooms dealt. " .. left .. " spare in reserve. " ..
                       found .. " of 3 keys found.", {0.72,0.72,1})
        if found >= 3 then
            broadcastToAll("All three keys are in the Foyer — the FINAL CHASE begins. "
                .. "Corridors now need a Killer roll too.", {1,0.3,0.25})
        end
    end, #ROOMS * 0.25 + 0.8)
end

--=============================================================
--  Ghost sight — the dead see every key, privately
--=============================================================
function btnPeekKeys(a, b)
    local colour = clickerColour(a, b)
    if colour == nil then return end
    if not GHOSTS[colour] then
        broadcastToColor("Only the dead see the house for what it is.", colour, {1,0.45,0.45})
        return
    end
    local lines = { "--- THE KEYS ---" }
    for _, R in ipairs(ROOMS) do
        local z, what = zoneOf(R.id), "(empty)"
        if z then
            for _, o in ipairs(z.getObjects()) do
                if o.hasTag("KeyCard") then what = o.getName() end
            end
        end
        lines[#lines+1] = R.name .. ": " .. what
    end
    broadcastToColor(table.concat(lines, "\n"), colour, {0.6,0.9,1})
end

-- A player declares their own death from the panel. Using the clicker's seat
-- means no name-to-colour mapping is needed, and Ghost sight keys off the same
-- seat, so the two always agree.
function btnIDied(a, b)
    local colour = clickerColour(a, b)
    if colour == nil then
        broadcastToAll("Sit in a seat first, then declare.", {1,0.7,0.3})
        return
    end
    if GHOSTS[colour] then
        broadcastToColor("You are already a ghost.", colour, {0.6,0.9,1})
        return
    end
    makeGhost(colour)
end

function btnClearGhosts()
    reviveAll()
end

function makeGhost(colour)
    GHOSTS[colour] = true
    buildUI()
    broadcastToAll(colour .. " has died and is now a ghost.", {0.6,0.6,0.6})
    broadcastToColor("You are a ghost. Take an Allegiance card, drop everything you carried, "
        .. "then press Ghost sight — only you will see the result.", colour, {0.6,0.9,1})
end

function reviveAll()
    GHOSTS = {}
    buildUI()
    broadcastToAll("Ghost list cleared.", {0.7,0.7,0.7})
end

--=============================================================
--  Rounds and the killer
--=============================================================
function btnEndTurn(a, b)
    if Turns.enable then
        Turns.turn_color = Turns.getNextTurnColor()
    else
        broadcastToAll("Turn order is off. Use 'Start turns' first.", {1,0.7,0.3})
    end
end

function btnStartTurns()
    local seats = seatedColours()
    if #seats == 0 then
        broadcastToAll("Nobody is seated.", {1,0.7,0.3})
        return
    end
    Turns.enable = true
    Turns.type = 2               -- custom order
    Turns.order = seats
    Turns.turn_color = seats[1]
    currentRound = 1
    broadcastToAll("Turn order set: " .. table.concat(seats, ", "), {0.72,0.82,0.94})
    buildUI()
end

-- Fires when the active seat changes. previousPlayer has just finished a turn.
function onPlayerTurn(player, previousPlayer)
    if previousPlayer ~= nil and killerSlayer ~= nil
       and previousPlayer.color == killerSlayer then
        slayerTurns = slayerTurns + 1
        if slayerTurns >= 2 then
            broadcastToAll("The killer returns, at FULL Health.", {1,0.25,0.25})
            killerSlayer = nil
            slayerTurns  = 0
            KILLER_HP    = KILLER_MAX
        else
            broadcastToAll("The killer stays away for one more of " ..
                           killerSlayer .. "'s turns.", {0.62,0.62,0.62})
        end
    end

    local seats = Turns.order
    if seats ~= nil and #seats > 0 and player ~= nil and player.color == seats[1] then
        currentRound = currentRound + 1
        broadcastToAll("Round " .. currentRound, {1,1,1})
    end
    buildUI()
end

function btnKillerDriven(a, b)
    local colour = clickerColour(a, b)
    if colour == nil then
        broadcastToAll("Could not tell who drove the killer off.", {1,0.7,0.3})
        return
    end
    killerSlayer = colour
    slayerTurns  = 0
    KILLER_HP    = 0
    broadcastToAll(colour .. " drove the killer off. +1 VP. It returns at full Health "
                   .. "once " .. colour .. " has played two more turns.", {0.45,1,0.55})
    buildUI()
end

--=============================================================
--  Controls
--=============================================================

--=============================================================
--  Screen UI — controls panel and the health tracker.
--  All of it is built here in Lua rather than baked into the save,
--  so the health rows can follow who is actually seated.
--=============================================================
TRACK      = nil     -- ordered list of {id, name, hp}
nextTrackId = 1
KILLER_HP  = 8

SEAT_HEX = {
    White="#F2F5F8", Brown="#8B5E3C", Red="#C0392B", Orange="#D4791F",
    Yellow="#C9A227", Green="#3F8B5B", Teal="#2E8B8B", Blue="#3A6FB0",
    Purple="#6B5B8C", Pink="#C46A94", Grey="#7A8894", Black="#3A424C"
}
SEAT_ORDER = { "White","Brown","Red","Orange","Yellow","Green",
               "Teal","Blue","Purple","Pink","Grey","Black" }

function seatedColours()
    local out = {}
    for _, p in ipairs(Player.getPlayers()) do
        if p.seated then out[#out+1] = p.color end
    end
    table.sort(out, function(a,b)
        local ia, ib = 99, 99
        for i,c in ipairs(SEAT_ORDER) do
            if c==a then ia=i end
            if c==b then ib=i end
        end
        return ia < ib
    end)
    return out
end

function xesc(s)
    return tostring(s):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;")
end

function addTracked(name, hp)
    TRACK[#TRACK+1] = { id = "t" .. nextTrackId, name = name or "Player", hp = hp or 5 }
    nextTrackId = nextTrackId + 1
end

function findTracked(id)
    for i, t in ipairs(TRACK) do if t.id == id then return t, i end end
    return nil
end

function seedTrack()
    TRACK = {}
    for _, c in ipairs(seatedColours()) do addTracked(c, 5) end
    if #TRACK == 0 then addTracked("Player 1", 5) end
end

function btnAddPlayer()
    addTracked("Player " .. (#TRACK + 1), 5)
    buildUI()
end

function btnAddSeated()
    local have = {}
    for _, t in ipairs(TRACK) do have[t.name] = true end
    local n = 0
    for _, c in ipairs(seatedColours()) do
        if not have[c] then addTracked(c, 5); n = n + 1 end
    end
    buildUI()
    broadcastToAll(n .. " seated player(s) added.", {0.72,0.82,0.94})
end

function removeTracked(player, value, id)
    local t, i = findTracked(value)
    if i then table.remove(TRACK, i) end
    buildUI()
end

function onNameEdit(player, value, id)
    local t = findTracked((id or ""):gsub("^name_", ""))
    if t then t.name = value end
end

function hpAdjust(player, value, id)
    local who, delta = tostring(value):match("^(.-)|(-?%d+)$")
    if who == nil then return end
    delta = tonumber(delta)
    if who == "KILLER" then
        KILLER_HP = math.max(0, KILLER_HP + delta)
        if KILLER_HP == 0 then
            broadcastToAll("The killer is at 0 Health — use 'Killer driven off'.", {1,0.5,0.4})
        end
    else
        local t = findTracked(who)
        if t == nil then return end
        t.hp = math.max(0, t.hp + delta)
        if t.hp == 0 then broadcastToAll(t.name .. " is at 0 Health.", {0.85,0.4,0.4}) end
    end
    buildUI()
end

function hpRow(id, name, hex, value, editable)
    local label
    if editable then
        label = '<InputField id="name_' .. id .. '" text="' .. xesc(name) ..
                '" onEndEdit="onNameEdit" fontSize="13" textColor="' .. hex ..
                '" preferredWidth="76" />'
    else
        label = '<Text fontSize="14" color="' .. hex ..
                '" alignment="MiddleLeft" preferredWidth="76">' .. xesc(name) .. '</Text>'
    end
    local kill = editable and
        ('<Button onClick="removeTracked(' .. id .. ')" fontSize="12" preferredWidth="20" ' ..
         'color="#3A424C" textColor="#B7C4D2">x</Button>') or
        '<Text preferredWidth="20"> </Text>'
    return table.concat({
      '<HorizontalLayout preferredHeight="30" spacing="3">', label,
      '<Button onClick="hpAdjust(', id, '|-1)" fontSize="16" preferredWidth="26" color="#E9EEF3" textColor="#1B2C3E">-</Button>',
      '<Text fontSize="16" color="#DCE8F2" alignment="MiddleCenter" preferredWidth="30">', tostring(value), '</Text>',
      '<Button onClick="hpAdjust(', id, '|1)" fontSize="16" preferredWidth="26" color="#E9EEF3" textColor="#1B2C3E">+</Button>',
      kill, '</HorizontalLayout>'
    })
end

function buildUI()
    if TRACK == nil then seedTrack() end

    local rows = {}
    for _, t in ipairs(TRACK) do
        local hex = SEAT_HEX[t.name] or "#DCE8F2"
        if GHOSTS[t.name] then hex = "#8FA2B5" end
        rows[#rows+1] = hpRow(t.id, t.name, hex, t.hp, true)
    end
    rows[#rows+1] = '<Text fontSize="11" color="#5A7086" alignment="MiddleCenter" preferredHeight="16">THE KILLER</Text>'
    rows[#rows+1] = hpRow("KILLER", "Killer", "#E2695E", KILLER_HP, false)

    local h = 150 + #TRACK * 33

    local xml = table.concat({
    '<Panel id="kmControls" rectAlignment="UpperLeft" offsetXY="16 -16" width="212" height="410"',
    ' color="#152232F0" outlineColor="#93A9BE" outline="1 1"',
    ' allowDragging="true" returnToOriginalPositionWhenReleased="false">',
      '<VerticalLayout padding="12 12 10 12" spacing="6" childForceExpandHeight="false">',
        '<Text fontSize="14" color="#8FA2B5" alignment="MiddleCenter" preferredHeight="20">KILLER MANSION  (drag)</Text>',
        '<Button onClick="btnReshuffleKeys" fontSize="14" preferredHeight="34" color="#E9EEF3" textColor="#1B2C3E">Reshuffle keys</Button>',
        '<Button onClick="btnIDied" fontSize="14" preferredHeight="34" color="#5A6B7C" textColor="#E9EEF3">I died</Button>',
        '<Button onClick="btnPeekKeys" fontSize="14" preferredHeight="34" color="#E9EEF3" textColor="#1B2C3E">Ghost sight</Button>',
        '<Button onClick="btnKillerDriven" fontSize="14" preferredHeight="34" color="#E9EEF3" textColor="#1B2C3E">Killer driven off</Button>',
        '<Button onClick="btnEndTurn" fontSize="14" preferredHeight="34" color="#E9EEF3" textColor="#1B2C3E">End turn</Button>',
        '<Button onClick="btnStartTurns" fontSize="12" preferredHeight="26" color="#B7C4D2" textColor="#1B2C3E">Start turns</Button>',
        '<Button onClick="btnAlign" fontSize="12" preferredHeight="26" color="#B7C4D2" textColor="#1B2C3E">Align to board</Button>',
        '<HorizontalLayout preferredHeight="24" spacing="4">',
          '<Button onClick="btnClearGhosts" fontSize="11" color="#8FA2B5" textColor="#0F1924">Clear ghosts</Button>',
          '<Button onClick="btnDiagnose" fontSize="11" color="#8FA2B5" textColor="#0F1924">Board report</Button>',
        '</HorizontalLayout>',
      '</VerticalLayout>',
    '</Panel>',
    '<Panel id="kmHealth" rectAlignment="UpperRight" offsetXY="-16 -16" width="236" height="', tostring(h), '"',
    ' color="#152232F0" outlineColor="#93A9BE" outline="1 1"',
    ' allowDragging="true" returnToOriginalPositionWhenReleased="false">',
      '<VerticalLayout padding="10 10 8 10" spacing="3" childForceExpandHeight="false">',
        '<Text fontSize="13" color="#8FA2B5" alignment="MiddleCenter" preferredHeight="20">HEALTH  (drag)</Text>',
        table.concat(rows),
        '<HorizontalLayout preferredHeight="26" spacing="4">',
          '<Button onClick="btnAddPlayer" fontSize="11" color="#B7C4D2" textColor="#1B2C3E">Add player</Button>',
          '<Button onClick="btnAddSeated" fontSize="11" color="#8FA2B5" textColor="#0F1924">Add seated</Button>',
        '</HorizontalLayout>',
      '</VerticalLayout>',
    '</Panel>'
    })
    UI.setXml(xml)
end

function buildButtons()
    local host = findByNick(CONTROL_NICK)
    if host == nil then return end
    host.clearButtons()
    local defs = {
        { "btnReshuffleKeys", "Reshuffle keys",  -1.05 },
        { "btnPeekKeys",      "Ghost sight",     -0.35 },
        { "btnKillerDriven",  "Killer driven off", 0.35 },
        { "btnEndRound",      "End round",        1.05 },
    }
    for _, d in ipairs(defs) do
        host.createButton({
            click_function = d[1], function_owner = Global, label = d[2],
            position = { 0, 0.3, d[3] }, width = 1500, height = 500,
            font_size = 170, color = {0.93,0.95,0.97}, font_color = {0.1,0.13,0.17}
        })
    end
    host.createButton({
        click_function = "btnAlign", function_owner = Global, label = "Align to board",
        position = { 0, 0.3, 1.75 }, width = 1500, height = 400,
        font_size = 150, color = {0.80,0.84,0.88}, font_color = {0.1,0.13,0.17}
    })
end

function btnAlign() alignZones(false) end
