--=============================================================
--  HAUNTED  ·  Thornfield Manor
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
killerBackOn = nil     -- round the killer returns on

function onLoad(saved)
    if saved and saved ~= "" then
        local ok, s = pcall(function() return JSON.decode(saved) end)
        if ok and s then
            zoneGUID     = s.zoneGUID or {}
            GHOSTS       = s.GHOSTS or {}
            currentRound = s.currentRound or 1
            killerBackOn = s.killerBackOn
        end
    end
    Wait.time(function()
        indexZones()
        alignZones(true)
        buildButtons()
        broadcastToAll("Haunted ready. Controls are the panel at the top-left of your screen.", {0.72,0.82,0.94})
        broadcastToAll("Import your board image, then click Align to board.", {0.62,0.72,0.84})
    end, 1)
end

function onSave()
    return JSON.encode({ zoneGUID=zoneGUID, GHOSTS=GHOSTS,
                         currentRound=currentRound, killerBackOn=killerBackOn })
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
function keyCardsInPlay()
    local found = {}
    for _, R in ipairs(ROOMS) do
        local z = zoneOf(R.id)
        if z then
            for _, o in ipairs(z.getObjects()) do
                if o.hasTag("KeyCard") then found[#found+1] = o end
            end
        end
    end
    return found
end

function btnReshuffleKeys()
    local board = findByNick(BOARD_NICK)
    if board == nil then broadcastToAll("Board not found.", {1,0.4,0.3}) return end

    local cards = keyCardsInPlay()
    if #cards == 0 then
        broadcastToAll("No cards tagged KeyCard are sitting in the rooms.", {1,0.7,0.3})
        return
    end

    broadcastToAll("The house rearranges itself...", {0.72,0.72,1})

    -- stack them all on one spot so they merge into a deck
    local drop = cellToWorld(board, FOYER.cc, FOYER.cr)
    drop.y = drop.y + 3
    for i, c in ipairs(cards) do
        c.setLock(false)
        c.setPositionSmooth({ drop.x, drop.y + i * 0.3, drop.z })
        c.setRotationSmooth({ 0, 180, 180 })
    end

    Wait.time(function() collectAndDeal(drop, #cards) end, 2.5)
end

function collectAndDeal(drop, expected)
    local deck = nil
    for _, o in ipairs(getAllObjects()) do
        if o.type == "Deck" and o.hasTag("KeyCard") then
            local p = o.getPosition()
            if math.abs(p.x - drop.x) < 3 and math.abs(p.z - drop.z) < 3 then deck = o end
        end
    end

    if deck == nil then
        broadcastToAll("The key cards did not merge into a deck. Nudge them together and reshuffle.", {1,0.6,0.2})
        return
    end

    deck.shuffle()
    Wait.time(function() dealKeys(deck) end, 1)
end

function dealKeys(deck)
    local board = findByNick(BOARD_NICK)
    for i, R in ipairs(ROOMS) do
        Wait.time(function()
            if deck ~= nil and not deck.isDestroyed() then
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
        broadcastToAll("Ten keys hidden. Nobody knows where.", {0.72,0.72,1})
    end, #ROOMS * 0.25 + 0.5)
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

function makeGhost(colour)
    GHOSTS[colour] = true
    broadcastToAll(colour .. " has died.", {0.6,0.6,0.6})
    broadcastToColor("You are a ghost. Draw an Allegiance card and a secret objective, then use Ghost sight.",
                     colour, {0.6,0.9,1})
end

function reviveAll()
    GHOSTS = {}
    broadcastToAll("Ghost list cleared.", {0.7,0.7,0.7})
end

--=============================================================
--  Rounds and the killer
--=============================================================
function btnEndRound()
    currentRound = currentRound + 1
    if killerBackOn ~= nil then
        if currentRound >= killerBackOn then
            killerBackOn = nil
            broadcastToAll("Round " .. currentRound .. ". The killer returns, at full Health.", {1,0.25,0.25})
            return
        end
        broadcastToAll("Round " .. currentRound .. ". The killer is still gone.", {0.62,0.62,0.62})
        return
    end
    broadcastToAll("Round " .. currentRound, {1,1,1})
end

function btnKillerDriven()
    killerBackOn = currentRound + 2
    broadcastToAll("Driven off. Gone for 2 rounds, back at full Health. +1 VP", {0.45,1,0.55})
end

--=============================================================
--  Controls
--=============================================================
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
