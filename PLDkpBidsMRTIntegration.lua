

local _, PLDKPBids = ...

local maxRaidTimeDiff = 60*60*24 -- 1 day in seconds

function PLDKPBids:PLDKP_RegisterWithMRT()
    local bRet = false
    -- register item cost handler
    if ( MRT_RegisterItemCostHandler ~= nil ) then     
        MRT_RegisterItemCostHandler(PLDKPBids_MrtQueryItemCost, "PLDkpBids")
        bRet = true
    end

    -- register loot notifier in order to sync loot data between MRT instances
    if ( MRT_RegisterLootNotify ~= nil ) then     
        MRT_RegisterLootNotify(PLDKPBids_MrtLootNotify)
        bRet = true
    end

    return bRet
end

function PLDKPBids:PLDKP_UnRegisterWithMRT()
    if ( MRT_UnregisterItemCostHandler ~= nil ) then     
        MRT_UnregisterItemCostHandler(PLDKPBids_MrtQueryItemCost)
    end

    if ( MRT_UnregisterLootNotify ~= nil ) then     
        MRT_UnregisterLootNotify(PLDKPBids_MrtLootNotify)
    end
end

----------------------------
--  MRT Global API variables  --
----------------------------
-- Item actions
--MRT_LOOTACTION_NORMAL = 1;
--MRT_LOOTACTION_BANK = 2;
--MRT_LOOTACTION_DISENCHANT = 3;
--MRT_LOOTACTION_DELETE = 4;

-- Item notify sources
--MRT_NOTIFYSOURCE_ADD_POPUP = 1;
--MRT_NOTIFYSOURCE_ADD_SILENT = 2;
--MRT_NOTIFYSOURCE_ADD_GUI = 3;
--MRT_NOTIFYSOURCE_EDIT_GUI = 4;
--MRT_NOTIFYSOURCE_DELETE_GUI = 5;

-- returns
-- local retOK, dkpValue_tmp, playerName_tmp, itemNote_tmp, lootAction_tmp, supressCostDialog_tmp
-- lootAction = MRT_LOOTACTION_BANK
-- lootAction = MRT_LOOTACTION_DISENCHANT
-- lootAction = MRT_LOOTACTION_DELETE

function PLDKPBids_MrtQueryItemCost(notifierInfo)

    --local notifierInfo = {
    --    ["ItemLink"] = itemLink,
    --    ["ItemString"] = itemString,
    --    ["ItemId"] = itemId,
    --    ["ItemName"] = itemName,
    --    ["ItemColor"] = itemColor,
    --    ["ItemCount"] = itemCount,
    --    ["Looter"] = playerName,
    --    ["DKPValue"] = dkpValue,
    --    ["Time"] = MRT_GetCurrentTime(),
    --};
   
    PLDKP_debug("MRT querying item price for: " ..  notifierInfo["ItemLink"] .. ", looted by " .. notifierInfo["Looter"])
    local queryData = PLDkpBidsFrame_GetLastWinnerDataOfCurrentRaid(notifierInfo["Looter"], notifierInfo["ItemLink"], notifierInfo["ItemCount"], notifierInfo["Time"])

    if queryData then 
        local lootAction = nil
        PLDKP_debug("Found price: " .. tostring(queryData["Price"]) .. " buyer " .. queryData["MainCharName"] or queryData["Name"])
        return queryData["Price"], queryData["MainCharName"] or queryData["Name"], queryData["Note"], lootAction, true
    else
        PLDKP_debug("No data found for item and looter")
        error("No data found for item and looter") -- MRT will handle the error
    end
end

