# The Elder Scrolls III: Morrowind data presenter

[![Build Status](https://travis-ci.org/sevenseacat/esm-data-presenter.svg?branch=master)](https://travis-ci.org/sevenseacat/esm-data-presenter)
[![Ebert](https://ebertapp.io/github/sevenseacat/esm-data-presenter.svg)](https://ebertapp.io/github/sevenseacat/esm-data-presenter)

The end goal is to create a read-only webapp to present game data used in Morrowind.

At the moment this is still in the "parse the ESM data file into something readable" stage.

Using the amazing work of Dave Humphrey detailed here: http://www.uesp.net/morrow/tech/mw_esm.txt

## The Plan

- Parse the ESM data file into a meaningful format
- Insert the parsed data into a database
- Build frontend to present data nicely

## Record types

Some of these won't be handled at all, but the list is here for completeness

| Parsed | Tested | Imported | Tested | Displayed | Name |
| :---:  | :---:  | :---:    | :---:  | :---:     |------|
|        |        |          |        |           | `TES3` (Main header record) |
| ✓      | ✓      |          |        |           | `CLAS` (Classes) |
| ✓      | ✓      | ✓        |        |           | `FACT` (Factions) |
| ✓      |        |          |        |           | `RACE` (Races) |
| ✓      | ✓      | ✓        | ✓      |           | `SKIL` (Skills) - "use values" are ignored |
| ✓      | ✓      | ✓        | ✓      |           | `MGEF` (Magic effects) |
| ✓      | ✓      | ✓        | ✓      |           | `SCPT` (Scripts) |
| ✓      | ✓      |          |        |           | `REGN` (Regions) |
| ✓      | ✓      |          |        |           | `BSGN` (Birth signs) |
| ✓      | ✓      |          |        |           | `MISC` (Miscellaneous items) |
| ✓      | ✓      |          |        |           | `WEAP` (Weapons) |
| ✓      | ✓      |          |        |           | `CONT` (Containers) |
| ✓      | ✓      |          |        |           | `SPEL` (Spells) |
| ✓      | ✓      | ✓        |        |           | `ENCH` (Enchantments) |
| ✓      | ✓      |          |        |           | `NPC_` (NPCs) |
| ✓      | ✓      |          |        |           | `ARMO` (Armour) |
| ✓      | ✓      |          |        |           | `CLOT` (Clothing) |
| ✓      | ✓      |          |        |           | `REPA` (Repair items) |
| ✓      | ✓      |          |        |           | `APPA` (Alchemy apparatus) |
| ✓      | ✓      |          |        |           | `LOCK` (Lockpicking items) |
| ✓      | ✓      |          |        |           | `PROB` (Probe items) |
| ✓      | ✓      |          |        |           | `INGR` (Ingredients) |
| ✓      | ✓      | ✓        |        |           | `BOOK` (Books and papers) |
| ✓      | ✓      |          |        |           | `ALCH` (Potions?) |
| ✓      | ✓      |          |        |           | `LEVI` (Levelled items) |
| ✓      | ✓      |          |        |           | `CELL` (Cells) |
| ✓      | ✓      |          |        |           | `DIAL` (Dialogue/journal topics) |
| ✓      | ✓      |          |        |           | `INFO` (Dialogue records) |
| ✓      | ✓      |          |        |           | `INFO` (Journal records) |

### Record types (probably) not going to be done

- `GMST` (Game settings)
- `GLOB` (Global variables)
- `SOUN` (Sounds)
- `LTEX` (Land textures?)
- `STAT` (Statics)
- `BODY` (Body parts)
- `LIGH` (Lights)
- `LAND` (Landscapes)
- `PGRD` (Path grids)
- `SNDG` (Sound generators)
- `ACTI` (Activators)
- `LEVC` (Levelled creatures)

### Other

- `DOOR` (Doors)
- `CREA` (Creatures and animals)
