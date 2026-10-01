HOW TO CONFIGURE:


After installing the mod and loading a save file, a text file will be created in:
%localappdata%\Larian Studios\Baldur's Gate 3\Script Extender  (you can copy paste this into windows search to go there)

The config file is called "CombatRandomizerConfig.txt"


If you can't find it, click the settings icon in the Larian launcher (bottom left), then scroll down and find the "Open profile folder" button. The Script Extender folder should be there.

Configuration options:

The config file CAN be edited in-game. You need to manually reload it by using a "Ping" anywhere (ping is the button next to the minimap that marks a spot). If you want le funny mode, use TransformAllNpcs (very good for videos/streams).

Randomness - this number decides how extreme NPCs can get, it affects the amount of boosts/statuses/etc. they gain.
Recommended value (for a normal-ish playthrough) is around 20. Can go up to any number you want, may cause long-ish delays at high (100+) values. This is NOT a percentage, it's just a number used for random rolls. Think of it as a multiplier for other boosts.

NpcEquipment- this is a percentage chance (0-100) for NPCs to gain new equipment. Each equipment slot is rolled separately. Affected by EnemiesOnly and NpcsDropAddedItems. As of v1.9.0.2 , equipment is deleted immediately if the enemy did not succeed a NpcsDropAddedItems roll.

NpcSpells - this is a percentage chance (0-100) for NPCs to gain new random spells. Due to the way their AI is programmed, some NPCs can decide to spam certain spells, so a value of 100 is not recommended(unless you like fun). Affected by Randomness and EnemiesOnly.

Transformations - this is a percentage chance (0-100) for NPCs to transform into a random model. Can break some stuff, for example if an enemy gets a dragon model in a cave it might become unable to move due to collision. Affected by EnemiesOnly and ActualTransformations. If you want the enemies to not just be disguised as a different model, use ActualTransformations (described later). The game is (sadly) limited to only in-region NPCs for transformations, so if you're in Act 1 you will mostly see characters from Act 1.

EnemiesOnly - this is a toggle (0 or 1). If it's 1, then only enemies in combat will be affected by the mod. If it's 0, all NPCs in combat will be affected.

LevelUps - this is a percentage chance (0-100) for NPCs to randomly level up. NOT RECOMMENDED. Most enemies do not scale with level, and this will boost your XP gains exponentially, so only use it if you want that. Affected by Randomness. Also might crash the game if you've got high enemy multiplication settings, nothing I can do about that.

ResourceBoosts - this is a percentage chance (0-100) for NPCs to gain random resource boosts. This includes actions, bonus actions, rage points, sorcery points, superiority dies, wildshape charges, lay on hands charges, channel oath charges, channel divinity charges and ki points. Affected by EnemiesOnly and Randomness.

Statuses - this is a percentage chance (0-100) for NPCs to gain random (positive or negative) statuses for a random duration. Affected by EnemiesOnly, Randomness and NegativeStatuses.

Consumables- this is a percentage chance (0-100) for NPCs to gain random consumables. A lot of enemies really like to spam them so a value of 100 is NOT recommended. Affected by Randomness and EnemiesOnly. Enemies will blow the shit out of you with OP bombs so use at own discretion.

NegativeStatuses- this is a toggle (0 or 1). If the value is 1, then enemies are allowed to gain negative statuses as well as positive ones, if the value is 0 then only positive statuses will be given. Only works if Statuses is higher than 0.

HealthBoosts - this is a percentage chance (0-100) for NPCs to gain a random amount of bonus (temporary) health. The health has been changed from max HP to reduce annoyance from enemies healing a shit ton and to allow clones to receive
HP boosts. Affected by Randomness and EnemiesOnly.

NpcsDropAddedItems - this is a percentage chance (0-100) for NPCs to drop items given by NpcEquipment and Consumables. Only use if you want to gain OP items. As of v1.9.0.2 , equipment is deleted immediately on death if the enemy did not succeed the item drop roll.

