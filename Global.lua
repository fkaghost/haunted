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
            HEALTH       = s.HEALTH or {}
            KILLER_HP    = s.KILLER_HP or 8
            KILLER_MAX   = s.KILLER_MAX or 8
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
                         HEALTH=HEALTH, KILLER_HP=KILLER_HP, KILLER_MAX=KILLER_MAX })
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
    buildUI()
    broadcastToAll(colour .. " has died.", {0.6,0.6,0.6})
    broadcastToColor("You are a ghost. Draw an Allegiance card and a secret objective, then use Ghost sight.",
                     colour, {0.6,0.9,1})
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
HEALTH      = {}          -- seat colour -> current health
KILLER_HP   = 8
KILLER_MAX  = 8
MAXES       = { 6, 8, 10 }

SEAT_ORDER = { "White","Brown","Red","Orange","Yellow","Green",
               "Teal","Blue","Purple","Pink","Grey","Black" }

SEAT_HEX = {
    White="#F2F5F8", Brown="#8B5E3C", Red="#C0392B", Orange="#D4791F",
    Yellow="#C9A227", Green="#3F8B5B", Teal="#2E8B8B", Blue="#3A6FB0",
    Purple="#6B5B8C", Pink="#C46A94", Grey="#7A8894", Black="#3A424C"
}

function seatedColours()
    local out = {}
    for _, p in ipairs(Player.getPlayers()) do
        if p.seated then out[#out+1] = p.color end
    end
    table.sort(out, function(a, b)
        local ia, ib = 99, 99
        for i, c in ipairs(SEAT_ORDER) do
            if c == a then ia = i end
            if c == b then ib = i end
        end
        return ia < ib
    end)
    return out
end

function esc(s) return tostring(s):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;") end

function hpRow(label, hex, value, tag, extra)
    return table.concat({
      '<HorizontalLayout preferredHeight="30" spacing="3">',
        '<Text fontSize="13" color="', hex, '" alignment="MiddleLeft" preferredWidth="66">', esc(label), '</Text>',
        '<Button onClick="hpAdjust(', tag, '|-1)" fontSize="16" preferredWidth="26" color="#E9EEF3" textColor="#1B2C3E">-</Button>',
        '<Text fontSize="16" color="#DCE8F2" alignment="MiddleCenter" preferredWidth="34">', tostring(value), '</Text>',
        '<Button onClick="hpAdjust(', tag, '|1)" fontSize="16" preferredWidth="26" color="#E9EEF3" textColor="#1B2C3E">+</Button>',
        extra or '',
      '</HorizontalLayout>'
    })
end

function buildUI()
    local seats = seatedColours()
    local rows = {}

    for _, c in ipairs(seats) do
        if HEALTH[c] == nil then HEALTH[c] = 5 end
        local dead = GHOSTS[c] and "  (ghost)" or ""
        rows[#rows+1] = hpRow(c .. dead, SEAT_HEX[c] or "#DCE8F2", HEALTH[c], c)
    end
    if #seats == 0 then
        rows[#rows+1] = '<Text fontSize="12" color="#8FA2B5" alignment="MiddleCenter" preferredHeight="40">Sit in a seat, then press Refresh seats</Text>'
    end

    rows[#rows+1] = '<Text fontSize="11" color="#5A7086" alignment="MiddleCenter" preferredHeight="16">THE KILLER</Text>'
    rows[#rows+1] = hpRow("Killer", "#C0392B", KILLER_HP .. "/" .. KILLER_MAX, "KILLER",
        '<Button onClick="cycleKillerMax" fontSize="10" preferredWidth="34" color="#8FA2B5" textColor="#0F1924">max</Button>')

    local panelH = 108 + math.max(1, #seats) * 33

    local xml = table.concat({
    '<Panel id="hauntedControls" rectAlignment="UpperLeft" offsetXY="16 -16" width="212" height="372" color="#152232F0" outlineColor="#93A9BE" outline="1 1">',
      '<VerticalLayout padding="12 12 10 12" spacing="6" childForceExpandHeight="false">',
        '<Text fontSize="15" color="#DCE8F2" alignment="MiddleCenter" preferredHeight="24">KILLER MANSION</Text>',
        '<Button onClick="btnReshuffleKeys" fontSize="14" preferredHeight="36" color="#E9EEF3" textColor="#1B2C3E">Reshuffle keys</Button>',
        '<Button onClick="btnPeekKeys" fontSize="14" preferredHeight="36" color="#E9EEF3" textColor="#1B2C3E">Ghost sight</Button>',
        '<Button onClick="btnKillerDriven" fontSize="14" preferredHeight="36" color="#E9EEF3" textColor="#1B2C3E">Killer driven off</Button>',
        '<Button onClick="btnEndTurn" fontSize="14" preferredHeight="36" color="#E9EEF3" textColor="#1B2C3E">End turn</Button>',
        '<Button onClick="btnStartTurns" fontSize="12" preferredHeight="28" color="#B7C4D2" textColor="#1B2C3E">Start turns</Button>',
        '<Button onClick="btnAlign" fontSize="13" preferredHeight="32" color="#B7C4D2" textColor="#1B2C3E">Align to board</Button>',
        '<Button onClick="btnDiagnose" fontSize="13" preferredHeight="30" color="#8FA2B5" textColor="#0F1924">Board report</Button>',
      '</VerticalLayout>',
    '</Panel>',
    '<Panel id="hauntedHealth" rectAlignment="UpperRight" offsetXY="-16 -16" width="228" height="', tostring(panelH), '" color="#152232F0" outlineColor="#93A9BE" outline="1 1">',
      '<VerticalLayout padding="10 10 8 10" spacing="3" childForceExpandHeight="false">',
        '<Text fontSize="14" color="#DCE8F2" alignment="MiddleCenter" preferredHeight="22">HEALTH</Text>',
        table.concat(rows),
        '<Button onClick="btnRefreshSeats" fontSize="11" preferredHeight="24" color="#8FA2B5" textColor="#0F1924">Refresh seats</Button>',
      '</VerticalLayout>',
    '</Panel>'
    })

    UI.setXml(xml)
end

function hpAdjust(player, value, id)
    local who, delta = value:match("^(.-)|(-?%d+)$")
    if who == nil then return end
    delta = tonumber(delta)
    if who == "KILLER" then
        KILLER_HP = math.max(0, math.min(KILLER_MAX, KILLER_HP + delta))
        if KILLER_HP == 0 then
            broadcastToAll("The killer is at 0 Health — use 'Killer driven off'.", {1,0.5,0.4})
        end
    else
        HEALTH[who] = math.max(0, (HEALTH[who] or 5) + delta)
        if HEALTH[who] == 0 then
            broadcastToAll(who .. " is at 0 Health.", {0.85,0.4,0.4})
        end
    end
    buildUI()
end

function cycleKillerMax()
    local i = 1
    for n, v in ipairs(MAXES) do if v == KILLER_MAX then i = n end end
    KILLER_MAX = MAXES[(i % #MAXES) + 1]
    KILLER_HP = KILLER_MAX
    broadcastToAll("Killer set to " .. KILLER_MAX .. " Health.", {0.85,0.55,0.5})
    buildUI()
end

function btnRefreshSeats()
    buildUI()
    broadcastToAll(#seatedColours() .. " players seated.", {0.72,0.82,0.94})
end

function onPlayerChangeColor() Wait.time(buildUI, 0.4) end

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
