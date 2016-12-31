# The Elder Scrolls III: Morrowind data presenter

The end goal is to create a read-only webapp to present game data used in Morrowind.

At the moment this is still in the "parse the ESM data file into something readable" stage.

Using the amazing work of Dave Humphrey detailed here: http://www.uesp.net/morrow/tech/mw_esm.txt

## The Plan

- [ ] Parse the ESM data file into a meaningful format
- [ ] Insert the parsed data into a database
- [ ] Build frontend to present data nicely

## Record types parsed from ESM so far

Some of these won't be parsed at all, but the list is here for completeness

- [ ] `TES3` (Main header record)
- [ ] `GMST` (Game settings)
- [ ] `GLOB` (Global variables)
- [ ] `CLAS` (Classes)
- [ ] `FACT` (Factions)
- [ ] `RACE` (Races)
- [ ] `SOUN` (Sounds)
- [x] `SKIL` (Skills) - "use values" are ignored
- [ ] `MGEF` (Magic effects)
- [ ] `SCPT` (Scripts)
- [ ] `REGN` (Regions)
- [ ] `BSGN` (Birth signs)
- [ ] `LTEX` (Land textures?)
- [ ] `STAT` (Statics)
- [ ] `MISC` (Miscellaneous items)
- [ ] `WEAP` (Weapons)
- [ ] `CONT` (Containers)
- [ ] `SPEL` (Spells)
- [ ] `BODY` (Body parts)
- [ ] `LIGH` (Lights)
- [ ] `ENCH` (Enchantments)
- [ ] `NPC_` (NPCs)
- [ ] `ARMO` (Armour)
- [ ] `CLOT` (Clothing)
- [ ] `REPA` (Repair items)
- [ ] `ACTI` (Activators)
- [ ] `APPA` (Alchemy apparatus)
- [ ] `LOCK` (Lockpicking items)
- [ ] `PROB` (Probe items)
- [ ] `INGR` (Ingredients)
- [ ] `BOOK` (Books and papers)
- [ ] `ALCH` (Potions?)
- [ ] `LEVI` (Levelled items)
- [ ] `LEVC` (Levelled creatures)
- [ ] `CELL` (Cells)
- [ ] `LAND` (Landscapes)
- [ ] `PGRD` (Path grids)
- [ ] `SNDG` (Sound generators)
- [ ] `DIAL` (Dialogue/journal topic)
- [ ] `INFO` (Dialogue/journal records)
