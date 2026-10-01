local CR_Tables = require "CR_Tables"

local function OnSessionLoaded()
    print("Combat Randomizer - v2.1.0.6")
    local isDebug = tonumber(0);
    CombatRandomizer_ChosenRaidBoss = ""
    RandomRaidBossTransformation = ""
    Vars = {}
    ConfigFailed = 0
    CombatRandomizer_ClonedNPCS = {}
    CR_SpellsAddedToParty = {}
    CR_TransformedPartyMembers = {}
    CR_WhoopsAllBosses = 0
    CR_NexusCommenterMessageTimer = 60000

    local transformVFX = "d510b142-164e-4196-b1b7-41c4a3b5367f"
    local transformVFXparty = "d510b142-164e-4196-b1b7-41c4a3b5367a"

    local function IsExcludedOrParty(entityGuid)
        for _, id in ipairs(CombatRandomizer_ExcludedNPCs) do
            if id == entityGuid then
                return true
            end
        end

        if Osi.IsPlayer(entityGuid) == 1 then
            return true
        end

        local entity = Ext.Entity.Get(entityGuid)
        if entity and entity.PartyMember and entity.PartyMember.Party then
            return true
        end

        return false
    end

    function ResetConfig()
        ConfigFailed = 0

        local default_config =
            [[
            Randomness=20
            NpcEquipment=50
            NpcSpells=100
            Transformations=100
            EnemiesOnly=0
            LevelUps=10
            ResourceBoosts=30
            Statuses=30
            Consumables=10
            NegativeStatuses=1
            HealthBoosts=50
            NpcsDropAddedItems=20
            StatBoosts=20
            ACBoosts=20
            DamageBonus=40
            ActualTransformations=1
            EnemyMultiplication=0
            ChangeSize=100
            RaidBosses=0
            RaidBossEnrageTurns=4
            FreezeTurns=3
            Passives=50
            EnemyDuplicationChance=50
            EnemyOnlyDuplication=1
            AllyOnlyDuplication=0
            RandomDuplicationAmount=0
            NameChanges=0
            Elites=0
            GiveRandomSpellToParty=30
            TransformPartyMembers=10
            WhoopsAllBosses=10
            RandomTreasure=10
            TransformAllNpcs=0
            AutomaticallyReadConfig=0
            ReadingAbilityUnlocked=0
            ConsoleDebug=0
            ]]

        Ext.IO.SaveFile("CombatRandomizerConfig.txt", default_config)
        GetStuffFromFile()
    end

    function Patch1point8configupdate()
        local defaults = {
            {"Randomness", 20},
            {"NpcEquipment", 50},
            {"NpcSpells", 100},
            {"Transformations", 100},
            {"EnemiesOnly", 0},
            {"LevelUps", 10},
            {"ResourceBoosts", 30},
            {"Statuses", 30},
            {"Consumables", 10},
            {"NegativeStatuses", 1},
            {"HealthBoosts", 30},
            {"NpcsDropAddedItems", 20},
            {"StatBoosts", 20},
            {"ACBoosts", 20},
            {"DamageBonus", 40},
            {"ActualTransformations", 1},
            {"EnemyMultiplication", 0},
            {"ChangeSize", 50},
            {"RaidBosses", 1},
            {"RaidBossEnrageTurns", 5},
            {"FreezeTurns", 3},
            {"Passives", 50},
            {"EnemyDuplicationChance", 50},
            {"EnemyOnlyDuplication", 1},
            {"AllyOnlyDuplication", 0},
            {"RandomDuplicationAmount", 0},
            {"NameChanges", 0},
            {"Elites", 10},
            {"GiveRandomSpellToParty", 30},
            {"TransformPartyMembers", 10},
            {"WhoopsAllBosses", 10},
            {"RandomTreasure", 10},
            {"TransformAllNpcs", 0},
            {"AutomaticallyReadConfig", 0},
            {"ReadingAbilityUnlocked", 0},
            {"ConsoleDebug", 0}
        }

        local lines = {}
        for _, item in ipairs(defaults) do
            local key, default = item[1], item[2]
            local value = (Vars[key] ~= nil) and tonumber(Vars[key]) or default
            table.insert(lines, key .. "=" .. value)
        end

        local new_config = table.concat(lines, "\n") .. "\n"
        Ext.IO.SaveFile("CombatRandomizerConfig.txt", new_config)
    end

    --fuck json, all my homies hate json
    function GetStuffFromFile()
        Vars = {}
        local s = Ext.IO.LoadFile("CombatRandomizerConfig.txt")

        if not s then
            print("Combat Randomizer - Configuration file not found. Creating one...")
            ResetConfig()
            return GetStuffFromFile()
        end

        for k, v in s:gmatch("([%w_]+)=([%w_%-]+)") do
            Vars[k] = tonumber(v) or v
        end

        isDebug = tonumber(Vars["ConsoleDebug"])
    end

    function ResetModdedItemsFile()
        local moddedfile =
            [[
            {
              "Transformations": [],
              "Spells": [],
              "Armor": [],
              "Gloves": [],
              "Helmets": [],
              "Shields": [],
              "Cloaks": [],
              "Boots": [],
              "Rings": [],
              "Amulets": [],
              "Consumables": [],
              "Weapons": [],
              "Statuses": [],
              "NegativeStatuses": []
            }
        ]]

        Ext.IO.SaveFile("CombatRandomizerModdedItems.txt", moddedfile)
        print("Combat Randomizer - Making modded items file.")
    end

    GetStuffFromFile()
    Patch1point8configupdate()
    GetStuffFromFile()
    if (ConfigFailed == 1) then
        print("Combat Randomizer - Configuration file load failed. Reseting file to standard version")
        ResetConfig()
    end

    function GetUpToHundred()
        local randomuptohundred = math.random(100)
        if (isDebug == 1) then
            print("Returning random up to 100: " .. randomuptohundred)
        end
        return (randomuptohundred)
    end

    function PrintoutConfig()
        local outputBuffer = {}
        
        for key, value in pairs(Vars) do
            local numericValue = tonumber(value) or 0
            table.insert(outputBuffer, "\n" .. key .. "= " .. numericValue)
        end
        
        print(table.concat(outputBuffer, ""))
    end

    if (isDebug == 1) then
        PrintoutConfig()
    end

    function GetModdedStuffFromFile()
        local fileName = "CombatRandomizerModdedItems.txt"
        local modded_stuff = Ext.IO.LoadFile(fileName)

        if modded_stuff == nil then
            ResetModdedItemsFile()
            modded_stuff = Ext.IO.LoadFile(fileName)
        end

        if modded_stuff == nil then return end

        local jsoned_file = Ext.Json.Parse(modded_stuff)
        if type(jsoned_file) ~= "table" then return end

        local categoryMap = {
            ["Transformations"]  = Table,
            ["Spells"]           = SpellsTable,
            ["Armor"]            = Armor,
            ["Gloves"]           = Gloves,
            ["Helmets"]          = Helmets,
            ["Shields"]          = Shields,
            ["Cloaks"]           = Cloaks,
            ["Boots"]            = Boots,
            ["Rings"]            = Rings,
            ["Amulets"]          = Amulets,
            ["Consumables"]      = Consumables,
            ["Weapons"]          = Weapons,
            ["Statuses"]         = Statuses,
            ["NegativeStatuses"] = NegativeStatuses
        }

        local isDebug = isDebug == 1

        for jsonKey, targetTable in pairs(categoryMap) do
            local itemList = jsoned_file[jsonKey]

            if type(itemList) == "table" then
                for _, item in ipairs(itemList) do
                    table.insert(targetTable, item)

                    if isDebug then
                        print("Combat Randomizer - adding modded " .. jsonKey:lower() .. ": " .. tostring(item))
                    end
                end
            end
        end
    end

    GetModdedStuffFromFile()

    Current_combat = ""
    Party = {}
    CombatNPCS = {}
    AddedItems = {}
    AddedConsumables = {}
    StupidFuckingBuggedAddedItems = {}
    function GetGUID(str) -- returns just the uuid without the prefix cause the game is FUCKIN STUPID and they are not the same apparently
        return string.sub(str, -36)
    end
    function CheckIfOrigin(target)
        for i = #CombatRandomizer_ExcludedNPCs, 1, -1 do
            if (CombatRandomizer_ExcludedNPCs[i] == target or GetGUID(CombatRandomizer_ExcludedNPCs[i]) == target) then
                return 1
            end
        end
        return 0
    end
    function CheckIfParty(target)
        for k, d in ipairs(Osi.DB_PartyMembers:Get(nil)) do
            table.insert(Party, d[1])
        end
        for i = #Party, 1, -1 do
            if
                (Osi.IsPartyMember(target, 0) == 1 or Osi.IsPartyMember(target, 1) == 1 or
                    Osi.IsPartyMember(target, 2) == 1 or
                    Osi.IsPartyMember(target, 3) == 1 or
                    Osi.IsPartyMember(target, 4) == 1)
             then
                return 1
            else
                return 0
            end
        end
    end

    function GetRandomTransform()
        CR_CurrentTransformTable = {}
        if (CR_WhoopsAllBosses ~= 2) then
            CR_CurrentTransformTable = Table
        else
            CR_CurrentTransformTable = CR_BossesTable
        end
        local randomtransformation = CR_CurrentTransformTable[math.random(#CR_CurrentTransformTable)]

        if (isDebug == 1) then
            print("Rolled transformation:" .. randomtransformation)
        end
        return randomtransformation
    end

    function RandomTransformAllNpcs()
        for i, v in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
            if(v ~= nil and Osi.HasAppliedStatus(v.Uuid.EntityUuid, "CR_TRANSFORMED") == 0 and
                    CheckIfParty(v.Uuid.EntityUuid) == 0 and
                    CheckIfOrigin(v.Uuid.EntityUuid) == 0 and
                    Osi.IsDead(v.Uuid.EntityUuid) == 0)
             then --
                --print("transforming:" .. v.Uuid.EntityUuid)
                Osi.Transform(v.Uuid.EntityUuid, GetRandomTransform(), transformVFX)
                if (isDebug == 1) then
                    print("Transforming: " .. v.Uuid.EntityUuid)
                end
                Osi.ApplyStatus(v.Uuid.EntityUuid, "CR_TRANSFORMED", -1)
            end
        end
    end

    Ext.Osiris.RegisterListener(
        "LevelGameplayStarted",
        2,
        "after",
        function(firstparam, secondparam)
            --print("first parameter:" .. firstparam)
            --print("second parameter:" .. secondparam)
            if (isDebug == 1) then
                print("Setting up blazing elite fire trails. (and the stupid unequip bugfix)")
            end
            Osi.TimerLaunch("ReadRandomizerConfig", 3000)
            Osi.TimerLaunch("TransformAllUntransformed", 500)
            Osi.TimerLaunch("DoBlazingEliteTrails", 200) --i fucking hate this shit but apparently that's how larian does trails as well. what the fuck
            Osi.TimerLaunch("BugFixUnequip", 200) --i hate this even more
            if (tonumber(Vars["ReadingAbilityUnlocked"]) ~= 1) then
                Osi.TimerLaunch("NexusCommentsRemover", 1000)
            end
            Osi.TimerLaunch("BugfixSummons", 500)

            -- print("current region 4:" .. CR_CurrentRegion)
        end
    )

    function GetRandomTransformRule()
        local rndrule = math.random(#TransformRules)
        local rndactualrule = TransformRules[rndrule]
        if (isDebug == 1) then
            print("Using transform rule:" .. rndactualrule)
        end
        return rndactualrule
    end

    function GiveRandomEquipment(target)
        AddedItems[target] = AddedItems[target] or {}

        local npcEquipmentThreshold = tonumber(Vars["NpcEquipment"]) or 0
        local isDebug = (isDebug == 1)

        local categories = {
            Armor,
            Amulets,
            Gloves,
            Helmets,
            Shields,
            Cloaks,
            Boots,
            Rings,
            Weapons
        }

        for _, itemList in ipairs(categories) do
            if itemList and #itemList > 0 then
                local passExtraCheck = (itemList ~= Shields) or (math.random(3) == 1)

                if passExtraCheck and npcEquipmentThreshold >= GetUpToHundred() then
                    local selectedItem = itemList[math.random(#itemList)]

                    Osi.TemplateAddTo(selectedItem, target, 1, 1)
                    table.insert(AddedItems[target], selectedItem)

                    if isDebug then
                        print(string.format("Character: %s gained item: %s", tostring(target), tostring(selectedItem)))
                    end
                end
            end
        end
    end

    function GiveRandomConsumables(target)
        AddedConsumables[target] = {}

        local itemCount = math.min(4, math.floor(GetLevelOfRandomness() / 8))

        for i = itemCount, 1, -1 do
            local rndcons = math.random(#Consumables)
            Osi.TemplateAddTo(Consumables[rndcons], target, 1, 1)
            AddedConsumables[target][i] = Consumables[rndcons]
            if (isDebug == 1) then
                print("Character: " .. target .. " gained item: " .. Consumables[rndcons])
            end
        end
    end

    function GetLevelOfRandomness()
        local rawConfig = tonumber(Vars["Randomness"]) or 20
        rawConfig = math.max(0, rawConfig)

        local cappedMax = math.floor((rawConfig / (rawConfig + 50)) * 100)

        if cappedMax < 1 then
            cappedMax = 1
        end

        return math.random(1, cappedMax)
    end

    function GetRandomTreasureTable()
        return CR_AllTreasureTables[math.random(#CR_AllTreasureTables)]
    end

    function ActuallySetRandomLevel(target, lvl)
        local adjusted_lvl = lvl + math.random(2) + GetLevelOfRandomness()
        if (isDebug == 1) then
            print("Character: " .. target .. " set to level:" .. adjusted_lvl + 1)
        end
        Ext.Entity.Get(target).EocLevel.Level = adjusted_lvl
        Osi.PROC_LevelUp(target)
    end

    function GetRandomHPIncrease(target)
        local hpincrease = GetLevelOfRandomness() * Osi.GetLevel(target)
        if (Osi.IsEnemy(target, Osi.GetHostCharacter()) == 1) then
            hpincrease = hpincrease + 2 --leftover code, aint deleting that though
        end
        if (isDebug == 1) then
            print("Character: " .. target .. " gained" .. hpincrease .. " temp health")
        end
        return "TemporaryHP(" .. hpincrease .. ")"
    end

    function SetRandomScale(target)
        local randscalemultiplier = math.random(25) / 10 --gives a random number between 0 and 2.5
        if (randscalemultiplier < 0.3) then -- dont want them to be at 0 size for obvious reasons
            randscalemultiplier = 0.3
        end
        if (isDebug == 1) then
            print("Character: " .. target .. " set to scale multiplier:" .. randscalemultiplier)
        end

        Osi.AddBoosts(target, "ScaleMultiplier(" .. randscalemultiplier .. ")", "1", "1")
    end

    function GiveRandomSpells(target)
        for i = math.random(math.floor(GetLevelOfRandomness() / 1.5)), 1, -1 do
            local rnd = math.random(#SpellsTable)
            local randomspell = SpellsTable[rnd]
            if (isDebug == 1) then
                print("Character: " .. target .. " gained spell:" .. randomspell)
            end
            Osi.AddSpell(target, randomspell, 1)
        end
    end

    local function ExtraActionPointsFunc()
        local rnd = GetLevelOfRandomness()
        local extraactionpoints = 0
        local actionRoll = math.random(1, 100)

        local chance1Action = math.floor(rnd * 0.6)

        local chance2Actions = (rnd >= 50) and math.floor((rnd - 50) * 0.2) or 0

        if actionRoll <= chance2Actions then
            extraactionpoints = 2
        elseif actionRoll <= chance1Action then
            extraactionpoints = 1
        end

        local extrabonuspoints = 0
        local bonusRoll = math.random(1, 100)

        local chance1Bonus = math.floor(rnd * 0.7)
        local chance2Bonus = (rnd >= 35) and math.floor((rnd - 35) * 0.4) or 0
        local chance3Bonus = (rnd >= 70) and math.floor((rnd - 70) * 0.2) or 0

        if bonusRoll <= chance3Bonus then
            extrabonuspoints = 3
        elseif bonusRoll <= chance2Bonus then
            extrabonuspoints = 2
        elseif bonusRoll <= chance1Bonus then
            extrabonuspoints = 1
        end
        return extraactionpoints, extrabonuspoints
    end

    function GiveRandomActionsAndBonus(target)
        local rnd = GetLevelOfRandomness()

        local extraactionpoints, extrabonuspoints = ExtraActionPointsFunc()

        local function ApplyResourceBoost(resourceType, amount, chanceDenominator, debugName, level)
            level = level or 0

            if amount <= 0 then
                return
            end

            if math.random(1, chanceDenominator) == 1 then
                local boostString = string.format("ActionResource(%s,%d,%d)", resourceType, amount, level)
                Osi.AddBoosts(target, boostString, "Randomizer", "Randomizer")

                if isDebug == 1 then
                    local levelText = level > 0 and string.format(" (Nivel %d)", level) or ""
                    print(string.format("Character: %s gained %s: +%d%s", target, debugName, amount, levelText))
                end
            end
        end

        ApplyResourceBoost("ActionPoint", extraactionpoints, 3, "action points")
        ApplyResourceBoost("BonusActionPoint", extrabonuspoints, 3, "bonus action points")

        local rageAmount = math.max(1, math.floor(rnd / 35))
        local sorceryAmount = math.max(1, math.floor(rnd / 10))
        local superiorityAmount = math.max(1, math.floor(rnd / 20))
        local wildshapeAmount = math.max(1, math.floor(rnd / 35))
        local layOnHandsAmount = math.max(1, math.floor(rnd / 15))
        local oathAmount = math.max(1, math.floor(rnd / 40))
        local divinityAmount = math.max(1, math.floor(rnd / 40))
        local kiAmount = math.max(1, math.floor(rnd / 10))

        ApplyResourceBoost("Rage", rageAmount, 2, "rage points")
        ApplyResourceBoost("SorceryPoint", sorceryAmount, 2, "sorcery points")
        ApplyResourceBoost("SuperiorityDie", superiorityAmount, 2, "superiority die")
        ApplyResourceBoost("WildShape", wildshapeAmount, 2, "wildshape charges")
        ApplyResourceBoost("LayOnHandsCharge", layOnHandsAmount, 2, "lay on hands charges")
        ApplyResourceBoost("ChannelOath", oathAmount, 2, "oath charges")
        ApplyResourceBoost("ChannelDivinity", divinityAmount, 2, "divinity points")
        ApplyResourceBoost("KiPoint", kiAmount, 2, "ki points")

        local maxSlotTier = math.min(6, math.max(1, math.floor(rnd / 16)))
        local slotsToAdd = math.min(3, math.max(1, math.floor(rnd / 30)))

        for slotLevel = 1, maxSlotTier do
            ApplyResourceBoost("SpellSlot", slotsToAdd, 2, "spell slots", slotLevel)
        end
    end

    function RemoveGivenItems(target)
        if (isDebug == 1) then
            print("Removing given items from: " .. target)
        end
        for i = 20, 1, -1 do
            if (target ~= nil and AddedItems[target] ~= nil and AddedItems[target][i] ~= nil) then
                if (isDebug == 1) then
                    print("Removing item: " .. AddedItems[target][i])
                end
                Osi.TemplateRemoveFrom(AddedItems[target][i], target, 15)
                Osi.RequestDelete(AddedItems[target][i])
            end
        end
    end

    function RemoveGivenConsumables(target)
        if (isDebug == 1) then
            print("Removing consumables from: " .. target)
        end
        for i = GetLevelOfRandomness(), 1, -1 do
            if (target ~= nil and AddedConsumables[target] ~= nil and AddedConsumables[target][i] ~= nil) then
                Osi.TemplateRemoveFrom(AddedConsumables[target][i], target, 99)
                Osi.RequestDelete(AddedConsumables[target][i])
            end
        end
    end

    function GiveRandomStatuses(target)
        -- Duración por defecto (en segundos) si no se pasa como parámetro o no existe globalmente
        local status_duration = math.random(6)
        local rndstatus = math.floor(GetLevelOfRandomness() / 2)

        for i = 1, rndstatus do
            local is_positive = true

            -- Determinar si el estado será positivo o negativo (1 = positivo, 2 = negativo)
            if tonumber(Vars["NegativeStatuses"]) == 1 then
                is_positive = (math.random(2) == 1)
            end

            -- Tirada del 1 al 3 (33% de probabilidad de aplicar el estado en esta iteración)
            if math.random(3) == 1 then
                if is_positive and #Statuses > 0 then
                    local stat_index = math.random(#Statuses)
                    local selected_status = Statuses[stat_index]

                    if isDebug == 1 then
                        print("Character: " .. tostring(target) .. " gained status " .. tostring(selected_status))
                    end

                    Osi.ApplyStatus(target, selected_status, status_duration)
                elseif not is_positive and #NegativeStatuses > 0 then
                    local stat_index = math.random(#NegativeStatuses)
                    local selected_status = NegativeStatuses[stat_index]

                    if isDebug == 1 then
                        print("Character: " .. tostring(target) .. " gained status " .. tostring(selected_status))
                    end

                    Osi.ApplyStatus(target, selected_status, status_duration)
                end
            end
        end
    end

    function GiveRandomStatBoosts(target)
        if (isDebug == 1) then
            print("Character: " .. target .. " gained random boosts")
        end
        if (math.random(4) == 1) then
            Osi.AddBoosts(target, "Ability(Strength,+" .. math.floor(GetLevelOfRandomness() / 3) .. ")", "1", "1")
        end
        if (math.random(4) == 1) then
            Osi.AddBoosts(target, "Ability(Dexterity,+" .. math.floor(GetLevelOfRandomness() / 3) .. ")", "1", "1")
        end
        if (math.random(4) == 1) then
            Osi.AddBoosts(target, "Ability(Constitution,+" .. math.floor(GetLevelOfRandomness() / 3) .. ")", "1", "1")
        end
        if (math.random(4) == 1) then
            Osi.AddBoosts(target, "Ability(Intelligence,+" .. math.floor(GetLevelOfRandomness() / 3) .. ")", "1", "1")
        end
        if (math.random(4) == 1) then
            Osi.AddBoosts(target, "Ability(Wisdom,+" .. math.floor(GetLevelOfRandomness() / 3) .. ")", "1", "1")
        end
        if (math.random(4) == 1) then
            Osi.AddBoosts(target, "Ability(Charisma,+" .. math.floor(GetLevelOfRandomness() / 3) .. ")", "1", "1")
        end
    end
    function GiveRandomACBoost(target)
        local randacboost =
            math.random(math.floor(GetLevelOfRandomness() / 3)) - math.random(math.floor(GetLevelOfRandomness() / 2))
        --print("randacboost: " .. randacboost)
        if (isDebug == 1) then
            print("Character: " .. target .. " gained AC: " .. randacboost)
        end
        Osi.AddBoosts(target, "AC(" .. randacboost .. ")", "1", "1")
    end
    function AddRandomPassive(target)
        local randpassive = math.random(#CR_Passives)
        if (isDebug == 1) then
            print("Character: " .. target .. " gained passive: " .. CR_Passives[randpassive])
        end
        Osi.AddPassive(target, CR_Passives[randpassive])
    end
    function DoEnemyMultiplication()
        if (isDebug == 1) then
            print("------------------CLONING FUNCTION STARTED.------------------")
            print("Number of NPCs to clone:" .. #CombatNPCS)
        end
        for i = #CombatNPCS, 1, -1 do
            if (tonumber(Vars["EnemyDuplicationChance"]) >= GetUpToHundred()) then
                local clone_x, clone_y, clone_z = Osi.GetPosition(CombatNPCS[i])
                if (tonumber(Vars["RandomDuplicationAmount"]) == 0) then
                    for k = tonumber(Vars["EnemyMultiplication"]), 1, -1 do
                        if
                            (tonumber(Vars["EnemyOnlyDuplication"]) == 1 and
                                Osi.IsEnemy(CombatNPCS[i], Osi.GetHostCharacter()) == 1)
                         then
                            if (isDebug == 1) then
                                print("creating a clone of: " .. CombatNPCS[i])
                            end
                            Osi.CreateAt(
                                Osi.GetTemplate(CombatNPCS[i]),
                                clone_x + math.random(5) - 4,
                                clone_y,
                                clone_z + math.random(5) - 4,
                                0,
                                0,
                                ""
                            )
                        end
                        if (tonumber(Vars["EnemyOnlyDuplication"]) == 0 and tonumber(Vars["AllyOnlyDuplication"]) == 0) then
                            if (isDebug == 1) then
                                print("creating a clone of: " .. CombatNPCS[i])
                            end
                            Osi.CreateAt(
                                Osi.GetTemplate(CombatNPCS[i]),
                                clone_x + math.random(5) - 4,
                                clone_y,
                                clone_z + math.random(5) - 4,
                                0,
                                0,
                                ""
                            )
                        end
                        if
                            (tonumber(Vars["AllyOnlyDuplication"]) == 1 and tonumber(Vars["EnemyOnlyDuplication"]) == 0 and
                                Osi.IsEnemy(CombatNPCS[i], Osi.GetHostCharacter()) == 0)
                         then
                            if (isDebug == 1) then
                                print("creating a clone of: " .. CombatNPCS[i])
                            end
                            Osi.CreateAt(
                                Osi.GetTemplate(CombatNPCS[i]),
                                clone_x + math.random(5) - 4,
                                clone_y,
                                clone_z + math.random(5) - 4,
                                0,
                                0,
                                ""
                            )
                        end
                    end
                end
                if (tonumber(Vars["RandomDuplicationAmount"]) == 1) then
                    local randomduplicationamount = math.floor(tonumber(Vars["EnemyMultiplication"]) or 0)
                    --print("random dupe amount " .. randomduplicationamount)
                    if (isDebug == 1) then
                        print("Random duplication amount: " .. randomduplicationamount)
                    end
                    local isEnemyOnly = tonumber(Vars["EnemyOnlyDuplication"]) == 1
                    local isEnemy = Osi.IsEnemy(CombatNPCS[i], Osi.GetHostCharacter()) == 1
                    local isDebug = isDebug == 1

                    -- Si no está limitado a enemigos O si está limitado pero el NPC ES un enemigo:
                    if not isEnemyOnly or isEnemy then
                        local template = Osi.GetTemplate(CombatNPCS[i])

                        for k = randomduplicationamount, 1, -1 do
                            if isDebug then
                                print("creating a clone of: " .. tostring(CombatNPCS[i]))
                            end

                            local offsetX = math.random(5) - 4
                            local offsetZ = math.random(5) - 5

                            Osi.CreateAt(template, clone_x + offsetX, clone_y, clone_z + offsetZ, 0, 0, "")
                        end
                    end
                end
            end
        end
    end

    function AddRandomEpithet(target)
        local old_name = Ext.Loca.GetTranslatedString(Osi.GetDisplayName(target))
        local new_name = old_name .. " " .. CombatRandomizer_Epithets[math.random(#CombatRandomizer_Epithets)]
        if (isDebug == 1) then
            print("Changing name of" .. target .. " to " .. new_name)
        end
        Osi.SetStoryDisplayName(target, new_name)
    end

    function MakeElite(target)
        local cr_elite_type = math.random(#CR_EliteTypes)
        local cr_elite = CR_EliteTypes[cr_elite_type]
        if (isDebug == 1) then
            print("Turning into " .. cr_elite .. " elite: " .. target)
        end
        --print("making elite:" .. target .. " with elite type:" .. cr_elite)
        local current_npc_name = Ext.Loca.GetTranslatedString(Osi.GetDisplayName(target))
        local new_npc_name = cr_elite .. " " .. current_npc_name
        Osi.SetStoryDisplayName(target, new_npc_name)
        --
        if (cr_elite == "Overloading") then --extra hp
            Osi.AddBoosts(target, "TemporaryHP(30)", "", "")
        else
            Osi.AddBoosts(target, "TemporaryHP(12)", "", "")
        end
        --
        if (cr_elite == "Overloading") then
            Osi.PROC_LoopEffect("eb7a79f8-8d1e-7c76-88ab-7ad33f49bacb", target, "", "__ANY__", "", 1)
            Osi.AddBoosts(target, "Resistance(Lightning,Immune)", "", "")
            Osi.AddBoosts(target, "Resistance(Thunder,Immune)", "", "")
        end
        if (cr_elite == "Blazing") then
            Osi.PROC_LoopEffect("45fee957-e719-a110-42b7-055a57448e93", target, "", "__ANY__", "", 1)
            Osi.AddBoosts(target, "Resistance(Fire,Immune)", "", "")
        end
        if (cr_elite == "Glacial") then
            Osi.PROC_LoopEffect("0265d413-7396-43ef-ba1a-4cef43894950", target, "", "__ANY__", "", 1)
            Osi.AddBoosts(target, "Resistance(Cold,Immune)", "", "")
            Osi.AddBoosts(target, "StatusImmunity(SG_Prone)", "", "")
        end
        if (cr_elite == "Malachite") then
            Osi.PROC_LoopEffect("04160bf1-681c-7909-f3a4-620a27aa926f", target, "", "__ANY__", "", 1)
            Osi.AddBoosts(target, "Resistance(Poison,Immune)", "", "")
        end

        if (cr_elite == "Frenzied") then
            Osi.PROC_LoopEffect("719ba6d7-cb58-e7d3-9606-e84bb129f17b", target, "", "__ANY__", "", 1)
            Osi.AddBoosts(target, "ReduceCriticalAttackThreshold(5)", "", "")
            Osi.AddBoosts(target, "ActionResourceConsumeMultiplier(Movement,0.5,0)", "", "")
            Osi.ApplyStatus(target, "UNSTOPPABLE", 15)
            Osi.ApplyStatus(target, "LEGENDARY_RESISTANCE", 15)
        end
        if (cr_elite == "Volatile") then
            Osi.PROC_LoopEffect("3adb1e74-983e-40cb-935d-8ad1abc3db92", target, "", "__ANY__", "", 1)
        end
        if (cr_elite == "Leeching") then
            Osi.PROC_LoopEffect("6fe1e247-43e2-c8b8-e09d-c9f0eb724a89", target, "", "__ANY__", "", 1)
        end
    end

    function CheckIfTemplateOfNPC(clone_template)
        for i = #CombatNPCS, 1, -1 do
            if (GetGUID(Osi.GetTemplate(CombatNPCS[i])) == clone_template) then
                return 1
            end
        end
        return 0
    end

    function GetCharacterFromTemplate(clone_template)
        for i = #CombatNPCS, 1, -1 do
            if (GetGUID(Osi.GetTemplate(CombatNPCS[i])) == clone_template) then
                if (isDebug == 1) then
                    print("Template of" .. CombatNPCS[i] .. " is " .. clone_template)
                end
                return CombatNPCS[i]
            end
        end
        return ""
    end

    function RaidBossEventStart(raidboss)
        local host = Osi.GetHostCharacter()
        local RAID_BOSS_CONFIGS = {
            ["CINE_S_WYR_AnsurGhost_dc2cbb9b-d6d6-438b-8fad-cb6fb1b2f87e"] = {
                name = "Muffin",
                hpMultiplier = 28,
                boosts = {"Resistance(Lightning,Immune)"},
                spells = {
                    "Projectile_Fireball_Dragon",
                    "Projectile_LightningBreath_Dragon_Skeletal",
                    "Projectile_SuperNova_Dragon_Skeletal"
                },
                templates = {
                    "4f313dde-14bb-43a2-abdd-07b2eb38b33a",
                    "df08ec01-52f0-4fdf-b5e7-4fa0970a480a"
                }
            },
            ["LOW_Slayer_Orin_ced6bfeb-8f6f-47d0-943f-77833f643318"] = {
                name = "ULTIMATE SLAYER",
                hpMultiplier = 23,
                boosts = {"ReduceCriticalAttackThreshold(5)"},
                hostBoosts = {"CriticalHitExtraDice(1,MeleeUnarmedAttack)"}
            },
            ["CrabFamiliar_Summon_48cda2b7-04bc-40c2-81f5-1dddabcd15ab"] = {
                name = "GIANT ENEMY CRAB",
                hpMultiplier = 50,
                boosts = {"ScaleMultiplier(4)"}
            },
            ["[WIP] Humans_Female_Strong_NightSong_9671ecbb-4030-48ff-b63e-f138e988835f"] = {
                name = "HELLKNIGHT AYLIN",
                hpMultiplier = 22,
                boosts = {"Resistance(Fire,Immune)"},
                templates = {"7219fca3-5f41-43a0-8253-f4c09d8b6308"}
            }
        }

        if isDebug == 1 then
            print("Raid boss chosen:" .. tostring(raidboss))
        end

        -- 1. Aplicar SURPRISED a los enemigos que no sean el Raid Boss
        local freezeTurns = (tonumber(Vars["FreezeTurns"]) or 0) * 5
        for i = #CombatNPCS, 1, -1 do
            local npc = CombatNPCS[i]
            if npc ~= raidboss and Osi.IsEnemy(npc, host) == 1 then
                Osi.ApplyStatus(npc, "SURPRISED", freezeTurns)
            end
        end

        -- 2. Estado del Raid Boss
        local enrageTime = (tonumber(Vars["RaidBossEnrageTurns"]) or 0) * 5
        Osi.ApplyStatus(raidboss, "CR_RAIDBOSS", enrageTime)
        CombatRandomizer_ChosenRaidBoss = raidboss

        local transformation = RaidBossesTable[math.random(#RaidBossesTable)]
        Osi.Transform(raidboss, transformation, transformVFX)

        local config = RAID_BOSS_CONFIGS[transformation]
        if config then
            if config.name then
                Osi.SetStoryDisplayName(raidboss, config.name)
            end

            Osi.ApplyStatus(raidboss, "LEGENDARY_RESISTANCE", -1)

            if config.hpMultiplier then
                local tempHp = Osi.GetLevel(host) * config.hpMultiplier
                Osi.AddBoosts(raidboss, "TemporaryHP(" .. tempHp .. ")", "", "")
            end

            for _, boost in ipairs(config.boosts or {}) do
                Osi.AddBoosts(raidboss, boost, "", "")
            end

            for _, hostBoost in ipairs(config.hostBoosts or {}) do
                Osi.AddBoosts(host, hostBoost, "", "")
            end

            for _, spell in ipairs(config.spells or {}) do
                Osi.AddSpell(raidboss, spell, 1)
            end

            -- Agregar Objetos / Templates
            for _, template in ipairs(config.templates or {}) do
                Osi.TemplateAddTo(template, raidboss, 1)
            end
        end
    end

    function GetRandomRaidBossSpell(RaidBossType)
        if (RaidBossType == "Slayer") then
            return "" -- slayer no getty the spelly, already makes itself unstoppable (no spell animation for unstoppable buff smh my head)
        end
        if (RaidBossType == "DameAylin") then
            RandomRaidSpell = math.random(#RaidBossSpellsTable_DameAylin)
            return RaidBossSpellsTable_DameAylin[RandomRaidSpell]
        end
        if (RaidBossType == "Muffin") then
            RandomRaidSpell = math.random(#RaidBossSpellsTable_MuffinDragon)
            return RaidBossSpellsTable_MuffinDragon[RandomRaidSpell]
        end
        if (RaidBossType == "MuffinNotDragon") then
            RandomRaidSpell = math.random(#RaidBossSpellsTable_Muffin)
            return RaidBossSpellsTable_Muffin[RandomRaidSpell]
        end

        return ""
    end

    function CR_UnequipAllWornItems(target)
        for i = #CR_EquipmentSlots, 1, -1 do
            if (Osi.GetEquippedItem(target, CR_EquipmentSlots[i]) ~= nil) then
                local item_to_unequip = Osi.GetEquippedItem(target, CR_EquipmentSlots[i])
                Osi.LockUnequip(item_to_unequip, 0)
                Osi.Unequip(target, item_to_unequip)
            end
        end
    end

    function DoRaidBossBehavior(raid_boss)
        --find appropriate target
        RaidBossTarget = ""
        for i = #Party, 1, -1 do
            if (Osi.CanSee(raid_boss, Party[i]) == 1) then
                RaidBossTarget = Party[i]
                break
            end
        end
        if (RandomRaidBossTransformation == "LOW_Slayer_Orin_ced6bfeb-8f6f-47d0-943f-77833f643318") then --slayer, no special spells but they do be unstoppable
            Osi.ApplyStatus(raid_boss, "UNSTOPPABLE", 25)
        end
        if (RandomRaidBossTransformation == "CrabFamiliar_Summon_48cda2b7-04bc-40c2-81f5-1dddabcd15ab") then --tanky crabby
            if (math.random(5) == 1) then
                Osi.UseSpell(raid_boss, "Target_FindFamiliar_Crab", RaidBossTarget)
            end
        end
        if (RandomRaidBossTransformation == "[WIP] Humans_Female_Strong_NightSong_9671ecbb-4030-48ff-b63e-f138e988835f") then
            if (math.random(6) ~= 1) then
                Osi.UseSpell(CombatRandomizer_ChosenRaidBoss, GetRandomRaidBossSpell("DameAylin"), RaidBossTarget)
            end
        end
        if (RandomRaidBossTransformation == "CINE_S_WYR_AnsurGhost_dc2cbb9b-d6d6-438b-8fad-cb6fb1b2f87e") then
            GainedSpell = GetRandomRaidBossSpell("Muffin")
            GainedSpell2 = GetRandomRaidBossSpell("MuffinNotDragon")
            if (math.random(4) ~= 1) then --75% chance
                Osi.AddSpell(CombatRandomizer_ChosenRaidBoss, GainedSpell, 1)
                Osi.AddSpell(CombatRandomizer_ChosenRaidBoss, GainedSpell2, 1)
                if (GainedSpell == "Projectile_SuperNova_Dragon_Skeletal") then
                    --Transform(CombatRandomizer_ChosenRaidBoss,"08da5063-a761-475a-b66e-1356d7fcab40","ceccc4eb-d774-4cd5-9147-12322b81b763")
                    Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "DRAGON_SKELETAL_FLIGHTSTATE", 5)
                    Osi.UseSpell(
                        CombatRandomizer_ChosenRaidBoss,
                        "Projectile_SuperNova_Dragon_Skeletal",
                        RaidBossTarget
                    )
                    Osi.TimerLaunch("DoDragonSupernova", 2000)
                else
                    Osi.UseSpell(
                        CombatRandomizer_ChosenRaidBoss,
                        "Projectile_SuperNova_Dragon_Skeletal",
                        RaidBossTarget
                    )
                end
            elseif (math.random(5) ~= 1) then
                Osi.UseSpell(CombatRandomizer_ChosenRaidBoss, GainedSpell2, RaidBossTarget)
            end
        end
    end

    Ext.Osiris.RegisterListener(
        "EnteredCombat",
        2,
        "after",
        function(guid, combatid) -- where the magic happens
            if IsExcludedOrParty(guid) then
                return
            end

            Current_combat = combatid

            for k, d in ipairs(Osi.DB_PartyMembers:Get(nil)) do
                table.insert(Party, d[1])
            end --sets up party table (to not target them for randomization)

            if (CR_WhoopsAllBosses == 0) then
                if (tonumber(Vars["WhoopsAllBosses"]) >= GetUpToHundred()) then
                    CR_WhoopsAllBosses = 2
                else
                    CR_WhoopsAllBosses = 1
                end
            end

            if (tonumber(Vars["EnemiesOnly"]) == 1) then
                if
                    (Osi.IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and
                        Osi.IsEnemy(guid, Osi.GetHostCharacter()) == 1 and
                        Osi.HasAppliedStatus(guid, "CR_RANDOMIZED") == 0 and
                        CheckIfOrigin(guid) == 0)
                 then
                    table.insert(CombatNPCS, guid)
                    Osi.AddBoosts(guid, "Proficiency(MartialWeapons)", "", "") -- enemies without proficiency kinda suck ass
                    Osi.AddBoosts(guid, "Proficiency(SimpleWeapons)", "", "")
                    Osi.AddBoosts(guid, "Proficiency(HeavyArmor)", "", "")
                    Osi.AddBoosts(guid, "Proficiency(LightArmor)", "", "")
                    Osi.AddBoosts(guid, "Proficiency(MediumArmor)", "", "")
                    Osi.AddBoosts(guid, "ActionResource(SpellSlot,3,5)", "Randomizer", "Randomizer") --sneaky spell slot addition to make enemies be able to cast more shit, le difficulty
                    if (Osi.IsEnemy(guid, Osi.GetHostCharacter()) == 1) then
                        Osi.RequestSetSwarmGroup(guid, "") --gets rid of enemy swarms entirely cause it breaks smart AI
                    end
                    Osi.SetTag(guid, "BLOCK_RESURRECTION")
                    if (isDebug == 1) then
                        print("Entered combat (enemy)(not party): " .. guid)
                    end
                    if (tonumber(Vars["Passives"]) >= GetUpToHundred()) then
                        AddRandomPassive(guid)
                    end
                    if (tonumber(Vars["Transformations"]) >= GetUpToHundred()) then
                        if
                            (tonumber(Vars["ActualTransformations"]) == 0 and
                                Osi.HasAppliedStatus(guid, "CR_TRANSFORMED") == 0)
                        then
                            if (isDebug == 1) then
                                print("Transforming(disguise): " .. guid)
                            end
                            --Transform(guid,GetGUID(GetRandomTransform()),"c7c3381e-b901-416e-a0c4-bc745e1ff54a")
                            Osi.Transform(guid, GetRandomTransform(), "c7c3381e-b901-416e-a0c4-bc745e1ff54a") --disguise transformation
                            Osi.ApplyStatus(guid, "CR_TRANSFORMED", -1)
                        end
                        if(tonumber(Vars["ActualTransformations"]) == 1 and
                                Osi.HasAppliedStatus(guid, "CR_TRANSFORMED") == 0)
                        then
                            if (isDebug == 1) then
                                print("Transforming(actual transform): " .. guid)
                            end
                            -- Transform(guid,GetGUID(GetRandomTransform()),GetRandomTransformRule())
                            Osi.Transform(guid, GetRandomTransform(), transformVFX)
                            Osi.ApplyStatus(guid, "CR_TRANSFORMED", -1)
                        end
                    end
                    if (tonumber(Vars["HealthBoosts"]) >= GetUpToHundred()) then
                        Osi.AddBoosts(guid, GetRandomHPIncrease(guid), "1", "1")
                    end
                    if (tonumber(Vars["ChangeSize"]) >= GetUpToHundred()) then
                        SetRandomScale(guid)
                    end
                    if (tonumber(Vars["ResourceBoosts"]) >= GetUpToHundred()) then
                        GiveRandomActionsAndBonus(guid)
                    end
                    if (tonumber(Vars["NpcSpells"]) >= GetUpToHundred()) then
                        GiveRandomSpells(guid)
                    end
                    if (tonumber(Vars["NpcEquipment"]) >= GetUpToHundred()) then
                        GiveRandomEquipment(guid)
                    end
                    if (tonumber(Vars["Consumables"]) >= GetUpToHundred()) then
                        GiveRandomConsumables(guid)
                    end
                    if (tonumber(Vars["Statuses"]) >= GetUpToHundred()) then
                        GiveRandomStatuses(guid)
                    end
                    if (tonumber(Vars["StatBoosts"]) >= GetUpToHundred()) then
                        GiveRandomStatBoosts(guid)
                    end
                    if (tonumber(Vars["ACBoosts"]) >= GetUpToHundred()) then
                        GiveRandomACBoost(guid)
                    end
                    if (tonumber(Vars["Elites"]) >= GetUpToHundred()) then
                        MakeElite(guid)
                    end
                    Osi.ApplyStatus(guid, "CR_RANDOMIZED", -1)
                end
            end
            if (tonumber(Vars["EnemiesOnly"]) == 0) then
                if
                    (Osi.IsCharacter(guid) == 1 and CheckIfParty(guid) == 0 and
                        Osi.HasAppliedStatus(guid, "CR_RANDOMIZED") == 0 and
                        CheckIfOrigin(guid) == 0)
                 then
                    Osi.SetTag(guid, "BLOCK_RESURRECTION")
                    Osi.AddBoosts(guid, "Proficiency(MartialWeapons)", "", "") -- enemies without proficiency kinda suck ass
                    Osi.AddBoosts(guid, "Proficiency(SimpleWeapons)", "", "")
                    Osi.AddBoosts(guid, "Proficiency(HeavyArmor)", "", "")
                    Osi.AddBoosts(guid, "Proficiency(LightArmor)", "", "")
                    Osi.AddBoosts(guid, "Proficiency(MediumArmor)", "", "")
                    Osi.AddBoosts(guid, "ActionResource(SpellSlot,3,5)", "Randomizer", "Randomizer") --sneaky spell slot addition to make enemies be able to cast more shit, le difficulty
                    if (Osi.IsEnemy(guid, Osi.GetHostCharacter()) == 1) then
                        Osi.RequestSetSwarmGroup(guid, "")
                    end
                    if (Osi.IsEnemy(guid, Osi.GetHostCharacter()) == 0) then
                        Osi.RequestSetSwarmGroup(guid, "")
                    end
                    table.insert(CombatNPCS, guid)
                    if (isDebug == 1) then
                        print("Entered combat(not party): " .. guid)
                    end
                    if (tonumber(Vars["Passives"]) >= GetUpToHundred()) then
                        AddRandomPassive(guid)
                    end
                    if (tonumber(Vars["Transformations"]) >= GetUpToHundred()) then
                        if
                            (tonumber(Vars["ActualTransformations"]) == 0 and
                                Osi.HasAppliedStatus(guid, "CR_TRANSFORMED") == 0)
                         then
                            -- print("stock transform")
                            if (isDebug == 1) then
                                print("Transformed(disguise): " .. guid)
                            end
                            Osi.Transform(guid, GetRandomTransform(), "c7c3381e-b901-416e-a0c4-bc745e1ff54a")
                            Osi.ApplyStatus(guid, "CR_TRANSFORMED", -1)
                        end
                        if
                            (tonumber(Vars["ActualTransformations"]) == 1 and
                                Osi.HasAppliedStatus(guid, "CR_TRANSFORMED") == 0)
                         then
                            --print("actual transform")
                            if (isDebug == 1) then
                                print("Transformed(actual transform): " .. guid)
                            end
                            Osi.Transform(guid, GetRandomTransform(), transformVFX)
                            Osi.ApplyStatus(guid, "CR_TRANSFORMED", -1)
                        end
                    end
                    if (tonumber(Vars["HealthBoosts"]) >= GetUpToHundred()) then
                        Osi.AddBoosts(guid, GetRandomHPIncrease(guid), "1", "1")
                    end
                    if (tonumber(Vars["ChangeSize"]) >= GetUpToHundred()) then
                        SetRandomScale(guid)
                    end
                    if (tonumber(Vars["ResourceBoosts"]) >= GetUpToHundred()) then
                        GiveRandomActionsAndBonus(guid)
                    end
                    if (tonumber(Vars["NpcSpells"]) >= GetUpToHundred()) then
                        GiveRandomSpells(guid)
                    end
                    if (tonumber(Vars["NpcEquipment"]) >= GetUpToHundred()) then
                        GiveRandomEquipment(guid)
                    end
                    if (tonumber(Vars["Consumables"]) >= GetUpToHundred()) then
                        GiveRandomConsumables(guid)
                    end
                    if (tonumber(Vars["Statuses"]) >= GetUpToHundred()) then
                        GiveRandomStatuses(guid)
                    end
                    if (tonumber(Vars["StatBoosts"]) >= GetUpToHundred()) then
                        GiveRandomStatBoosts(guid)
                    end
                    if (tonumber(Vars["ACBoosts"]) >= GetUpToHundred()) then
                        GiveRandomACBoost(guid)
                    end
                    if (tonumber(Vars["Elites"]) >= GetUpToHundred()) then
                        MakeElite(guid)
                    end
                    Osi.ApplyStatus(guid, "CR_RANDOMIZED", -1)
                end
            end
        end
    )

    Ext.Osiris.RegisterListener(
        "PingRequested",
        1,
        "after",
        function(_)
            print("Combat Randomizer - applying current config.")
            GetStuffFromFile()
        end
    )

    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(characterGUID, statusID, causeeGUID, storyActionID)
        if statusID == "DOWNED" then
            if (isDebug == 1) then
                print("El personaje ha caído tumbado (DOWNED): " .. tostring(characterGUID))
            end
            
            RevertPartyMember(characterGUID)
        end
    end)
    
    Ext.Osiris.RegisterListener("CharacterDied", 1, "after", function(characterGUID)
        if (isDebug == 1) then
            print("El personaje ha MUERTO: " .. tostring(characterGUID))
        end
        
        RevertPartyMember(characterGUID)
    end)

    Ext.Osiris.RegisterListener(
        "TurnStarted",
        1,
        "after",
        function(turnstarted)
            if CR_PartyTransformTurns and CR_PartyTransformTurns[turnstarted] then
                CR_PartyTransformTurns[turnstarted] = CR_PartyTransformTurns[turnstarted] - 1

                if (isDebug == 1) then
                    print(
                        "Turnos restantes de transformación para " ..
                            tostring(turnstarted) .. ": " .. tostring(CR_PartyTransformTurns[turnstarted])
                    )
                end

                if CR_PartyTransformTurns[turnstarted] <= 0 then
                    RevertPartyMember(turnstarted)
                end
            end

            Osi.RequestSetSwarmGroup(turnstarted, "")
            Osi.SetStayInAiHints(turnstarted, 1)
            if
                (turnstarted == CombatRandomizer_ChosenRaidBoss and
                    Osi.HasActiveStatus(CombatRandomizer_ChosenRaidBoss, "CR_RAIDBOSS_ENRAGED") == 1)
             then
                DoRaidBossBehavior(CombatRandomizer_ChosenRaidBoss)
            end
            if (turnstarted == CombatRandomizer_ChosenRaidBoss) then
                if
                    (Osi.HasActiveStatus(CombatRandomizer_ChosenRaidBoss, "CR_RAIDBOSS") == 1 and
                        RandomRaidBossTransformation ==
                            "[WIP] Humans_Female_Strong_NightSong_9671ecbb-4030-48ff-b63e-f138e988835f")
                 then
                    Osi.ApplyStatus(Osi.GetEquippedWeapon(CombatRandomizer_ChosenRaidBoss), "DIPPED_FIRE", -1)
                end
                if
                    (Osi.HasActiveStatus(CombatRandomizer_ChosenRaidBoss, "CR_RAIDBOSS") == 0 and
                        Osi.HasActiveStatus(CombatRandomizer_ChosenRaidBoss, "CR_RAIDBOSS_ENRAGED") == 0)
                 then
                    --print("IS ENRAGED")
                    Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "CR_RAIDBOSS_ENRAGED", -1)
                    Osi.AddBoosts(CombatRandomizer_ChosenRaidBoss, "TemporaryHP(70)", "", "")
                    Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "LIGHT_FLAME_BLADE", -1)
                    if (RandomRaidBossTransformation == "LOW_Slayer_Orin_ced6bfeb-8f6f-47d0-943f-77833f643318") then
                        Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "VOID_AURA", -1)
                        Osi.AddBoosts(CombatRandomizer_ChosenRaidBoss, "ActionResource(ActionPoint,2,0)", "", "")
                        Osi.AddBoosts(
                            CombatRandomizer_ChosenRaidBoss,
                            "ActionResourceConsumeMultiplier(Movement,0,0)",
                            "",
                            ""
                        )
                    end
                    if (RandomRaidBossTransformation == "CrabFamiliar_Summon_48cda2b7-04bc-40c2-81f5-1dddabcd15ab") then
                        Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "SLEET_STORM", -1)
                        Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "FIRE_SHIELD_CHILL", -1)
                        Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "BLESS", -1)
                        Osi.ApplyStatus(CombatRandomizer_ChosenRaidBoss, "REFLECTIVE_SHELL", -1)
                        Osi.AddBoosts(
                            CombatRandomizer_ChosenRaidBoss,
                            "ActionResourceConsumeMultiplier(Movement,0,0)",
                            "",
                            ""
                        )
                    end
                    if
                        (RandomRaidBossTransformation ==
                            "[WIP] Humans_Female_Strong_NightSong_9671ecbb-4030-48ff-b63e-f138e988835f")
                     then
                        Osi.AddPassive(CombatRandomizer_ChosenRaidBoss, "Parry_Githyanki")
                        Osi.AddPassive(CombatRandomizer_ChosenRaidBoss, "Smite_Divine_2")
                        Osi.AddBoosts(CombatRandomizer_ChosenRaidBoss, "ActionResource(ActionPoint,1,0)", "", "")
                        Osi.AddBoosts(
                            CombatRandomizer_ChosenRaidBoss,
                            "ActionResourceConsumeMultiplier(Movement,0,0)",
                            "",
                            ""
                        )
                        Osi.UseSpell(
                            CombatRandomizer_ChosenRaidBoss,
                            "CR_RaidBossRage",
                            CombatRandomizer_ChosenRaidBoss
                        )
                    end
                    if (RandomRaidBossTransformation == "CINE_S_WYR_AnsurGhost_dc2cbb9b-d6d6-438b-8fad-cb6fb1b2f87e") then
                        Osi.AddBoosts(CombatRandomizer_ChosenRaidBoss, "ActionResource(ActionPoint,1,0)", "", "")
                        Osi.AddBoosts(
                            CombatRandomizer_ChosenRaidBoss,
                            "ActionResourceConsumeMultiplier(Movement,0,0)",
                            "",
                            ""
                        )
                    end
                end
            end
            if (string.find(Ext.Loca.GetTranslatedString(Osi.GetDisplayName(turnstarted)), "Glacial") ~= nil) then
                if (math.random(3) == 1) then
                    Osi.ApplyStatus(turnstarted, "SLEET_STORM", 1)
                end
            end
            if (Ext.Loca.GetTranslatedString(Osi.GetDisplayName(turnstarted)) == "Nautiloid Cannon") then
                NautiloidCannonTarget = ""
                for i = #Party, 1, -1 do
                    if (Osi.CanSee(turnstarted, Party[i]) == 1) then
                        NautiloidCannonTarget = Party[i]
                        break
                    end
                end
                if (NautiloidCannonTarget ~= "") then
                    Osi.UseSpell(
                        turnstarted,
                        "ProjectileStrike_END_HighHallInterior_NautiloidStrike",
                        NautiloidCannonTarget
                    )
                end
            end
        end
    )

    function GetRandomPartySpell()
        return SpellsTable[math.random(#SpellsTable)]
    end

    local function CleanUseCosts(spell)
        if not spell or not spell.UseCosts or spell.UseCosts == "" then return end
    
        local newCosts = {}
        for cost in string.gmatch(spell.UseCosts, "[^;]+") do
            if string.find(cost, "ActionPoint") or string.find(cost, "BonusActionPoint") or string.find(cost, "ReactionActionPoint") then
                table.insert(newCosts, cost)
            end
        end
    
        spell.UseCosts = table.concat(newCosts, ";")
    end

    local function ProcessSpellAndContainers(spellName)
        local spell = Ext.Stats.Get(spellName)
        if not spell then return end
    
        CleanUseCosts(spell)
    
        if spell.ContainerSpells and spell.ContainerSpells ~= "" then
            for childSpellName in string.gmatch(spell.ContainerSpells, "[^;]+") do
                local childSpell = Ext.Stats.Get(childSpellName)
                if childSpell then
                    CleanUseCosts(childSpell)
                end
            end
        end
    end

    Ext.Events.StatsLoaded:Subscribe(function() -- TODO resume (NO FUNCIONA)
        for _, spellName in ipairs(SpellsTable) do
            ProcessSpellAndContainers(spellName)
        end
    end)


    function AddRandomSpellToParty()
        for i = 4, 1, -1 do
            if (Party[i] ~= nil and tonumber(Vars["GiveRandomSpellToParty"]) >= GetUpToHundred()) then
                local spelltoadd = GetRandomPartySpell()
                Osi.AddSpell(Party[i], spelltoadd, 1)
                if (isDebug == 1) then
                    print("Adding random spell to " .. Party[i] .. " " .. spelltoadd)
                end
                table.insert(CR_SpellsAddedToParty, spelltoadd)
            end
        end
    end

    function RemoveRandomSpellFromParty()
        if (isDebug == 1) then
            print("Removing added spells from party")
        end
        for i = #Party, 1, -1 do
            for j = #CR_SpellsAddedToParty, 1, -1 do
                Osi.RemoveSpell(Party[i], CR_SpellsAddedToParty[j])
            end
        end
    end

    Ext.Osiris.RegisterListener(
        "TimerFinished",
        1,
        "after",
        function(event)
            if (event == "BugfixSummons") then
                CR_ActuallyClones = {}
                for i = 1, #CombatRandomizer_ClonedNPCS, 1 do
                    if (Osi.IsEnemy(CombatRandomizer_ClonedNPCS[i], Osi.GetHostCharacter()) == 1) then
                        table.insert(CR_ActuallyClones, CombatRandomizer_ClonedNPCS[i])
                    end
                end
                CombatRandomizer_ClonedNPCS = CR_ActuallyClones
                Osi.TimerLaunch("BugfixSummons", 500)
            end

            if (event == "AreThingsSupposedToBeSurprised") then
                local ohgodohfuck = 0
                for k, d in ipairs(Osi.DB_Is_InCombat:Get(nil, nil)) do
                    if
                        (Osi.IsEnemy(d[1], Osi.GetHostCharacter()) == 1 and Osi.HasAppliedStatus(d[1], "SURPRISED") == 1 and
                            Osi.HasActiveStatus(d[1], "SURPRISED") == 1)
                     then
                        ohgodohfuck = 1
                        break
                    end
                end
                if (ohgodohfuck == 1) then
                    for k, d in ipairs(Osi.DB_Is_InCombat:Get(nil, nil)) do
                        if
                            (Osi.IsEnemy(d[1], Osi.GetHostCharacter()) == 1 and
                                Osi.HasAppliedStatus(d[1], "SURPRISED") == 0 and
                                Osi.HasActiveStatus(d[1], "SURPRISED") == 0)
                         then
                            Osi.ApplyStatus(d[1], "SURPRISED", 5)
                        end
                    end
                end
            end

            if (event == "ReadRandomizerConfig" and tonumber(Vars["AutomaticallyReadConfig"]) == 1) then
                GetStuffFromFile()
                Osi.TimerLaunch("ReadRandomizerConfig", 3000)
            end

            if (event == "NexusCommentsRemover" and tonumber(Vars["ReadingAbilityUnlocked"]) == 0) then
                Osi.OpenMessageBox(
                    Osi.GetHostCharacter(),
                    "Combat Randomizer - This message will reappear until you've read the nexus page and disabled it in config. This is done because people do not read it."
                )
                if (CR_NexusCommenterMessageTimer > 2000) then
                    CR_NexusCommenterMessageTimer = CR_NexusCommenterMessageTimer - 500
                end
                Osi.TimerLaunch("NexusCommentsRemover", CR_NexusCommenterMessageTimer)
            end
            if (event == "TransformAllUntransformed") then
                if (tonumber(Vars["TransformAllNpcs"]) == 1) then
                    --print("random transform all")
                    RandomTransformAllNpcs()
                end
                Osi.TimerLaunch("TransformAllUntransformed", 1500)
            end
            if (event == "BugFixUnequip") then
                OtherPartyTable = {}
                for k, d in ipairs(Osi.DB_PartyMembers:Get(nil)) do
                    table.insert(OtherPartyTable, d[1])
                end

                for i = #OtherPartyTable, 1, -1 do
                    for j = #CR_EquipmentSlots, 1, -1 do
                        if (Osi.GetEquippedItem(OtherPartyTable[i], CR_EquipmentSlots[j]) ~= nil) then
                            Osi.LockUnequip(Osi.GetEquippedItem(OtherPartyTable[i], CR_EquipmentSlots[j]), 0)
                        end
                    end
                end
                Osi.TimerLaunch("BugFixUnequip", 1000)
            end
            if (event == "ClearRandomizerTables" and Osi.IsInCombat(Osi.GetHostCharacter()) == 0) then
                --print("cleaning up tables")
                if (isDebug == 1) then
                    print("Cleaning up randomizer tables")
                end
                CombatRandomizer_ClonedNPCS = {}
                AddedItems = {}
                AddedConsumables = {}
                StupidFuckingBuggedAddedItems = {}
                CombatNPCS = {}
                CR_SpellsAddedToParty = {}
                Party = {}
                CR_TransformedPartyMembers = {}
                CR_CurrentTransformTable = {}
                CR_WhoopsAllBosses = 0
            end
            if (event == "RaidBossTimer") then
                if (tonumber(Vars["RaidBosses"]) >= GetUpToHundred()) then
                    while (true) do
                        WhoWillWinTheRaidBossLottery_number = math.random(#CombatNPCS)
                        WhoWillWinTheRaidBossLottery = CombatNPCS[WhoWillWinTheRaidBossLottery_number]
                        --print("Checking " .. WhoWillWinTheRaidBossLottery .. " for raid boss availability.")
                        if (Osi.IsBoss(WhoWillWinTheRaidBossLottery) == 1) then
                            NoRaidBoss = 1
                            break
                        end
                        if (Osi.IsEnemy(WhoWillWinTheRaidBossLottery, Osi.GetHostCharacter()) == 1) then
                            NoRaidBoss = 0
                            --print("WON THE LOTTERY:" .. WhoWillWinTheRaidBossLottery)
                            break
                        end
                    end
                    if (NoRaidBoss == 0) then
                        RaidBossEventStart(WhoWillWinTheRaidBossLottery)
                    end
                end
            end
            if (event == "DoBlazingEliteTrails") then
                -- print("blaze timer running")
                for k, d in ipairs(Osi.DB_Is_InCombat:Get(nil, nil)) do
                    if (string.find(Ext.Loca.GetTranslatedString(Osi.GetDisplayName(d[1])), "Blazing") ~= nil) then
                        --print("its le blazing: " .. d[1])
                        Osi.CreateSurface(d[1], "SurfaceHellfire", 1, 5)
                    end
                end
                Osi.TimerLaunch("DoBlazingEliteTrails", 300)
            end

            if (event == "ResetToDragonborn") then
                Osi.Transform(
                    CombatRandomizer_ChosenRaidBoss,
                    "CINE_S_WYR_AnsurGhost_dc2cbb9b-d6d6-438b-8fad-cb6fb1b2f87e",
                    "d47da5e8-e8d0-4e00-9578-35f8b1da8693"
                )
                Osi.TemplateAddTo("4f313dde-14bb-43a2-abdd-07b2eb38b33a", CombatRandomizer_ChosenRaidBoss, 1)
                Osi.TemplateAddTo("df08ec01-52f0-4fdf-b5e7-4fa0970a480a", CombatRandomizer_ChosenRaidBoss, 1)
            end
            if (event == "DoDragonSpell") then
                -- print("using spell:" .. CombatRandomizer_ChosenRaidBoss .. GainedSpell .. RaidBossTarget)
                Osi.UseSpell(CombatRandomizer_ChosenRaidBoss, GainedSpell, RaidBossTarget)
            end
            if (event == "DoDragonSupernova") then
                --print("using supernova spell:" .. CombatRandomizer_ChosenRaidBoss .. GainedSpell .. RaidBossTarget)
                Osi.UseSpell(CombatRandomizer_ChosenRaidBoss, "Projectile_SuperNova_Dragon_Skeletal", RaidBossTarget)
            end
        end
    )
    Ext.Osiris.RegisterListener(
        "TemplateAddedTo",
        4,
        "after",
        function(wpn_root, wpn_id, character, useless)
            if
                (StupidFuckingBuggedAddedItems[character] == nil and Osi.IsPartyMember(character, 1) == 0 and
                    Osi.IsInCombat(character) == 1 and
                    tonumber(Vars["NpcEquipment"]) > 0 and
                    CheckIfParty(character) == 0 and
                    CheckIfOrigin(character) == 0)
             then --shortest if ever
                StupidFuckingBuggedAddedItems[character] = {}
            end
            if
                (Osi.IsPartyMember(character, 1) == 0 and Osi.IsInCombat(character) == 1 and
                    tonumber(Vars["NpcEquipment"]) > 0 and
                    CheckIfParty(character) == 0 and
                    CheckIfOrigin(character) == 0)
             then
                table.insert(StupidFuckingBuggedAddedItems[character], wpn_id)
                if (Osi.IsEquipable(wpn_id) == 1) then
                    Osi.Equip(character, wpn_id)
                end
            --ApplyStatus(wpn_id,"CR_RANDOMIZED",-1)
            end
            if
                (Osi.HasAppliedStatus(character, "CR_RAIDBOSS") == 1 and Osi.IsPartyMember(character, 1) == 0 and
                    CheckIfParty(character) == 0 and
                    CheckIfOrigin(character) == 0)
             then --another stupid ass bugfix that is probably not necessary anymore. whatever man just shoot me in the head tbh
                Osi.Equip(character, wpn_id)
            end
        end
    )
    Ext.Osiris.RegisterListener(
        "CombatStarted",
        1,
        "after",
        function(combat_id)
            Osi.TimerLaunch("AreThingsSupposedToBeSurprised", 3000)
            if (isDebug == 1) then
                print("-------COMBAT STARTED-------")
            end
            for i = #CombatNPCS, 1, -1 do
                --print ("DOING NPC AI CHECKS")
                Osi.SetAiHint(CombatNPCS[i], "45a231e4-e94f-4b0e-a941-2daf1adf44b5")
                Osi.RequestSetBaseArchetype(CombatNPCS[i], "mage")
                Osi.SetStayInAiHints(CombatNPCS[i], 1)
            end
            if (tonumber(Vars["GiveRandomSpellToParty"]) > 0) then
                AddRandomSpellToParty()
            end
            if (tonumber(Vars["EnemyMultiplication"]) > 0) then
                DoEnemyMultiplication()
            end

            for i, v in ipairs(Osi.DB_PartyMembers:Get(nil)) do
                if (tonumber(Vars["TransformPartyMembers"]) >= GetUpToHundred()) then
                    table.insert(CR_TransformedPartyMembers, v[1])

                    TransformPartyMemberChaos(v[1], 5)
                end
            end
            for i = #CombatNPCS, 1, -1 do
                if (tonumber(Vars["LevelUps"]) >= GetUpToHundred()) then
                    local randlevel = math.random(Osi.GetLevel(Osi.GetHostCharacter()) * 2)
                    ActuallySetRandomLevel(CombatNPCS[i], randlevel)
                end
                if (tonumber(Vars["NameChanges"]) >= GetUpToHundred()) then
                    AddRandomEpithet(CombatNPCS[i])
                end
            end
            if (tonumber(Vars["RaidBosses"]) > 0 and CombatRandomizer_ChosenRaidBoss == "") then
                Osi.TimerLaunch("RaidBossTimer", 300)
            end
        end
    )

    CR_TransformedMembers = CR_TransformedMembers or {}
    CR_PartyTransformTurns = CR_PartyTransformTurns or {}

    function RevertPartyMember(characterGUID)
        if CR_TransformedMembers[characterGUID] then
            CR_TransformedMembers[characterGUID] = nil
            CR_PartyTransformTurns[characterGUID] = nil
    
            Osi.RemoveStatus(characterGUID, "MAG_ARCANE_TRICKERY")
            Osi.RemoveTransforms(characterGUID)
    
            local isDead = (Osi.IsDead(characterGUID) == 1)
            local isDowned = (Osi.HasActiveStatus(characterGUID, "DOWNED") == 1)
    
            local maxHP = Osi.GetMaxHitpoints(characterGUID) or 100
            local halfHP = math.floor(maxHP / 2)
    
            if isDead then
                Osi.Resurrect(characterGUID)
                Osi.SetHitpoints(characterGUID, halfHP)
    
                if (isDebug == 1) then
                    print("Personaje RESUCITADO de la transformación con 50% HP: " .. tostring(halfHP))
                end
    
            elseif isDowned then
                Osi.RemoveStatus(characterGUID, "DOWNED")
                Osi.SetHitpoints(characterGUID, halfHP)
    
                if (isDebug == 1) then
                    print("Personaje LEVANTADO del estado Tumbado con 50% HP: " .. tostring(halfHP))
                end
            end
        end
    end

    function TransformPartyMemberChaos(characterGUID, durationTurns)
        local randomTemplate = GetRandomTransform()

        CR_TransformedMembers[characterGUID] = true
        CR_PartyTransformTurns[characterGUID] = durationTurns or 3

        Osi.Transform(characterGUID, randomTemplate, transformVFXparty)
        Osi.ApplyStatus(characterGUID, "MAG_ARCANE_TRICKERY", (durationTurns or 3) * 6.0, 1)

        if (isDebug == 1) then
            print(
                "Personaje " .. tostring(characterGUID) .. " transformado por " .. tostring(durationTurns) .. " turnos."
            )
        end
    end

    Ext.Osiris.RegisterListener(
        "Dying",
        1,
        "after",
        function(characterGUID)
            if CR_TransformedMembers and CR_TransformedMembers[characterGUID] then
                RevertPartyMember(characterGUID)
            end
        end
    )

    Ext.Osiris.RegisterListener(
        "StatusRemoved",
        4,
        "after",
        function(characterGUID, statusID, causee, storyActionID)
            if statusID == "MAG_ARCANE_TRICKERY" and CR_TransformedMembers[characterGUID] then
                RevertPartyMember(characterGUID)
            end
        end
    )

    local RAID_BOSS_EFFECTS = {
        ["LOW_Slayer_Orin_ced6bfeb-8f6f-47d0-943f-77833f643318"] = function(target)
            Osi.ApplyStatus(target, "BLACKPOWDER_DETONATION", 20)
            Osi.ApplyStatus(target, "GAPING_WOUND", 10)
            Osi.ApplyStatus(target, "BLEEDING", 10)
            Osi.ApplyStatus(target, "CRIPPLED", 10)
        end,
        ["CrabFamiliar_Summon_48cda2b7-04bc-40c2-81f5-1dddabcd15ab"] = function(target)
            Osi.ApplyStatus(target, "HINDERED", 10)
            Osi.ApplyStatus(target, "CRAB_PINCHED", 50)
            Osi.ApplyStatus(target, "OFF_BALANCED", 10)
            Osi.ApplyStatus(target, "DAZED", 10)
        end,
        ["[WIP] Humans_Female_Strong_NightSong_9671ecbb-4030-48ff-b63e-f138e988835f"] = function(target)
            Osi.ApplyStatus(target, "SEARING_SMITE", 10)
            Osi.ApplyStatus(target, "BURNING", 10)
            Osi.ApplyStatus(target, "FAERIE_FIRE", 10)
        end,
        ["CINE_S_WYR_AnsurGhost_dc2cbb9b-d6d6-438b-8fad-cb6fb1b2f87e"] = function(target)
            Osi.ApplyStatus(target, "SHOCKED", 10)
            Osi.ApplyStatus(target, "STATIC_DISCHARGE", 5)
            Osi.CreateProjectileStrikeAt(target, "Projectile_ChromaticOrb_Lightning")
        end
    }

    local function ApplySafeDamage(target, totalDamage, damageType)
        local MAX_SINGLE_DAMAGE = 46340
        local remaining = totalDamage
        while remaining > 0 do
            local chunk = math.min(remaining, MAX_SINGLE_DAMAGE)
            Osi.ApplyDamage(target, chunk, damageType)
            remaining = remaining - chunk
        end
    end

    local function GetEntityDisplayName(entity)
        if not entity then
            return ""
        end
        local name = Osi.GetDisplayName(entity)
        return name and Ext.Loca.GetTranslatedString(name) or ""
    end

    Ext.Osiris.RegisterListener(
        "AttackedBy",
        7,
        "after",
        function(target, attacker, _, damage_type, amount, _, _)
            local damageBonus = tonumber(Vars["DamageBonus"]) or 0
            local isDebug = isDebug == 1
            local hasDealtDamage = amount and amount > 0

            if damageBonus > 0 and Osi.IsPartyMember(attacker, 1) == 1 then
                local isNonLethal =
                    Osi.HasAppliedStatus(attacker, "NON_LETHAL") == 1 or
                    Osi.HasActiveStatus(attacker, "NON_LETHAL") == 1

                if not isNonLethal and Osi.IsEnemy(target, attacker) == 1 then
                    local extraDmg = math.floor(amount * (damageBonus / 100))
                    if isDebug then
                        print("Extra damage to deal: " .. extraDmg)
                    end

                    if extraDmg > 0 then
                        ApplySafeDamage(target, extraDmg, damage_type)
                    end
                end
            end

            local isRaidBossEnraged = Osi.HasActiveStatus(CombatRandomizer_ChosenRaidBoss, "CR_RAIDBOSS_ENRAGED") == 1

            if attacker == CombatRandomizer_ChosenRaidBoss and isRaidBossEnraged then
                local applyBossEffect = RAID_BOSS_EFFECTS[RandomRaidBossTransformation]
                if applyBossEffect then
                    applyBossEffect(target)
                end
            end

            if target == CombatRandomizer_ChosenRaidBoss and isRaidBossEnraged then
                if RandomRaidBossTransformation == "CINE_S_WYR_AnsurGhost_dc2cbb9b-d6d6-438b-8fad-cb6fb1b2f87e" then
                    if math.random(3) ~= 1 then -- 66% de probabilidad
                        Osi.CreateProjectileStrikeAt(attacker, "Projectile_LightningArrow")
                    end
                end
            end

            local attackerName = GetEntityDisplayName(attacker)
            local targetName = GetEntityDisplayName(target)

            if hasDealtDamage then
                if string.find(attackerName, "Blazing") then
                    Osi.ApplyStatus(target, "BURNING", 10)
                end

                if string.find(attackerName, "Glacial") then
                    Osi.ApplyStatus(target, "CHILLED", 10)
                end

                if string.find(attackerName, "Overloading") then
                    Osi.ApplyStatus(target, "SHOCKED", 10)
                    if math.random(4) == 1 then
                        Osi.CreateProjectileStrikeAt(target, "Projectile_ChromaticOrb_Lightning")
                    end
                end

                if string.find(attackerName, "Malachite") then
                    Osi.ApplyStatus(target, "WRAITHS_EMBRACE", 10)
                    Osi.ApplyStatus(target, "POISONED", 10)
                end

                if string.find(attackerName, "Volatile") then
                    Osi.ApplyStatus(target, "BLACKPOWDER_DETONATION", 5)
                end

                if string.find(attackerName, "Leeching") then
                    Osi.ApplyStatus(attacker, "WILD_MAGIC_HEAL_3", 5)
                    Osi.AddBoosts(attacker, "TemporaryHP(5)", "", "")
                    Osi.ApplyStatus(target, "BLEEDING", 5)
                end
            end

            if string.find(targetName, "Volatile") then
                if
                    Osi.GetHitpointsPercentage(target) < 60 and
                        Osi.HasAppliedStatus(target, "STEELWATCHER_QUADRUPED_SELFDESTRUCT_BEGIN") == 0
                 then
                    Osi.ApplyStatus(target, "STEELWATCHER_QUADRUPED_SELFDESTRUCT_BEGIN", 10)
                end
            end
        end
    )

    function ExistsInCombatNpcsDB(target)
        for i = #CombatNPCS, 1, -1 do
            if (target == CombatNPCS[i]) then
                print(target .. " is in combat npcs table")
                return 1
            end
        end
        return 0
    end

    function RemoveFromCombatNPCsTable(target)
        for k, v in pairs(CombatNPCS) do
            for i, v in ipairs(CombatNPCS) do
                if v == target then
                    print("removing from table " .. CombatNPCS[i])
                    return table.remove(CombatNPCS, i)
                end
            end
        end
    end

    Ext.Osiris.RegisterListener(
        "Dying",
        1,
        "before",
        function(dead_dude)
            if (string.find(Ext.Loca.GetTranslatedString(Osi.GetDisplayName(dead_dude)), "Overloading") ~= nil) then
                Osi.CreateProjectileStrikeAt(dead_dude, "Projectile_SuperNova_Dragon_Skeletal") --doesn't do damage luckily enough. also probably lags the shit out of lower end computers. oh well!
            end
            if (string.find(Ext.Loca.GetTranslatedString(Osi.GetDisplayName(dead_dude)), "Malachite") ~= nil) then
                Osi.CreateSurface(dead_dude, "SurfaceAcid", 5, 10)
            end
            --print(StupidFuckingBuggedAddedItems[dead_dude])
            if (ExistsInCombatNpcsDB(dead_dude) == 1) then
                Osi.Die(dead_dude) --just fuckin die fully
                CR_UnequipAllWornItems(dead_dude)
                if (tonumber(Vars["RandomTreasure"]) >= GetUpToHundred()) then
                    Osi.GenerateTreasure(dead_dude, GetRandomTreasureTable(), 1, Osi.GetHostCharacter())
                end
            end

            RemoveFromCombatNPCsTable(dead_dude)
            Osi.Die(dead_dude)
        end
    )

    local function IsItemContainer(itemGUID)
        local entity = Ext.Entity.Get(itemGUID)
        return entity ~= nil and entity.InventoryOwner ~= nil
    end

    Ext.Osiris.RegisterListener(
        "Opened",
        1,
        "after",
        function(itemGUID)
            if IsItemContainer(itemGUID) then
                GenerateMultiItemLoot(itemGUID)
            end
        end
    )

    function GenerateMultiItemLoot(targetContainer)
        if targetContainer == nil then
            return
        end

        local rollAmount = math.random(1, 1000) -- Usamos rango 1-1000 para mayor precisión
        local itemQuantity = 0

        -- Distribución de probabilidades sobre 1000:
        if rollAmount <= 500 then
            itemQuantity = 1 -- 50% de chance (Común)
        elseif rollAmount <= 750 then
            itemQuantity = 2 -- 25% de chance (Poco común)
        elseif rollAmount <= 900 then
            itemQuantity = 3 -- 15% de chance (Raro)
        elseif rollAmount <= 970 then
            itemQuantity = 4 -- 7% de chance (Muy raro)
        elseif rollAmount <= 995 then
            itemQuantity = 5 -- 2.5% de chance (Épico)
        else
            itemQuantity = 6 -- 0.5% de chance (Legendario / 1 de cada 200 veces)
        end

        -- 2. Generar cada objeto de forma independiente
        for i = 1, itemQuantity do
            local randomIndex = math.random(1, #CR_AllTreasureTables)
            local selectedTemplate = CR_AllTreasureTables[randomIndex]

            -- Insertar el objeto en el inventario del cadáver o cofre
            Osi.TemplateAddTo(selectedTemplate, targetContainer, 1, 0)
        end
    end

    LastAttacker = LastAttacker or {}

    -- Función para obtener un personaje de jugador válido (Host o fallback a DB)
    local function GetPlayerCharacter()
        local host = Osi.GetHostCharacter()
        if host and host ~= "" then
            return host
        end

        local players = Osi.DB_IsPlayer:Get(nil)
        if players and #players > 0 and players[1] and players[1][1] then
            return players[1][1]
        end

        return nil
    end

    Ext.Osiris.RegisterListener(
        "AttackedBy",
        7,
        "after",
        function(defender, attackerOwner, attacker, _, _, _, _)
            -- Priorizar el dueño (invocación/familiar) o el atacante directo
            local realAttacker =
                (attackerOwner and attackerOwner ~= "NULL_00000000-0000-0000-0000-000000000000") and attackerOwner or
                attacker

            if defender and realAttacker then
                LastAttacker[defender] = realAttacker
            end
        end
    )

    Ext.Osiris.RegisterListener(
        "Died",
        1,
        "after",
        function(characterGUID)
            if not characterGUID then
                return
            end

            if Osi.IsPlayer(characterGUID) == 1 then
                return
            end

            local attacker = LastAttacker[characterGUID] or GetPlayerCharacter()

            if attacker then
                local isAlly = Osi.IsAlly(characterGUID, attacker)
                if isAlly ~= 1 then
                    BuffExperiencePerKill(characterGUID, attacker)
                end
            end

            LastAttacker[characterGUID] = nil
        end
    )

    function BuffExperiencePerKill(character, attacker)
        if not character or not attacker then
            return
        end

        if Osi.IsPlayer(attacker) ~= 1 then
            return
        end

        local dropChance = 35
        if math.random(1, 100) > dropChance then
            return
        end

        local enemyLevel = Osi.GetLevel(character) or 1
        if enemyLevel < 1 then
            enemyLevel = 1
        end

        local baseXpPerLevel = math.random(15, 200)
        local calculatedXp = enemyLevel * baseXpPerLevel

        local multiplier = 1.0
        if enemyLevel >= 5 and enemyLevel <= 8 then
            multiplier = 1.5
        elseif enemyLevel > 8 then
            multiplier = 2.0
        end

        local finalXp = math.floor(calculatedXp * multiplier)

        if finalXp and finalXp > 0 then
            Osi.AddExplorationExperience(Party[1], finalXp)
            
            if (tonumber(Vars["ConsoleDebug"]) == 1) then
                print("Otorgando " .. tostring(finalXp) .. " XP extra al grupo.")
            end
        end

        local statusText = string.format("¡XP Bonus (%dnv): +%d!", enemyLevel, finalXp)

        pcall(
            function()
                Osi.RequestDisplayCombatText(attacker, statusText)
            end
        )
    end

    --anti-spell spam (sometimes works? fuck enemy AI dude bruh)
    Ext.Osiris.RegisterListener(
        "CastedSpell",
        5,
        "after",
        function(caster, spell, _, _, _)
            if (Osi.IsEnemy(caster, Osi.GetHostCharacter()) == 1 and Osi.IsInCombat(caster) == 1) then
                Osi.RemoveSpell(caster, spell)
                Osi.RemoveSpell(caster, spell, 1)
                Osi.RemoveSpell(caster, spell, 10)
            end
        end
    )
    Ext.Osiris.RegisterListener(
        "EnteredLevel",
        3,
        "after",
        function(char_to_clone, char_template, _) -- for cloning
            if (tonumber(Vars["EnemyMultiplication"]) > 0 and Osi.IsInCombat(Osi.GetHostCharacter()) == 1) then
                table.insert(CombatRandomizer_ClonedNPCS, char_to_clone)
                if
                    (char_to_clone ~= nil and GetCharacterFromTemplate(char_template) ~= nil and
                        Osi.GetFaction(GetCharacterFromTemplate(char_template)) ~= nil)
                 then
                    Osi.Transform(
                        char_to_clone,
                        GetCharacterFromTemplate(char_template),
                        "4acc6277-6dcd-4110-9450-b9379beaedac"
                    )
                    Osi.SetFaction(char_to_clone, Osi.GetFaction(GetCharacterFromTemplate(char_template)))
                    Osi.SetCanJoinCombat(char_to_clone, 1)
                    Osi.MakeWar(char_to_clone, Osi.GetHostCharacter(), 1)
                end
            end
        end
    )
    Ext.Osiris.RegisterListener(
        "CombatEnded",
        1,
        "after",
        function(combat)
            if (combat == Current_combat) then
                if (isDebug == 1) then
                    print("-------COMBAT ENDED-------")
                end
                RemoveRandomSpellFromParty()

                if CR_TransformedMembers then
                    for characterGUID, _ in pairs(CR_TransformedMembers) do
                        RevertPartyMember(characterGUID)
                    end
                end
                CR_PartyTransformTurns = {}

                for i = #CombatNPCS, 1, -1 do
                    if (tonumber(Vars["Transformations"]) > 0 and Osi.IsDead(CombatNPCS[i]) == 1) then
                        if (isDebug == 1) then
                            print("Removing transformations from:" .. CombatNPCS[i])
                        end
                    --RemoveTransforms(CombatNPCS[i])
                    end
                    if
                        (tonumber(Vars["Transformations"]) > 0 and
                            Osi.IsEnemy(Osi.GetHostCharacter(), CombatNPCS[i]) == 0)
                     then
                        if (isDebug == 1) then
                            print("Removing transformations from:" .. CombatNPCS[i])
                        end
                    --RemoveTransforms(CombatNPCS[i])
                    end
                end
                for l = #CombatRandomizer_ClonedNPCS, 1, -1 do
                    if (Osi.IsDead(CombatRandomizer_ClonedNPCS[l]) == 1) then
                        if (isDebug == 1) then
                            print("Setting off stage:" .. CombatRandomizer_ClonedNPCS[l])
                        end
                        Osi.SetOnStage(CombatRandomizer_ClonedNPCS[l], 0)
                    end
                    if (Osi.IsEnemy(CombatRandomizer_ClonedNPCS[l], Osi.GetHostCharacter()) == 0) then
                        if (isDebug == 1) then
                            print("Setting off stage:" .. CombatRandomizer_ClonedNPCS[l])
                        end
                        Osi.SetOnStage(CombatRandomizer_ClonedNPCS[l], 0)
                    end
                end
            end
            Osi.TimerLaunch("ClearRandomizerTables", 600)
        end
    )
end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)