StatBoosts - this is a percentage chance (0-100) for NPCs to gain random stat boosts. Affected by EnemiesOnly and Randomness.

ACBoosts - this is a percentage chance (0-100) for NPCs to gain or lose a random amount of AC. Affected by EnemiesOnly and Randomness. The formula for calculation is a random number between 1 and Randomness divided by 3, rounded down minus random number between 1 and Randomness divided by 2, rounded down. TL;DR negative AC values are more likely cause they gain a shit ton from equipment anyway.


DamageBonus- this is a percentage that dictates how much extra damage your party members will deal to enemies. For example, setting this value to 100 would double damage done to enemies (in combat). This bonus will be applied as separate instances of damage, to bypass damage cap limitations (if you want to run 10 million% damage boost or something). Recommended, you will need it. Enabling non-lethal attacks will disable this feature.

ActualTransformations - this is a toggle (0 or 1). This makes enemies become who they transformed into. The game will attempt to combine the AI of the original and the transformed creature, which can be pretty wonky. Hopefully doesn't crash the game too much. Might cause very weird interactions. The "original" NPCs will still exist, so quests shouldn't be super broken.

EnemyMultiplication - this dictates how many times each NPC will be cloned in combat, for example a value of 1 would make everyone in combat get 1 clone of themselves (that then gets randomized separately). Affected by EnemiesOnly.
The clones appear slightly after the combat starts for not crashing reasons. Setting this to a very high number will likely softlock the fight completely. Clones attempt to automatically inherit equipment from the thing they were cloned from, but are then randomized separately and may gain different equipment. In big fights, clones may appear out of vision to the players and enter combat only when you move closer. Clones can receive resource, AC, and other boosts (though again, they are rolled separately), however their base stats may be slightly lower than the character they've been cloned from. You can change this to only clone enemies using the EnemyOnlyDuplication config option, or only target allies using AllyOnlyDuplication (explained lower in the mod description). Can fail to work if the enemies try to spawn in an invalid location (same thing happens in vanilla with stuff like the ogre horn so don't blame me). Clones also seemingly don't get name changes because the game hates everything fun. To make cloning chance based, use EnemyDuplicationChance. Clones can be looted mid-combat, however they will automatically be cleaned up after the fight. This feature can be kinda buggy because some fights are scripted and that messes with game logic.

ChangeSize- this is a percentage chance (0-100) for NPCs to change their size. Setting this to 100 will guarantee everyone will change their size. Minimum possible size is 0.2x, maximum is 2.5x. (size not configurable to prevent softlocks).
Might get some NPCs stuck in places because of their size, so if you're using it make sure to save often.


RaidBosses - this is a percentage change (0-100) for a random ENEMY in combat to become one of the available raid boss variants (4 variants are available). They are special enemies that get their own pre-configured stats and abilities. Raid boss events will make every other enemy in combat Surprised for X amount of turns (configurable using the FreezeTurns config option). They will also become enraged after X amount of turns (configurable using RaidBossEnrageTurns config option). After becoming enraged, they become much stronger. Allies/neutral NPCs in battle cannot become raid bosses and will not be surprised by a raid boss appearing. (Thanks to Muffin for the idea!)

RaidBossEnrageTurns - this is the number of turns before a raid boss becomes enraged.

FreezeTurns - this is the number of turns enemies become Surprised for when a raid boss appears.

Passives - this is a percentage chance (0-100) for enemies to gain a random passive.

EnemyDuplicationChance- this is a percentage (0-100) that dictates the chance for an enemy to be duplicated. If set to 100, the enemies will  always succeed a duplication check, however the mod also checks RandomDuplicationAmount afterwards.

EnemyOnlyDuplication - this is a toggle (0-1). If set to 1, only enemies will be duplicated in combat, if set to 0, then everyone can be duplicated.

AllyOnlyDuplication - this is a toggle (0-1). If set to 1, only allies will be duplicated in combat, if set to 0, then everyone can be duplicated. Not compatible with EnemyOnlyDuplication (obviously)

