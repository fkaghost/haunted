# KILLER MANSION — Master Rules & Design Document

*A cooperative-with-a-twist horror board game: find the keys and escape the haunted house before the killer catches you — and before your dead friends decide whose side they're on.*

*Working draft. Rules below are the current agreed state; every unresolved item is collected in **Section 11 — Things to Address**.*

---

## 1. Premise

You and the other players wake up trapped in a haunted house with a murderer closing in. You have to escape the house to survive. If you die, you don't leave the game — you become a **ghost** who might help the others escape... or lead them to their doom.

---

## 2. How to Win

- The house is a map of connected rooms. A **killer** stalks it.
- The group must find **3 keys** hidden around the house, then reach the **Front Door** (in the Foyer) and escape. Once the third key is found, the **Final Chase** begins and even the hallways become dangerous (Section 7).
- Key locations are hidden and reshuffle every time one is found, so nobody knows where they are. The group's central choice: **split up** to search faster, or **stick together** to survive the killer.
- Sticking together makes it easier to fight the killer off; splitting up finds keys faster but leaves lone players exposed.

### Victory Points

Escaping isn't scored alone — the group earns **Victory Points (VP)**, tallied at the end of the game:

| Source | VP |
|--------|-----|
| Each player who escapes alive | **+1** each |
| **Clean run** — no player ever became a ghost | **+1** (all or nothing) |
| Each time the killer is dropped to **0 Health** | **+1** each (repeatable — see the return rule in Section 7) |
| Each **Guardian** ghost that completed the objective on its card | **+1** each |
| Each **oppositional (Malevolent)** ghost in play when the group wins | **+1** each *(scored only on a win — see below)* |

*Note on defeated ghosts:* a Malevolent ghost counts as "defeated" simply because the group **succeeded anyway**, despite it. There is no exorcism mechanic and no traitor hunt — the living never need to identify ghosts. Because it only scores **after** the group has already met its threshold, this VP can never be what *gets* you to victory; it measures how decisively you beat the traitors.

### Win thresholds

| Players | To win |
|---------|--------|
| **1** | Find all 3 keys and escape |
| **2** | **2 VP** |
| **3** | **4 VP** |
| **4** | **5 VP** |
| **5** | **6 VP** |
| **6** | **7 VP** |

*(From 3 players up, the threshold is **players + 1**.)*

