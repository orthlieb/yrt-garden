---
title: Ironsworn Extensions
---

> [!warning] Generated file
> Built by `npm run ref` from the Iron Ledger `yrt` extension, with the prose in `tooling/extensions-intro.md` and `tooling/extensions-outro.md`. Edit one of those — changes made here are lost.

# Ironsworn Extensions

House rules, assets, moves, oracles and a bestiary for running *Ironsworn* (Core, Delve, and Lodestar) in the world of YRT. Everything here is **additive** — nothing overrides a core Ironsworn mechanic. Where a document needed a home mechanic that core does not have, such as the manite-driven **Cast Conclave Ritual**, it is defined here.

All of it — foes, assets, moves, oracles and rarities — is **authored in the Iron Ledger repository** and rendered into this vault by `npm run ref`. The notes below are a read-only view. To change any of it, edit `extensions/yrt` in ironledger and re-run the sync; edits made to these notes are overwritten on the next run.

## Foes (24)

- [[Amber Schemer]]
- [[Blighted Guilder]]
- [[Bloater]]
- [[Carrier]]
- [[Carrion Mound]]
- [[Coldhusk]]
- [[Drowning Eye]]
- [[Echo]]
- [[Ember Kite]]
- [[Greatmask]]
- [[Locus]]
- [[Mask Risen]]
- [[Mire Form]]
- [[Necrotic Sea Hare]]
- [[Puppet Bones]]
- [[Rotwell]]
- [[The Tainted]]
- [[The Whispering Stones]]
- [[Tomb Walker]]
- [[Verdant Crawler]]
- [[Vow Walker]]
- [[War Pile]]
- [[Wisp Walker]]
- [[Witherwind]]

## Assets (13)

- [[Arcane Inspection]]
- [[Bittercraft]]
- [[Cantrip]]
- [[Compulsion]]
- [[Illusion]]
- [[Quillwise]]
- [[Touched, Bovine]]
- [[Touched, Feline]]
- [[Touched, Hircine]]
- [[Touched, Porcine]]
- [[Touched, Salamandrine]]
- [[Touched, Ursine]]
- [[Touched, Varanine]]

## Moves (2)

- [[Cast Conclave Ritual]]
- [[Craft an Item]]

## Oracles (12)

- [[Character - Freeport Occupation|Character: Freeport Occupation]]
- [[Character - Touched|Character: Touched]]
- [[Character - Touched Aspect|Character: Touched Aspect]]
- [[Character - Touched Features|Character: Touched Features]]
- [[Location - Region|Location: Region]]
- [[Location - Settlement Landmark|Location: Settlement Landmark]]
- [[Location - Settlement Opportunity|Location: Settlement Opportunity]]
- [[Location - Settlement Peril|Location: Settlement Peril]]
- [[Location - Settlement Waypoint|Location: Settlement Waypoint]]
- [[Magic - Mana Backlash|Magic: Mana Backlash]]
- [[Settlement - Type|Settlement: Type]]
- [[Story - Region|Story: Region]]

## Rarities (1)

- [[Nemezo]]

## Adapted Foes (43)

Creatures from the Ironsworn and Delve bestiaries, reframed to fit a world with no souls, no spirits and no gods that answer. Base text under CC BY 4.0; the **In YRT** section on each is ours.

- [[Atanya]]
- [[Basilisk]]
- [[Bear]]
- [[Bladewing]]
- [[Blighthound]]
- [[Blood Thorn]]
- [[Boar]]
- [[Broken]]
- [[Carrion Newt]]
- [[Cave Lion]]
- [[Chimera]]
- [[Chitter]]
- [[Common Folk]]
- [[Deep Rat]]
- [[Elder Beast]]
- [[Elf]]
- [[Gaunt]]
- [[Giant]]
- [[Gloom]]
- [[Gnarl]]
- [[Harrow Spider]]
- [[Hunter]]
- [[Husk]]
- [[Iron-Wracked Beast]]
- [[Kraken]]
- [[Leviathan]]
- [[Mammoth]]
- [[Marsh Rat]]
- [[Merrow]]
- [[Mystic]]
- [[Nightmare Spider]]
- [[Nightspawn]]
- [[Raider]]
- [[Rhaskar]]
- [[Shroud Crab]]
- [[Trog]]
- [[Troll]]
- [[Varou]]
- [[Warrior]]
- [[Wolf]]
- [[Wyrm]]
- [[Wyvern]]
- [[Zealot]]

## Excluded Foes

And 15 creatures from those books that YRT rules out altogether. See [[Excluded Foes]].

# House Extensions

Two mechanics that core Ironsworn does not have. Both are additive: neither changes an existing move. Each is noted in the entry of any foe that uses it.

## Escalating Harm

Introduced with the **Necrotic Sea Hare**. Some foes do not inflict fixed harm — they start low and escalate the longer the character fails to deal with them.

**Trigger.** On a Miss or Weak Hit where the fiction calls for the character to **Endure Harm**, the foe's current harm value increases by 1 tick for all subsequent attacks.

**Rank as ceiling, not fixed value.** Rank sets the escalation cap (and encounter difficulty), not a static harm number. A Troublesome escalating foe caps at 2 ticks; Dangerous at 3; Formidable at 4.

**Reset.** Escalation resets only when the foe is fully removed *and* the contact site is treated. On a Strong Hit, the character may narrate shaking the foe loose, reducing escalation by 1 step.

## Escalating Defense

Introduced with the **Blighted Guilder** and the **Tomb Walker**. Some foes project a passive mana shield — a reactive lattice that absorbs incoming strikes. Each miss erodes the shield by one tier before harm can reach the foe.

**Trigger.** On a Miss, the foe's current defense value decreases by 1 as the shield absorbs the strike. Use the Escalating Defense spinner in Iron Ledger to track it.

**Defense cap by rank, in ticks.** The cap is deliberately inverse to rank — a lower-rank foe has more room for the shield to degrade before it bottoms out.

| Rank | Cap |
|---|---|
| Troublesome | 12 |
| Dangerous | 8 |
| Formidable | 4 |
| Extreme | 2 |
| Epic | 1 |

**Progress blocked while the shield is up.** You cannot mark progress against a shielded foe until its defense reaches the minimum of 1. The Iron Ledger UI disables Mark Progress and shows the current value in the Progress pill (*Progress: 8 ↓*) as a reminder.

**Reset.** The shield resets only on the narrative trigger named in each foe's entry. Defeating the foe does not automatically remove it.

---

# The Premise

**There is no supernatural in Yrt.** Every "monster" is one of five things — a wild mana phenomenon, a mana-saturated body, a pre-Fall artifact still executing dead orders, a deliberately built construct, or an altered living person. Each bestiary entry tags its foe by mechanism, mana colour, and faction interest.

See also [[YRT_Foe_Analysis|YRT Foe Analysis]] — which *Delve* foes fit YRT, which need reworking, which do not fit at all — and [[YRT_Bestiary_Image_Prompts|YRT Bestiary Image Prompts]].