function PLDKPBids_MrtLootNotify(itemInfo, callType, raidNumber, lootNumber, oldItemInfo)
    --local itemInfo = {
    --    ["ItemLink"] = itemLink,
    --    ["ItemString"] = itemString,
    --    ["ItemId"] = itemId,
    --    ["ItemName"] = itemName,
    --    ["ItemColor"] = itemColor,
    --    ["ItemCount"] = itemCount,
    --    ["BossNumber"] = bossNum,
    --    ["Looter"] = playerName,
    --    ["DKPValue"] = dkpValue,
    --    ["Note"] = note,
    --    ["Time"] = MRT_GetCurrentTime(),
    --};

    if MRT_RaidLog then

        local mrtLootData = {}
        mrtLootData.itemInfo = itemInfo
        mrtLootData.callType = callType
        mrtLootData.raidNumber = raidNumber
        mrtLootData.lootNumber = lootNumber
        mrtLootData.oldItemInfo = oldItemInfo

        mrtLootData.raidInfo = {}
        mrtLootData.raidInfo["Bosskills"] = MRT_RaidLog[raidNumber]["Bosskills"]
        mrtLootData.raidInfo["RaidZone"] = MRT_RaidLog[raidNumber]["RaidZone"]
        mrtLootData.raidInfo["DiffID"] = MRT_RaidLog[raidNumber]["DiffID"]
        mrtLootData.raidInfo["RaidSize"] = MRT_RaidLog[raidNumber]["RaidSize"]
        mrtLootData.raidInfo["Realm"] = MRT_RaidLog[raidNumber]["Realm"]
        mrtLootData.raidInfo["StartTime"] = MRT_RaidLog[raidNumber]["StartTime"]
        mrtLootData.raidInfo["MostRecentRaid"] = (raidNumber == #MRT_RaidLog)

        PLDKP_debug("Sending MRT loot notification data...")
        -- send this raid info via AddonComs in RAID channel !
        PLDKPBids.Sync:SendData("PLMRTItemLoot", mrtLootData)
    else
        PLDKP_debug("MRT_RaidLog is not present or does not contain a raid with the given id " .. tostring(raidNumber))
    end
end

-- --------------------------------------------------------------------------
-- MRT specific comms receiving functions
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
-- FindLocalMrtRaid
-- 
-- Takes raid info sent by comms message and tries to find a matching local raid
-- in order to modify loots
-- --------------------------------------------------------------------------
function PLDKPBids:FindLocalMrtRaid(raidInfo)
    if not raidInfo then
        return nil
    end

    if MRT_RaidLog then
        if raidInfo["MostRecentRaid"] == true then
            PLDKP_debug("raidInfo to check is the most recent raid - returning '" .. tostring(#MRT_RaidLog) .. "' as the translated id")
            return #MRT_RaidLog
        end

        for i = 1, #MRT_RaidLog do
            local compareRaid = MRT_RaidLog[i]

            if compareRaid["RaidZone"] == raidInfo["RaidZone"] and 
                compareRaid["RaidSize"] == raidInfo["RaidSize"] and 
                compareRaid["Realm"] == raidInfo["Realm"] and
                compareRaid["DiffID"] == raidInfo["DiffID"] then
                    -- compare captured time variance and boss kills

                    local diff = (compareRaid["StartTime"] or 0) - (raidInfo["StartTime"] or 0)

                    if diff < 0 then
                        diff = diff * -1
                    end

                    if diff <= maxRaidTimeDiff then
                        -- start time is within range

                        -- check boss kills
                        if compareRaid["Bosskills"] and raidInfo["Bosskills"] and #compareRaid["Bosskills"] == #raidInfo["Bosskills"] then
                            local bossesEquals = true
                            -- check if the same bosses had been tracked
                            for b=1, #compareRaid["Bosskills"] do
                                bossesEquals = bossesEquals and ((compareRaid["Bosskills"][b]["BossId"] and raidInfo["Bosskills"][b]["BossId"] and compareRaid["Bosskills"][b]["BossId"] == raidInfo["Bosskills"][b]["BossId"] and compareRaid["Bosskills"][b]["Difficulty"] == raidInfo["Bosskills"][b]["Difficulty"]) 
                                                                 or ( compareRaid["Bosskills"][b]["Difficulty"] == raidInfo["Bosskills"][b]["Difficulty"] and compareRaid["Bosskills"][b]["Name"] == raidInfo["Bosskills"][b]["Name"]))
                            end

                            if bossesEquals then
                                return i
                            end
                        end
                    end
            end
        end
    else
        PLDKP_debug("MRT_RaidLog is not present")
    end

    PLDKP_debug("Could not find a matching MRT_RaidLog")
    return nil
end

function PLDKPBids:ExistingLootForRaid(raidNumber, itemInfo)
    
    if MRT_RaidLog[raidNumber]["Loot"] then
        for i=1, #MRT_RaidLog[raidNumber]["Loot"] do
            local compareItem = MRT_RaidLog[raidNumber]["Loot"][i]

            if compareItem["ItemId"] == itemInfo["ItemId"] and compareItem["Looter"] == itemInfo["Looter"] and compareItem["ItemCount"] == itemInfo["ItemCount"] then
                return compareItem, i
            end
        end
    end

    return nil, nil
end

function PLDKPBids:MrtReceivedLootNotification(sender, raidInfo, itemInfo, callType, raidNumber, lootNumber, oldItemInfo)
    local localRaidNum = PLDKPBids:FindLocalMrtRaid(raidInfo)

    if localRaidNum then
        local existingItemOfCurrentRaid, existingItemLootNum = PLDKPBids:ExistingLootForRaid(localRaidNum, itemInfo)

        if callType == MRT_NOTIFYSOURCE_EDIT_GUI and oldItemInfo then
            -- in case of an edit - search using the old item info
            existingItemOfCurrentRaid, existingItemLootNum = PLDKPBids:ExistingLootForRaid(localRaidNum, oldItemInfo)
        end

        if existingItemOfCurrentRaid and existingItemLootNum then
            if callType == MRT_NOTIFYSOURCE_DELETE_GUI then
                -- removing existing item
                PLDKP_debug("Removing item from raidlog: Looter: " .. (existingItemOfCurrentRaid["Looter"] or "n/a") .. ", ItemLink: " .. (existingItemOfCurrentRaid["ItemLink"] or "n/a") .. ", Price: " .. tostring(existingItemOfCurrentRaid["DKPValue"] or 0))
                -- removing loot from local table
                tremove(MRT_RaidLog[localRaidNum]["Loot"], existingItemLootNum);

            elseif callType == MRT_NOTIFYSOURCE_EDIT_GUI then
                PLDKP_debug("Modifying item in raidlog: Looter: " .. (existingItemOfCurrentRaid["Looter"] or "n/a") .. ", ItemLink: " .. (existingItemOfCurrentRaid["ItemLink"] or "n/a").. ", Price: " .. tostring(existingItemOfCurrentRaid["DKPValue"] or 0))
                -- hange item info
                MRT_RaidLog[localRaidNum]["Loot"][existingItemLootNum] = itemInfo
            else
                -- check DKP Value
                if not existingItemOfCurrentRaid["DKPValue"] or existingItemOfCurrentRaid["DKPValue"] <= 0 and itemInfo["DKPValue"] then
                    PLDKP_debug("Update DKP value of already logged in raidlog. Looter: " .. (itemInfo["Looter"] or "n/a") .. ", ItemLink: " .. (itemInfo["ItemLink"] or "n/a").. ", Price: " .. tostring(itemInfo["DKPValue"] or 0))
                    existingItemOfCurrentRaid["DKPValue"] = itemInfo["DKPValue"]
                else
                    PLDKP_debug("Item already logged in raidlog - skipping. Looter: " .. (itemInfo["Looter"] or "n/a") .. ", ItemLink: " .. (itemInfo["ItemLink"] or "n/a").. ", Price: " .. tostring(itemInfo["DKPValue"] or 0))
                end
            end
        else
            if callType == MRT_NOTIFYSOURCE_ADD_POPUP or callType == MRT_NOTIFYSOURCE_ADD_SILENT or callType == MRT_NOTIFYSOURCE_ADD_GUI then
                PLDKP_debug("Inserting new item in raidlog: Looter: " .. (itemInfo["Looter"] or "n/a") .. ", ItemLink: " .. (itemInfo["ItemLink"] or "n/a").. ", Price: " .. tostring(itemInfo["DKPValue"] or 0))
                tinsert(MRT_RaidLog[localRaidNum]["Loot"], itemInfo);
            else
                PLDKP_debug("Do not add new loot item because of callType was not ADD")
            end
        end
    else
        PLDKP_debug("Error transforming incoming raidinformation to local raid index")
    end
end
