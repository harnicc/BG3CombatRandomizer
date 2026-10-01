## 📂 Project Structure

```text
Randomizer/
├── 📁 Localization/
│   └── 📁 English/
│       └── 📄 __MT_GEN_LOCA_...      # Localization files and English text strings
├── 📁 Mods/
│   └── 📁 Combat_Randomizer/
│       ├── 📁 ScriptExtender/
│       │   ├── 📁 Lua/
│       │   │   ├── 📁 Combat_Randomizer/
│       │   │   │   └── 📄 Main.lua            # Empty
│       │   │   ├── 📄 BootstrapServer.lua      # Main mod logic and combat event handlers
│       │   │   └── 📄 CR_Tables.lua           # Data tables (spells, items, statuses, etc.)
│       │   └── 📄 Config.json                 # Script Extender configuration settings
│       ├── 📄 meta.lsx                         # Mod metadata (UUID, name, version, dependencies)
│       ├── 📁 Gustav/
│       │   └── 📁 Globals/                     # Base game global data overrides
│       └── 📁 GustavDev/                       # Extended game content overrides
├── 📁 Public/
│   └── 📁 Combat_Randomizer/
│       ├── 📁 Shapeshift/
│       │   └── 📄 Rulebook.lsx                # Shapeshifting and transformation rules
│       └── 📁 Stats/
│           └── 📁 Generated/
│               └── 📁 Data/                    # Engine stat definitions
│                   ├── 📄 Data.txt             # General stats configuration
│                   ├── 📄 Spell_Shout.txt      # 'Shout' type spell definitions
│                   ├── 📄 Spell_Target.txt     # 'Target' type spell definitions
│                   ├── 📄 Spell_Zone.txt       # 'Zone' area-of-effect spell definitions
│                   └── 📄 Status_BOOST.txt     # Status effects, buffs, and debuffs
├── 📄 OsiMethodsBG3.lua                        # Osiris API autocomplete and helper definitions
└── 📄 README.md                                # Project documentation
```

---

### 📝 Key Components Breakdown

* **`Mods/Combat_Randomizer/ScriptExtender/Lua/`**: Contains the core Lua scripts executing real-time randomization via **Script Extender**.
  * `Main.lua`: Empty.
  * `CR_Tables.lua`: Stores data arrays for spell IDs, transformation forms, status effects, and loot pools.
  * `BootstrapServer.lua`: Manages combat initialization, turn hooks, unit deaths, and config reloads.
* **`Public/Combat_Randomizer/Stats/Generated/Data/`**: Engine `.txt` data files defining modified stats, spells, and status effects.
* **`Localization/`**: Handles localized text strings and dynamic character epithets.