**The math to know:** a flawless run scores exactly the threshold — **+1 per escapee** plus the **+1 clean-run bonus** = players + 1. So a perfect game wins by the narrowest possible margin. The moment one player dies, the group loses **2 VP at once** (that player's escape point *and* the clean-run bonus) and must make it up by killing the killer, or through Guardian ghosts completing objectives.

### "Unstoppable" — the perfect victory

- **1 player:** find all keys, drop the killer to 0 Health at least once, and escape.
- **2+ players:** find all keys, drop the killer to 0 Health at least once, **no player ever becomes a ghost**, and escape.

---

## 3. Components

- **Game board** — the haunted-house floor plan: 11 rooms plus connecting corridors. The **Foyer** holds the Front Door (start point and exit).
- **Character cards** — the playable survivors (Section 6).
- **Killer cards** — 9 killers; one is in play per game (Section 7).
- **Key Card deck** — 10 cards: 3 Keys, 7 "Not a Key."
- **Draw deck** — 44 cards: objects, 2 bag tools, and events mixed together (Section 8).
- **Ghost cards** — Allegiance cards (3 Guardian, each printed with its own objective : 2 Malevolent) and the 30-card ghost ability deck (Section 9).
- **Dice** — a **d6** (movement, actions, searching, encounters) and a **d10** (killer appearance).
- **Tokens** — key markers, player pawns, a killer marker (placed in whichever room it surfaces in), Health/damage trackers, and VP counters.

---

## 4. Setup

1. Lay out the board. All players place their pawns in the **Foyer** (also the exit).
2. Each player takes a **character card** (Section 6) and sets their Health to its starting value.
3. Put one **killer** card into play. The killer has no fixed position — it **surfaces** via the Killer roll (Section 7) rather than moving around the board.
4. Build the **Key Card deck** (3 Keys + 7 "Not a Key" = 10). Shuffle and deal **one card face-down into each searchable room** — every room except the Foyer (10 rooms, so exactly one card each).
   - **On every key found:** replace the found Key with a "Not a Key" card, then gather **all 10** cards (face-down and revealed alike), shuffle, and redeal one face-down per room. The deck stays at 10 with one fewer Key each time (3 → 2 → 1), and every room is hidden again.
   - *Why this matters — don't skip it:* without the reshuffle, revealed "Not a Key" cards accumulate and the group finds the rest by pure elimination. Playtesting showed that makes keys far too easy to find.
5. Shuffle the **Draw deck** (44 cards), the **ghost card deck** (30 cards), and the **Allegiance deck** (3 Guardian : 2 Malevolent), and set them within reach.
6. The group needs **3 keys** to open the Front Door and escape.

---

## 5. Turn Structure & Actions

**Turn and round — the standard definitions.** A **turn** ends when a player can take no further actions — their points are spent, or nothing remains they can legally do. A **round** is one full pass of the turn order. Any rule counting turns or rounds uses these.


Movement is *Clue*-style: one die roll is a single pool split between moving and acting, so every turn trades covering ground against getting something done.

**One roll, one pool**
- Roll **1d6** — that's your pool of **points** for the turn. Each point pays for **1 square of movement** *or* **1 action**.
- Spend points one at a time, in any order (e.g. move 2 → search → move 1), reacting as you go.
- Leftover points are lost at the end of your turn. Play passes to the left.

**Movement**
- 1 point = 1 square, orthogonal only (up/down/left/right, no diagonals), including stepping through a doorway.
**Familiar ground is dangerous.** You may go wherever you like — including straight back where you came from — but the house notices when you don't move on. In both cases below, the killer **appears automatically** (no Killer roll) and you **must face it — Run or Fight — on your first or second action**:

- **Staying put:** you begin your turn in the **same room you ended your last turn in**.
- **Doubling back:** you **return to a room you just left**.

Notes:
- You choose whether to face it on your **first or second action**. You may **search (or take any other action) first** and face the killer second — but no later than your second action.
  - *Face it first* if you want to **Run**, since escaping frees the rest of your turn.
  - *Search first* to squeeze value out of the room before dealing with it — but you're committed to facing it next.
- Because entering a room grants a free action, you always have at least one action available to respond with.
- Being forced to face the killer replaces that room's normal Killer roll for the visit.

*Why:* backtracking and camping are now **allowed but costly**. If a key is behind you, you can go get it — you'll just have to fight or flee your way through. That's a decision rather than a prohibition.

**Actions in a room**
- **Entering a room grants 1 guaranteed action**, even if your whole roll went to movement.
- You may take at most **3 actions in a single room** per turn; the 2nd and 3rd come out of your remaining points.
- An action is: **Search**, use an item, **trade an object with a player in the same room**, pick up a dropped item, try to open/unlock a door, turn on a lamp, or **respond to the killer** (Run — or **Fight, only if you're holding a weapon**).

**The Search action** — roll **1d6 + your Wits bonus** (Section 6):
- **5–6 → flip this room's Key card.** If it's a **Key**, you collect it. If it's **"Not a Key,"** you turned the room over and came up with something else instead — **draw 1 card from the Draw deck**. See the Key Card rules in Section 4.
- **3–4 → draw 1 card from the Draw deck** (object, tool, or event — Section 8).
- **1–2 → failed search**, nothing found.

*Why "Not a Key" still pays out:* without it, a high-Wits character flips the Key card ~67% of the time but only 3 of the 10 cards are Keys, so most searches produced nothing at all and objects stayed rare. Now every successful search (3+) yields either a key or a card, and Wits helps both outcomes.

**The killer roll — you choose when.** Once per room you enter, make the **Killer roll** (d10) to check whether it appears (Section 7). You pick the moment during your actions, before you leave the room.
- If the killer **appears**, spend a remaining action to **Run** or **Fight**.
- If you have **no actions left**, you **can't respond — it catches you** and you take its Scariness damage.
- A reserved action is a **pure hedge**: it can *only* pay for a Run or Fight. If the killer doesn't appear, that action is **wasted** — it can't be spent on anything else.

*Example:* You enter the Kitchen with 2 actions. You Search (action 1) and draw a card, then make the Killer roll — it appears. You spend your last action to Run. Had you searched twice first, you'd have had nothing left to respond with.

---

## 6. Player Characters

Every character has three traits, each rated **Low / Medium / High**. Each character card sets its own spread.

| Trait | Low | Medium | High |
|-------|-----|--------|------|
| **Bravery** (adds to Fight rolls) | no bonus | +1 to attack | +2 to attack |
| **Wits** (adds to Search and Run rolls) | no bonus | +1 | +2 |
| **Health** (hit points) | 5 | 6 | 7 |

- **Lose all Health → you die** and become a ghost (Section 9).
- Every character is built on the same budget: **Bravery bonus + Wits bonus + Health = 9**, so each one trades combat/utility against survivability for the same total.

### Roster

| Character | Bravery | Wits | Health | Role |
|-----------|---------|------|--------|------|
| **Movie Star** | Medium (+1) | Medium (+1) | High (7) | Balanced generalist — solid everywhere, master of nothing |
| **Athlete** | High (+2) | Low (—) | High (7) | Bruiser — best in a fight, weak at searching and running |
| **Detective** | High (+2) | High (+2) | Low (5) | Ace all-rounder (finds keys, fights, escapes) but fragile |
| **Caretaker** | Low (—) | High (+2) | High (7) | Durable searcher — finds keys and slips away, can't win a fight |
| **Priest** | High (+2) | Medium (+1) | Medium (6) | Brave frontline fighter with some know-how; average durability |

*More characters can be added on the same 9-point budget.*

---

## 7. Killers & Encounters

One killer is in play per game. Each has three stats — **Health**, **Difficulty**, **Scariness** — plus an optional special ability.

| Killer | Scariness | Difficulty | Health | Special |
|--------|-----------|------------|--------|---------|
| Clown | Terrifying | Medium | Medium | — |
| Zombie | Terrifying | Low | Low | Can turn a player into a zombie. Can't be possessed. |
| Vampire | Scary | Medium | High | Can't be possessed. *(Own bite/turn effect TBD.)* |
| Trench Coat Killer | Scary | Medium | Medium | — |
| Werewolf | Terrifying | High | Medium | On a hit, roll to see if it kills the player or turns them into a werewolf in 2 turns. Can't be possessed. |
| Serial Killer | Scary | Medium | Medium | — |
| Chainsaw | Terrifying | Low | High | — |
| El Cucuy | Terrifying | High | Medium | — |
| Killer Doll | Very Scary | Medium | Medium | — |

*(Difficulty ratings are provisional — they were carried over from an earlier stat and should be re-tuned per killer.)*

### Appearance — when the killer shows up

- The **Killer roll** uses the killer's own **d10**, separate from the d6.
- **When to roll:** each time you **enter a room**, make one Killer roll for that visit — you choose when during your actions (Section 5).
- The killer **appears in that room** if the roll lands in its Difficulty band:

| Difficulty | Appears on (d10) |
|------------|-------------------|
| Low | **7–10** (40%) |
| Medium | **6–10** (50%) |
| High | **5–10** (60%) |

- **Automatic appearance:** if you linger in a room (Section 5), the killer appears with no roll.
- **Roll modifiers:** the **Creaky Floor** and **Squeaky Teddy Bear** events and the ghost's **Glowing Room** card each add **+1** to the killer's roll (more likely to appear).
- **One menace:** once an encounter resolves, the killer submerges again. It is never in two rooms at once.

### The Final Chase — once all 3 keys are found

The moment the third key is collected, the house turns hostile and the group **races for the Front Door**. From that point on:

- **The hallways are no longer safe.** Any turn a player spends in the **hallways/corridors**, they must make a Killer roll (same Difficulty bands) to see if it catches them in the open.
- Room-entry checks continue as normal — so during the chase there is **nowhere that isn't a risk**.
- Respond to an appearance the usual way (Run or Fight, costing an action), so players sprinting the whole way with no action in reserve are the most exposed.

*Why it works:* before the chase, corridors were free movement and the danger lived in rooms — so the endgame was a safe victory lap once the keys were in hand. Now the escape is the tensest part of the game, and the group has to decide whether to sprint for the door or move carefully with an action held back.

### Scariness — the encounter penalty

When the killer appears and you respond, its Scariness makes your roll harder and sets the damage you take on a failure:

| Scariness | Run / Fight roll | Damage on failure |
|-----------|------------------|-------------------|
| Scary | no penalty | **1** |
| Very Scary | **+1** to the target | **2** |
| Terrifying | **+2** to the target | **3** |

A **failed response** = you tried to Run and didn't escape, or tried to Fight and didn't win. You take the damage either way — and also if you had no action left to respond at all.

### Killer Health & Recovery

- Killer Health by rating: **Low = 6**, **Medium = 8**, **High = 10**.
- **Recovery:** each turn the killer does **not** appear, it heals **1 Health**, up to its maximum.
- **Wounds suppress healing:** when a player damages the killer, it **cannot heal at all until that player's next turn comes around**. If a *different* player wounds it in the meantime, the clock **resets to that new player's turn**.
  - This lets the group **chain-suppress** the killer: if attacks are spread across different players in the turn order, the healing window keeps resetting and the killer never recovers a point. Concentrating all the damage on one player is far less effective.
  - It rewards **spacing attackers out around the table** — another concrete payoff for grouping up and coordinating, and it makes whittling the killer to 0 Health (worth **+1 VP**) genuinely achievable rather than a losing race against its healing.
- **Driven off:** at **0 Health** the killer leaves play. It returns at **full Health** only once **the player who dealt the killing blow has completed two further turns of their own**. Scores **+1 VP** (Section 2).

  *Why it's measured against one player:* two of a single player's turns is roughly two full rounds whatever the table size, so the reprieve lasts about as long at 2 players as at 6. Tying it to the slayer also puts the clock on the person who earned it, and stops a group staggering kills to keep the killer permanently gone.


### Encounters — Run or Fight

When the killer appears, spend an action and roll **1d6 + your bonus**. Base target is **4+**, raised by Scariness:

| Response | Base | vs. Scary | vs. Very Scary | vs. Terrifying |
|----------|------|-----------|----------------|----------------|
| **Run** (add **Wits**) | 4+ | 4+ | 5+ | 6+ |
| **Fight** (add **Bravery**) | 4+ | 4+ | 5+ | 6+ |

- **Run** — success: flee to an adjacent room (no killer roll for that entry). Failure: take Scariness damage and stay.
- **Fight** — you must hold a **weapon** (unarmed, you can only Run). Success: deal the weapon's damage to the killer's Health. Failure: take Scariness damage.
- **Grouping pays off:** every player in the room can spend an action to Fight the same killer, stacking damage in one visit.
- **Killer reduced to 0 Health:** it is **driven off**. It does not return until **the player who landed the killing blow has completed two more of their own turns**, and it returns at **full Health**.

---

## 8. Objects, Tools & Events — the Draw Deck (44 cards)

You draw from this deck on a **3–4 search roll**. **Objects** are kept and used, **Tools** (bags) are held, and **Events** resolve immediately when drawn.

### Carrying, dropping & trading

- You hold **3 objects** at a time. Bags are Tools that don't count toward the limit and raise it — **Small Bag → 4**, **Backpack → 5**, both → 6. Events and Tools never count as objects.
- At your limit, **drop** an object in your current room to take a new one.
- **Dropped items stay on the floor** as long as **any living player is still in the room**. They go to the **discard pile** the moment the room is empty of living players — the house swallows them.
  - Picking an item back up costs **1 action per item**.
  - So you *can* recover a dropped hand: stay in the room next turn and keep picking up. But **staying put means facing the killer automatically** (Section 5) — recovering your gear always costs you an encounter.
  - This makes **Trip!**, **See a Ghost**, and **Spook!** genuinely punishing — with a 3-action cap in a room, a player who drops a full hand usually can't recover all of it before the rest is gone for good.
- **When a player dies, everything they were carrying drops to the floor** of the room they died in — objects and bags alike. Survivors can pick it up as normal (1 action per item), and it lasts as long as a living player remains in the room.
- **Trading:** players in the **same room** may spend **1 action** to trade objects or hand one over. Either player can spend the action; it covers the whole exchange.
  - This is a real reward for grouping up: the Athlete can pass the Detective a weapon, or a wounded player can be handed healing.

### Weapons (needed to Fight)
| Weapon | Effect |
|--------|--------|
| Knife | +2 damage |
| Fire Poker | +2 damage; roll 1 less to attack |
| Bat | +1 damage; roll 1 less to attack |
| Hammer | +1 damage |

### Anti-killer (rare, killer-specific)
| Item | Effect |
|------|--------|
| Silver Stake | +8 damage to the Werewolf |
| Holy Water | +5 damage to Vampire, Werewolf, or Killer Doll |
| Crucifix | Roll 3 less to Run from the Vampire or Killer Doll |

### Healing
| Item | Effect |
|------|--------|
| Bandage | Heal 1 Health |
| Chocolate | Heal 1 Health |
| Pain Killers | Heal 2 Health |
| Strange Tonic | Heal 2 Health |
| Medic Pack | Heal a player 3 Health |
| Epinephrine | Revive a player to 3 Health |

### Search & Utility
| Item | Effect |
|------|--------|
| Flashlight | Roll 1 less to find objects |
| Lantern | Roll 1 less to find objects |
| Wind-Up Clock | Play to distract the killer in two turns; the killer won't appear that turn |

### Tools — bags (don't count toward the carry limit)
| Tool | Effect |
|------|--------|
| Small Bag | Carry 1 extra object (→ 4) |
| Backpack | Carry 2 extra objects (→ 5) |

### Events (resolve immediately when drawn)
| Event | Effect |
|-------|--------|
| Trip! | Drop all items; 1 action to pick up each — they stay on the floor until the room is empty of players |
| See a Ghost | Drop all items; 1 action to pick up each — they stay on the floor until the room is empty of players |
| Step on a Creaky Floor | +1 to the killer's roll to appear in the room |
| Step on a Squeaky Teddy Bear | +1 to the killer's roll to appear in the room |

### Deck composition (44 cards)

| Group | Cards (copies) | Subtotal |
|-------|----------------|----------|
| Weapons | Knife ×3, Bat ×3, Hammer ×3, Fire Poker ×2 | 11 |
| Healing | Bandage ×3, Chocolate ×3, Pain Killers ×2, Strange Tonic ×2, Medic Pack ×2, Epinephrine ×2 | 14 |
| Search & Utility | Flashlight ×2, Lantern ×2, Wind-Up Clock ×2 | 6 |
| Anti-killer | Silver Stake ×1, Holy Water ×1, Crucifix ×1 | 3 |
| Tools | Small Bag ×1, Backpack ×1 | 2 |
| Events | Trip! ×2, See a Ghost ×2, Creaky Floor ×2, Squeaky Teddy Bear ×2 | 8 |
| **Total** | | **44** |

When the draw pile runs out, shuffle the discard pile to form a new one.

---

## 9. Ghosts

When you die you become a ghost, but you stay in the game — you keep your seat, your turn, and your voice.

### Core principle: hide intent, not actions

**Every ghost draws from the same card deck; allegiance only decides how you aim it.** The living see a card played but never *why*. A ghost raising the killer's odds in a room might be baiting it **away** from the living or **onto** them. Ghosts may talk freely with the living — advise, warn, mislead — but must never reveal their allegiance.

### Allegiance

On death, draw one face-down **Allegiance card**, kept secret all game:

- **Guardian** (hidden benefactor) — you win if the group **meets its VP threshold** (Section 2).
- **Malevolent** (hidden traitor) — you win if the group **falls short**.

Build the Allegiance deck to lean Guardian — start at **3 Guardian : 2 Malevolent**, drawn face-down without replacement as players die. Ghost help should usually be genuine but never *safe to assume*: if the living knew no traitors existed they'd trust blindly, and if they knew one existed they'd distrust everyone equally.

### Becoming a ghost — you see the keys

The moment you die, **look at every remaining Key card on the board** (every room's card, face-down or revealed). You now know exactly where the keys are — and the living do not.

This is what makes a ghost both dangerous and valuable: you can steer the group toward a key or waste their turns on empty rooms, and nobody can tell which you're doing. Your allegiance matters from your very first turn.

**You stay informed.** Every time a key is found, all Key cards are reshuffled and redealt (Section 4) — and **ghosts view the new layout each time**. Ghosts always know where the keys are; the living never do. The dead are the house's permanent eyes.

**Then you must move something.** Immediately after viewing the keys (on death only), you **must switch the Key cards between two rooms of your choice**. Both cards are placed **face-down**, even if one was already revealed — the house rearranges itself and those rooms become unknown again.

- The living **see which two rooms** were disturbed, but never the contents.
- This is **mandatory for every new ghost**, which is exactly what makes it safe: a Guardian pulling a key toward the group and a Malevolent burying one in the far corner look identical from the outside, so the swap itself reveals nothing about your allegiance.
- It also means your key knowledge is useful the instant you die, rather than sitting idle until you happen to draw the right card.

### Ghost turns

- You keep your place in the turn order. Ghosts have **no pawn** and are not on the board — cards may target any room or player.
- On death, draw **3 ghost cards** (hand limit 3).
- On your turn you **must play exactly one ghost card** — no more, no less — then draw back up to 3.
- **Ghost cards may only be played on your own turn.** They can't be held as interrupts or played in reaction to a living player's roll.

*Why mandatory, and why on-turn only:* nearly every ghost card is a **delayed trigger** (it affects the *next* check, search, or entry in a place), so cards are meant to be committed in advance and fire later. Pre-committing keeps allegiance hidden — a Cold Spot placed two turns ago, before anyone knew who'd walk in, is unreadable, whereas a card dropped the instant before someone's fight roll broadcasts intent. Forcing a play each turn adds to that: you sometimes must play a card that doesn't serve your side, so the living can never assume a card reflects what you wanted.


### The ghost card deck (30 cards)

Every card is **dual-use** — a Guardian and a Malevolent would each plausibly play it, so the living can never read intent from the card alone.

| Card | Effect | Copies |
|------|--------|--------|
| **Glowing Room** | Choose a room. Add **+2** to the next Killer roll made there — the killer is **more likely** to appear. | 4 |
| **Cold Spot** | Choose a room. Apply **−2** to the next Killer roll made there — the killer is **less likely** to appear. | 4 |
| **Spook!** | Living players in a chosen room drop their held objects | 3 |
| **Possess** | **Take control of a living player's entire turn** — you roll and spend all their points and actions for them | 2 |
| **Chill in the Air** | Name a room; the next player to enter must make the Killer roll **immediately** on entry, losing their choice of timing | 2 |
| **Locked Door** | Seal a doorway for one round | 2 |
| **Slam the Door** | A chosen player must immediately leave their room into the hallway | 2 |
| **Familiar Halls** | A chosen player may **return to the room they just left, or stay put, without facing the killer** on their next turn | 2 |
| **Poltergeist** | Switch the **Key cards** between two rooms | 2 |
| **Second Sight** | A chosen player gets **+2 on their next Search** | 2 |
| **Grave Chill** | A chosen player gets **−2 on their next Run or Fight** | 2 |
| **Restless Spirit** | The killer **does not heal for 2 turns** *(stacks with wound suppression — Section 7)* | 1 |
| **Total** | | **30** |

**Stacking:** Glowing Room and Cold Spot effects **stack** on the same room (+2 and −2 cancel to net zero). Each waits in its room until a Killer roll is actually made there, then is spent. This lets ghosts quietly counter one another — a hidden ghost-vs-ghost layer the living never see.

*Balance notes:* **Possess** is the deck's most powerful card — a ghost can walk a player into danger *or* play their turn perfectly for them, and because it appears twice, being possessed says little about the ghost's allegiance. Held at **2 copies**: taking a player's turn away can feel bad, and at 4 it was tied for the most common card in the deck. **Glowing Room** and **Cold Spot** are mirrored at 4 copies each — the spine of the deck and the purest dual-use pair, since neither reveals anything about intent. **Second Sight** and **Grave Chill** mirror each other as the sharply-tilted pair. **Restless Spirit** is a singleton because it's the only card that purely disadvantages the killer, so it should feel rare.

### Guardian objectives

**Objectives are printed on the Guardian Allegiance cards themselves.** There is no separate objective deck — a Guardian's card names both their side and their goal. **Malevolent cards carry no objective.**

Because there are **3 Guardian cards**, each one carries a **different objective**:

| Objective | Condition |
|-----------|-----------|
| **Where I Fell** | A key must be found in the room where you died. |
| **Scattered Bones** | All 3 keys are found in three *different* rooms (no room yields two). |
| **Echoes** | The same room yields a key **twice** over the course of the game. |

An objective is a **bonus, not a requirement**: a Guardian's win depends only on the group hitting its VP threshold. Completing it is a "true victory" flourish that also scores the group **+1 VP** (Section 2). A Guardian is never punished for helping the group escape without it.

*Why these work:* neither objective sits on the survival axis, so pursuing one never hints at your allegiance — a Malevolent nudging keys around to sabotage looks identical to a Guardian chasing **Scattered Bones**. **Where I Fell** and **Echoes** are anchored to your own death or to a specific room, so they personalize automatically and can't be gamed.

*Target difficulty:* roughly **1 in 3** Guardians should complete their objective — an achievement, not a formality.

---

## 10. Game Progression & Difficulty

- Grouping is safer but slower; splitting is faster but exposed — the core tension of every turn.
- The longer players stay in the house, the worse it should get: after a set number of turns, a harder **round** begins. *(What escalates, and when, is still to be defined — Section 11.)*

---

## 11. Things to Address

### Ghost system
- **"Can't be possessed" is now orphaned:** the Zombie, Vampire, and Werewolf cards each say they can't be possessed, but **Possess** now targets *living players*, not the killer. Either drop the trait from those three cards, or give them a different immunity/perk in its place.
- The ghost system is now built (Section 9): allegiances with printed Guardian objectives, on-death key viewing and mandatory key swap, and the 30-card deck. Remaining tuning and edge cases:
  - **Poltergeist and Floating Objects are deliberate twins** — both switch the Key cards between two rooms, 2 copies each. Four copies of the effect is what makes key-shuffling common enough that doing it reveals nothing about a ghost's allegiance. Split them later only if the deck needs the slot.
  - **Tune in playtest:** the 3:2 Guardian:Malevolent ratio, the 3-card hand limit, and the 30-card deck size.
  - **Ghost power creep:** ghosts now re-view the keys after every reshuffle and must play a card every turn, so a large ghost pool is potent. Watch whether late-game (3+ ghosts) overwhelms the living, and if so, consider a cap on ghost cards played per round.

### Killers
- **Re-tune each killer's Difficulty** (values are provisional).
- **Vampire special:** its card previously borrowed the Werewolf's text — give it its own effect (likely a "turn into a vampire" ability paralleling Zombie/Werewolf).
- **"Turn a player into…" rules:** define what a turned Zombie/Werewolf player actually becomes and does.
- **Confirm Trench Coat Killer Health** (set to Medium as a placeholder).
- **Killer start & movement:** where does the killer begin, and does it move on its own at all, or only surface via the Killer roll?
- **Anti-killer cards vs. single killer:** Silver Stake / Holy Water / Crucifix only matter against specific killers, but only one killer is in play per game — so most games they're dead draws. Intended, or should they be seeded to match the chosen killer?

### Board & movement
- **Build the movement grid:** pip the corridors, mark doorways, and assign square-distances between rooms so a d6 feels right (short hops ≈ 3, long runs ≈ 5). Adjust distances, not the die, if the house plays too cramped or sprawling.
- **Final map size / room count** — keep the Key Card count equal to the number of searchable rooms.
- **Multi-room chaining:** since each room entry grants a free action *and* forces a killer roll, watch whether chaining rooms for a free search each needs a per-turn cap.

### Search, keys & objects
- **Card wording vs. the roll bands:** "roll 1 less to find objects" (Flashlight, Lantern) and "roll 1 less to attack" (Bat, Fire Poker) presumably *lower the target* (objects on 2–4, Fight hits on 3+) — confirm. Note the object bonus nudges toward the low band, not the key band.
- **5–6 on an already-flipped Key card:** what happens (suggestion: draw a card instead)?
- **Weapon damage:** confirm a Fight hit = 1 base + the weapon's bonus (Knife/Fire Poker 3, Bat/Hammer 2); do the anti-killer bonuses (+8/+5) add to or replace that?
- **Healing over max:** cap heals at each character's max (5/6/7)?
- **Epinephrine "revive":** needs a *downed-but-not-yet-ghost* state to target, or it conflicts with dying → becoming a ghost. Define that window.
- **Redundant event pairs:** Trip! = See a Ghost and Creaky Floor = Squeaky Teddy Bear — keep as duplicate-effect flavor, or differentiate one of each.

### Encounters
- **Per-weapon balance:** should the Fire Poker meaningfully beat the Bat?
- **Loud actions:** do forcing a door, running, or (if added) setting a fire carry extra consequences, e.g. raising the Killer roll?

### Progression
- **Define the time-escalation** concretely: at what turn count does a new round hit, and what worsens (wider appearance bands, faster killer healing, more events)?

### Win condition
- VP thresholds and Unstoppable conditions are now defined (Section 2). Remaining: does the game **end the moment the door opens**, or can players escape across several turns (letting stragglers still earn their +1)? What happens to players still inside when the keys are used?
- **Balance watch:** killing the killer (+1 VP) requires Fighting, which risks the deaths that cost **2 VP** each (the escapee point *and* the clean-run bonus). So the safe no-death path will usually outscore the aggressive one — if killing the killer should feel more tempting, it may need to be worth more than 1 VP.

### Parking lot (cut or reinstate)
- **Events:** See Something Shiny (peek at a room's Key card without flipping it), Find a Mirror (never defined).
- **Items:** Ghost Key / Lock Pick (need lockable interior doors?), Glass (killer must roll higher to appear), Lighter / Matches (need a fire mechanic?).

### Roster
- Game supports **1–6 players** (per the VP thresholds). Remaining: final **character roster size** — currently 5.
