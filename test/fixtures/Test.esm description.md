# Test ESM description

This is where I will describe all of the content I have manually created in the
Test.esm file. Then I can write tests to ensure it matches what is listed here.

## Apparatus

* ID: "noob_tool"
* Name: "Noob Tool"
* Type: Mortar/Pestle
* Script: "ToolScript"
* Weight: 1.5
* Value: 12
* Quality: 2.7
* Mesh: "a\\A_Ebony_boot_GND.nif"
* Texture: "s\\B_Tx_S_fire_shield.dds"
* References persist: checked
* Blocked: unchecked

## Birthsign

* ID: "steed"
* Name: "Sign of the Cross"
* Description: "The name of the rose"
* Image: "\_land\_default.dds"
* Spells: "pewpew"

## Book

* ID: "Argonian Maid"
* Name: "The Lusty Argonian Maid, Part 3"
* Script: none
* Weight: 1.5
* Value: 50000
* Teaches: Enchant
* Mesh: "bam\\a_bonemold_bracers.nif"
* Texture: "m\\tx_gold_001.dds"
* Scroll: checked
* Enchantment: 100
* Enchanting: nil
* Text: "Something about polishing spears goes here."

## Cell

* Description: Bedroom
* Ambient: R 28, B 115, G 71
* Sunlight: R 242, B 217, G 217
* Fog: R 210, G 217, B 85, density 0.5
* Has water: true (height: 5)
* Objects: fargoth (npc), LootBag (container)

## Class

* ID: "stuff"
* Name: "Something"
* Primary attributes: Luck, Willpower
* Specialization: Magic
* Playable: true
* Major skills: Block, Armorer, Medium Armor, Mercantile, Blunt Weapon
* Minor skills: Long Blade, Heavy Armor, Athletics, Axe, Spear
* Autocalc checked: Weapons, Clothing, Lights, Repair Items, Training
* Description: "A dummy class for test purposes."

## Dialogue

This is going to be even harder to describe. These entries are ordered.

### Topic: "goofed"

* "Yes, I think you [goofed]."
* ID: fargoth
* Cell: Bedroom
* PC Faction: other_guild
* Disposition: 0
* Conditions:
  * Item Gold_010 = 10
* Result "; lol it worked!"

(Added after "Huh?" and moved before it.)
* "Nah, you're cool, %PCName".
* Conditions:
  * Dead fargoth = 1
  * Journal test_j != 200
  * Not Faction ym_guild = 5

* "Huh?"
* Class: stuff
* Faction: ym_guild
* Rank: Rank A
* Sex: Male
* Disposition: 100

### Greeting 0

* "Oh God, I think you [goofed]."
* Race: other
* Disposition: 25
* Conditions:
  * Not ID fargoth = 0

## Faction

* ID: "ym_guild"
* Name: "My Guild"
* Favorite attributes: Intelligence, Willpower
* Favorite skills: Hand to hand, Speechcraft, Alchemy, Long Blade, Blunt Weapon, Heavy Armor
* Ranks:
  * Rank A - 10, 10, 20, 15, 0
  * Rank B - 15, 12, 20, 20, 10
* Reactions: ym_guild (5), other_guild (-5)
* Hidden: false

## Ingredient

* ID: "skooma"
* Name: "Skooma"
* Weight: 0.1
* Value: 500
* Icon: "a\Tx_Fur_Colovian_Helm_r.dds"
* Effects: Corprus, Damage Health, Blind
* References Persist: true

## Journal

This is going to be hard to describe.

* ID: "test_j"
* "Test Journal Name": quest name, index 0
* "This is an index": index 10
* "Quest complete!": quest complete, index 11
* "Quest still complete!": quest complete, index: 9
* "You dun goofed": quest restarted, index 100
* "Complete again. Yay.": quest complete, index 500

## Magic Effect

Hardcoded, but I edited Mark.

* School: Mysticism
* Base Cost: 15
* Creation Modes: Spellmaking
* Particle Texture: none
* Effect Icon: "n\\tx_adamantium.dds"
* Description: "Mark, then recall, for great justice."
* Casting effects:
  * Sound: Alteration Cast, VFX_DefaultArea
  * Bolt: Alteration Bolt, VFX_DefaultBolt
  * Hit: Alteration Hit, VFX_DefaultHit
  * Area: Alteration Area, VFX_DefaultCast
* Scale: SpeedX (1.0), SizeX (0.8), Size Cap (25)
* Lighting Effect: R (33), G (66), B (99), negative: true

## Misc Item

Customized one already in game.

* ID: "Misc_SoulGem_Petty"
* Name: "Pretty Soul Gem"
* Weight: 0.25
* Value: 11
* Mesh: "m\\misc_soulgem_petty.nif"
* Texture: "m\\tx_soulgem_petty.tga"

## NPC

* ID: "fargoth"
* Name: "Son of Fargoth"
* Script: "DaughterOfFargoth"
* Race: "other"
* Female: false
* Class: "stuff"
* Level 17
* Faction & Rank: "ym_guild", Rank B
* Essential: true
* Corpses Persist: false
* Respawn: false
* Auto-calc Stats: true
  * Str (100), Int (50), Wil (60), Agi (50), Spd (50), End (50), Per (50), Luk (60)
  * Health (123), Magicka (100), Fatigue (260), Disp (50), Rep (4)
* Blood texture: Skeleton (white)
* Skills:
  * Mercantile, Blunt Weapon, Medium Armor, Armorer, Block (46)
  * Athletics, Spear, Axe, Long Blade, Heavy Armor (31)
  * rest (7)
* Items:
  * 1 copy of "Argonian Maid" book

## Race

* ID: "Falmer"
* Name: "Falmer"
* Skill bonuses: Acrobatics (1), Alchemy (2), Alteration (3), Athletics (4), Axe (5), Armorer (7)
* Male attributes: Str (10), Int (20), Wil (30), Agi (40), Spd (50), End (60), Per (70), Luk (75)
* Female attributes: Str (15), Int (25), Wil (35), Agi (45), Spd (55), End (65), Per (75), Luk (70)
* Height: 0.90 (male), 0.97 (female)
* Weight: 0.95 (male), 1.01 (female)
* Playable: false
* Beast race: true
* Description: "Falmer live in caves."
* Specials: none
* Deleted: true

## Region

* ID: "House"
* Name: "My House"
* Weather: Clear (10), Cloudy (25), Foggy (35), Overcast (15), Rain (10), Thunder (0), Ash (0), Blight (0), Snow (5), Blizzard (0)
* Map Color: R 105, G 227, B 74

## Skill

Hardcoded, but I edited Marksman.

* Skill: Marksman
* Governing Attribute: Agility
* Specialization: Stealth
* Actions:
  * Successful Attack: 0.9
* Description: "Hello world"

## Spell

* ID: "pewpew"
* Name: "Pew! Pew!"
* Effects:
  * Absorb Attribute (Agility) on target, area 5, duration 10, magnitude 5-5
  * Damage Fatigue on self, area 0, duration 2, magnitude 1-10
* Type: Spell
* Auto-calculate cost: true
* PC Start Spell: true
* Always Succeeds: false
