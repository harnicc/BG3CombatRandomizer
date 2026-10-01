# 🎲 BG3 Combat Randomizer

A chaotic and highly customizable combat randomizer mod for **Baldur's Gate 3**, powered by BG3 Script Extender. Randomize enemy stats, spells, equipment, transformations, clones, elite variants, and much more!

---

## 🤝 Contributing

Contributions are more than welcome! 

Since this project is currently maintained solely by **1 person in their free time without any financial compensation**, help of any kind—whether it's fixing bugs, adding new features, or improving documentation—is immensely appreciated!

Feel free to open an **Issue**, submit a **Pull Request**, or share your feedback and ideas.

---

## ⚙️ How to Configure

### 📁 File Location

After installing the mod and loading a save file, a configuration file named `CombatRandomizerConfig.txt` will be automatically created in:

```text
%localappdata%\Larian Studios\Baldur's Gate 3\Script Extender
```
*(You can copy and paste this path directly into Windows Search / Explorer).*

> [!TIP]
> **Can't find the folder?**
> 1. Open the **Larian Launcher**.
> 2. Click the **Settings icon** (⚙️) in the bottom-left corner.
> 3. Scroll down and click <kbd>Open profile folder</kbd>.
> 4. Navigate to the `Script Extender` directory inside.

---

### 🔄 Applying Changes In-Game

The config file **CAN** be edited while the game is running:

* **Manual Reload:** Press <kbd>Ping</kbd> anywhere in-game (the button next to the minimap that marks a spot) to reload your settings instantly.
* **Automatic Reload:** Set `AutomaticallyReadConfig = 1` to let the game check and update settings every few seconds.

> [!WARNING]
> Enabling `AutomaticallyReadConfig` may cause rare crashes when loading saves. Manual reloading via <kbd>Ping</kbd> is recommended for maximum stability.

---

## 🎛️ Configuration Options

### 🛠️ Core & Debug Settings

* `AutomaticallyReadConfig` `(0 or 1)` — Toggles automatic config reloading every few seconds.
* `ReadingAbilityUnlocked` `(0 or 1)` — Set to `1` to disable the in-game splash message box.
* `ConsoleDebug` `(0 or 1)` — Prints mod activity in the Script Extender console. *(Reduces performance; only use if debugging).*

---

### 📊 Multipliers & Targeting

* `Randomness` `(Numeric Value)` — Determines how extreme randomized stats, boosts, and statuses become.
  * **Recommended:** `20` for a standard playthrough.
  * *Note:* This is a multiplier, not a percentage. High values (100+) may cause delay during turn processing.
* `EnemiesOnly` `(0 or 1)` — 
  * `1`: Only hostile enemies in combat are affected.
  * `0`: All NPCs in combat (allies, neutrals, enemies) are affected.

---

### ⚔️ NPC Stat & Ability Modifiers

* `NpcEquipment` `(0 - 100%)` — Chance for NPCs to gain new equipment (rolled per slot). Affected by `EnemiesOnly` and `NpcsDropAddedItems`.
  * *Note:* As of v1.9.0.2, equipment is deleted immediately on death if the enemy fails the `NpcsDropAddedItems` drop roll.
* `NpcSpells` `(0 - 100%)` — Chance for NPCs to gain random spells. 
  * *Values around 100 are not recommended unless you enjoy spell spam.*
* `ResourceBoosts` `(0 - 100%)` — Chance for NPCs to gain extra resource pools (Actions, Bonus Actions, Rage, Ki, Sorcery Points, Superiority Dice, Spell Slots, Wildshape, Lay on Hands, Channel Oath/Divinity charges).
* `Statuses` `(0 - 100%)` — Chance for NPCs to gain random status effects for a random duration.
* `NegativeStatuses` `(0 or 1)` — Allows NPCs to roll negative statuses alongside positive ones. Requires `Statuses > 0`.
* `Consumables` `(0 - 100%)` — Chance for NPCs to carry random consumables (bombs, potions). Enemies will use them aggressively.
* `HealthBoosts` `(0 - 100%)` — Chance to gain bonus temporary health.
* `StatBoosts` `(0 - 100%)` — Chance for NPCs to gain random core attribute boosts.
* `ACBoosts` `(0 - 100%)` — Chance for NPCs to gain or lose Armor Class. 
  * *Formula leans slightly negative to offset heavy equipment gains.*
* `Passives` `(0 - 100%)` — Chance for NPCs to gain random passive abilities.
* `ChangeSize` `(0 - 100%)` — Chance for NPCs to scale in size (`0.2x` to `2.5x`).
  * *May cause oversized NPCs to get stuck in narrow geometry; save often!*