RandomDuplicationAmount - this is a toggle (0-1). If set to 0, enemies will duplicate the exact amount of times specified by EnemyMultiplication. If set to 1, enemies will duplicate a random amount of times between 0 and EnemyMultiplication.

NameChanges - this is a percentage chance (0-100%) for each NPC to gain a random epithet (like Goblin Scout The Stupid as an example) after their name. It's purely a visual feature. Affected by EnemiesOnly. NPCs with changed names will appear as "Not Found" after restarting the game, so only use this if you don't mind that.

Elites - this is a percentage chance (0-100%) for each NPC to become Elite. Elite NPCs gain extra health and can be one of the 7 possible types:
Blazing - leaves a trail of hellfire and burns enemies it attacks.
Glacial - chills enemies it attacks and sometimes spawns a big ice field around itself.
Overloading - gains slightly more health, zaps enemies it attacks. On death, can electrify every surface around itself in a big area.
Malachite - applies anti-healing and poison on hit. On death, leaves a pool of acid.
Frenzied - gains extra movement, and temporary Unstoppable and Legendary Resistance.
Volatile - creates small explosions on the target when attacking, dealing extra force damage. At 60% health, will initiate a countdown to self-destruct. One-shotting them will not make them explode.
Leeching - heals and gains extra temporary health when hitting enemies, applies bleed.

Affected by EnemiesOnly.

All elites have effects on them and a prefix in their name to differentiate which is which.
(the idea was totally yoinked from Risk of Rain, epic game)

GiveRandomSpellToParty - this is a percentage chance (0-100%) for each party member to get a random spell from the same list the enemies get spells from. Most spells given from this only cost an action, and no actual resource. The given spells are removed after combat ends. Good spells not guaranteed.

TransformPartyMembers - this is a percentage chance (0-100%) for each party member to transform into a random NPC when combat starts. This can transform people even if they aren't in combat yet, like if one of your party members join combat it will still trigger. Transformations will be removed once the combat that triggered them ends. The transformations use the same rules as the NPCs, so you will NOT lose spells you had, only gain ones that the NPC you transformed into has.
This will also change your health to whatever you transformed into. Equipment changes are also possible, if the NPC you transformed into has equipment it's supposed to wear.
May cause characters to remain in their transformed form in some cases, especially when they die and are unable to lose their transformation. Use Script extender console, RemoveTransforms(GetHostCharacter()) command to get rid of it.

WhoopsAllBosses - this is a percentage chance (0-100%) that will transform every enemy into a "boss" enemy if it succeeds. Transformations and ActualTransformations must be enabled for this to function properly. The roll for it only happens once per combat and resets after combat ends.

RandomTreasure - this is a percentage chance (0-100%) that generates random loot in NPC inventories when they died. It picks a random existing treasure table and gives loot from that, so it might range from magic items to random junk. The chance is rolled every time an NPC dies.


TransformAllNpcs - this is a toggle (0 or 1). If set to 1, then all NPCs in the current region will immediately transform into random NPCs instead. Quests/dialogs will remain the same, just that NPCs will have different stats and appearances. This is PERMANENT. Npcs transformed by this will be unaffected by Transformations caused by Randomizer if they get into combat (as in, they won't transform into a different thing again). Certain "cutscene" NPCs will appear as normal but they don't actually exist so can't do much about that.

AutomaticallyReadConfig - this is a toggle (0 or 1). If enabled, the game will read and update the config every few seconds automatically. If disabled, you need to use "Ping" to reload the config. Automatically reading config may cause crashes when loading saves in rare situations.

ReadingAbilityUnlocked - Set this to 1 to disable the message box. Hope you read something while scrolling down here!

ConsoleDebug-  This is a toggle (0 or 1). It makes the mod print out what it's doing in the script extender console. Don't use unless you're interested and know what you're looking at, as it will reduce performance and spam up your console window.