* `LevelUps` `(0 - 100%)` — **NOT RECOMMENDED.** Chance for NPCs to randomly level up. Boosts XP gains exponentially and may crash high-density fights.

---

### 👥 Duplication & Clones

* `EnemyMultiplication` `(Numeric Value)` — Number of clones spawned per NPC in combat (e.g., `1` doubles everyone).
* `EnemyDuplicationChance` `(0 - 100%)` — Percentage chance for an NPC to attempt duplication.
* `RandomDuplicationAmount` `(0 or 1)` — 
  * `0`: Spawns exact amount set in `EnemyMultiplication`.
  * `1`: Spawns a random amount between `0` and `EnemyMultiplication`.
* `EnemyOnlyDuplication` `(0 or 1)` — `1` restricts cloning strictly to enemies.
* `AllyOnlyDuplication` `(0 or 1)` — `1` restricts cloning strictly to allies *(Incompatible with EnemyOnlyDuplication)*.

> [!NOTE]
> **Cloning Behavior:** Clones spawn slightly after combat starts to prevent crashes. They inherit equipment before receiving separate randomizations. Clones clear automatically when combat ends.

---

### 🐲 Transformations & Cosmetics

* `Transformations` `(0 - 100%)` — Chance for NPCs to visually transform into a random character model. Limited to in-region models per Act.
* `ActualTransformations` `(0 or 1)` — Forces transformed NPCs to adopt the stats, abilities, and AI of the target creature.
* `WhoopsAllBosses` `(0 - 100%)` — Global roll at combat start to convert every enemy into a boss unit *(Requires Transformations & ActualTransformations)*.
* `TransformAllNpcs` `(0 or 1)` — **PERMANENT.** Instantly transforms every NPC in the current region upon loading. Great for chaotic streams/videos!
* `NameChanges` `(0 - 100%)` — Adds random titles/epithets to NPC names (e.g., *Goblin Scout The Stupid*). Purely visual.

---

### 💀 Special Modes: Elites & Raid Bosses

#### **Elites (`Elites = 0 - 100%`)**
Chance for NPCs to turn into powerful Elite variants with custom visual effects and prefixes (inspired by *Risk of Rain*):

| Elite Type | Signature Effect |
| :--- | :--- |
| **🔥 Blazing** | Leaves hellfire trails and burns targets on hit. |
| **❄️️ Glacial** | Chills targets on hit and spawns ice fields around itself. |
| **⚡ Overloading** | Extra HP, zaps targets, and triggers a massive electrical burst on death. |
| **🧪 Malachite** | Applies anti-healing and poison on hit; leaves an acid pool on death. |
| **💨 Frenzied** | Extra movement speed, temporary *Unstoppable*, and *Legendary Resistance*. |
| **💣 Volatile** | Force explosions on hit. Starts self-destruct countdown at 60% HP. |
| **🩸 Leeching** | Lifesteal on hit, grants temp HP, and inflicts bleeding. |

#### **Raid Bosses**
* `RaidBosses` `(0 - 100%)` — Chance for a random enemy to become 1 of 4 custom Raid Boss variants with unique stats/abilities.
* `FreezeTurns` `(Numeric Value)` — Number of turns non-boss enemies are **Surprised** when a Raid Boss appears.
* `RaidBossEnrageTurns` `(Numeric Value)` — Number of turns before the Raid Boss becomes enraged and powers up.

*(Special thanks to Muffin for the Raid Boss idea!)*

---

### 🎒 Items & Loot Drops

* `NpcsDropAddedItems` `(0 - 100%)` — Chance for NPCs to drop randomized equipment and consumables added by the mod upon death.
* `RandomTreasure` `(0 - 100%)` — Chance for dying NPCs to drop loot generated from global treasure tables.

---

### 🛡️ Party Settings

* `DamageBonus` `(Percentage)` — Extra damage percentage dealt by party members (e.g., `100` = double damage). Applied as separate damage instances to bypass caps. *(Non-lethal attacks disable this feature).*
* `GiveRandomSpellToParty` `(0 - 100%)` — Gives party members a temporary random spell at the start of combat (removed post-combat).
* `TransformPartyMembers` `(0 - 100%)` — Randomly transforms party members into random NPCs during combat.

> [!TIP]
> **Stuck in Transformation?**  
> If a party member remains transformed after combat, open the Script Extender console and run:
> ```lua
> RemoveTransforms(GetHostCharacter())
> ```
