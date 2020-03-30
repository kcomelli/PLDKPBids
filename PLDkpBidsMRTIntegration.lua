

local _, PLDKPBids = ...

local LBB = LibStub("LibBabble-Boss-3.0");
local LBZ = LibStub("LibBabble-Zone-3.0");
local LBZR = LBZ:GetReverseLookupTable();
local LBBR = LBB:GetReverseLookupTable();

local maxRaidTimeDiff = 60*60*24 -- 1 day in seconds

PLDKPBids.MrtLootCommsProcessing = {}

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

-- -----------------------------------------------------------------------------
-- MRT item price query hook
--
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

-- -----------------------------------------------------------------------------
-- MRT loot info hook
--
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
        -- send english zone name if available
        mrtLootData.raidInfo["RaidZone"] = (LBZR[MRT_RaidLog[raidNumber]["RaidZone"]] or MRT_RaidLog[raidNumber]["RaidZone"])
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

-- -----------------------------------------------------------------------------
-- Will be called if receiving loot info via comms
--
function PLDKPBids:MrtReceivedLootNotification(sender, raidInfo, itemInfo, callType, raidNumber, lootNumber, oldItemInfo)
    
    local mrtData = {}
    mrtData.sender = sender
    mrtData.raidInfo = raidInfo
    mrtData.itemInfo = itemInfo
    mrtData.callType = callType
    mrtData.raidNumber = raidNumber
    mrtData.lootNumber = lootNumber
    mrtData.oldItemInfo = oldItemInfo

    -- schedule loot notification processing received via comms in order to avoid double entries
    -- loot info from comms may be faster than from 
    PLDkpBidsFrame_Schedule("PLDKPBids_MrtLootNotify_Comms_DelayProcessing", 2, mrtData)
end

function PLDKPBids_MrtLootNotify_Comms_DelayProcessing(mrtData)

    if PLDKPBids.MrtLootCommsProcessing.callType == callType and
        (PLDKPBids.MrtLootCommsProcessing.zone == raidInfo["RaidZone"] or PLDKPBids:IsSameZone((PLDKPBids.MrtLootCommsProcessing.zone or ""), raidInfo["RaidZone"])) and
        PLDKPBids.MrtLootCommsProcessing.size == raidInfo["RaidSize"] and 
        PLDKPBids.MrtLootCommsProcessing.realm == raidInfo["Realm"] and
        PLDKPBids.MrtLootCommsProcessing.itemId == itemInfo["ItemId"] and
        PLDKPBids.MrtLootCommsProcessing.looter == itemInfo["Looter"] and
        PLDKPBids.MrtLootCommsProcessing.itemCount == itemInfo["ItemCount"] then

        PLDKP_debug("Skip MRT loot notification processing because it is already being processed")
        return
    end

    local sender = mrtData.sender
    local raidInfo = mrtData.raidInfo
    local itemInfo = mrtData.itemInfo
    local callType = mrtData.callType
    local raidNumber = mrtData.raidNumber
    local lootNumber = mrtData.lootNumber
    local oldItemInfo = mrtData.oldItemInfo

    local localRaidNum = PLDKPBids:FindLocalMrtRaid(raidInfo)

    -- set currently processing info
    -- this should protect processing the same item modification twice if sent from multiple players
    PLDKPBids.MrtLootCommsProcessing.callType = callType
    PLDKPBids.MrtLootCommsProcessing.zone = raidInfo["RaidZone"]
    PLDKPBids.MrtLootCommsProcessing.size = raidInfo["RaidSize"]
    PLDKPBids.MrtLootCommsProcessing.realm = raidInfo["Realm"]
    PLDKPBids.MrtLootCommsProcessing.itemId = itemInfo["ItemId"]
    PLDKPBids.MrtLootCommsProcessing.looter = itemInfo["Looter"]
    PLDKPBids.MrtLootCommsProcessing.itemCount = itemInfo["ItemCount"]

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

    -- reset processing info
    PLDKPBids.MrtLootCommsProcessing = {}
end

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

            local compareRaid = MRT_RaidLog[#MRT_RaidLog]

            -- PLDKP_errln("Checking zone (" .. tostring(i) .. "):  - " .. (tostring(compareRaid["RaidZone"]) or "na") .. " vs " .. (tostring(raidInfo["RaidZone"]) or "na"))
            -- PLDKP_errln("Checking size (" .. tostring(i) .. "):  - ".. (tostring(compareRaid["RaidSize"]) or "na") .. " vs " .. (tostring(raidInfo["RaidSize"]) or "na"))
            -- PLDKP_errln("Checking realm (" .. tostring(i) .. "):  - ".. (tostring(compareRaid["Realm"]) or "na") .. " vs " .. (tostring(raidInfo["Realm"]) or "na"))
            -- PLDKP_errln("Checking diff (" .. tostring(i) .. "):  - ".. (tostring(compareRaid["DiffID"]) or "na") .. " vs " .. (tostring(raidInfo["DiffID"]) or "na"))

            if PLDKPBids:IsSameZone(compareRaid["RaidZone"], raidInfo["RaidZone"]) and 
                compareRaid["RaidSize"] == raidInfo["RaidSize"] and 
                compareRaid["Realm"] == raidInfo["Realm"] and
                compareRaid["DiffID"] == raidInfo["DiffID"] then

                    local diff = (compareRaid["StartTime"] or 0) - (raidInfo["StartTime"] or 0)

                    if diff < 0 then
                        diff = diff * -1
                    end

                    if diff <= maxRaidTimeDiff then
                        PLDKP_debug("raidInfo to check is the most recent raid - returning '" .. tostring(#MRT_RaidLog) .. "' as the translated id")
                        return #MRT_RaidLog
                    else
                        PLDKP_errln("Latest raid matches but is older or newer than the current one (at least 1 day), searching matching raid")
                        --PLDKP_errln("Compare Start: " .. (compareRaid["StartTime"] or 0) .. " - Raidinfo start: " .. (raidInfo["StartTime"] or 0))
                    end
            else
                PLDKP_errln("Latest raid not matching incoming query, searching matching raid")
            end
        end

        for i = #MRT_RaidLog, 1, -1 do
            local compareRaid = MRT_RaidLog[i]
            -- PLDKP_errln("Checking zone (" .. tostring(i) .. "):  - " .. (tostring(compareRaid["RaidZone"]) or "na") .. " vs " .. (tostring(raidInfo["RaidZone"]) or "na"))
            -- PLDKP_errln("Checking size (" .. tostring(i) .. "):  - ".. (tostring(compareRaid["RaidSize"]) or "na") .. " vs " .. (tostring(raidInfo["RaidSize"]) or "na"))
            -- PLDKP_errln("Checking realm (" .. tostring(i) .. "):  - ".. (tostring(compareRaid["Realm"]) or "na") .. " vs " .. (tostring(raidInfo["Realm"]) or "na"))
            -- PLDKP_errln("Checking diff (" .. tostring(i) .. "):  - ".. (tostring(compareRaid["DiffID"]) or "na") .. " vs " .. (tostring(raidInfo["DiffID"]) or "na"))

            if PLDKPBids:IsSameZone(compareRaid["RaidZone"], raidInfo["RaidZone"]) and 
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
                                                                 or ( compareRaid["Bosskills"][b]["Difficulty"] == raidInfo["Bosskills"][b]["Difficulty"] and PLDKPBids:IsSameBoss(compareRaid["Bosskills"][b]["Name"], raidInfo["Bosskills"][b]["Name"])))

                                if bossesEquals == false then
                                    PLDKP_errln("Boss nr: " .. tostring(b) .. " did not match! Id: " .. tostring(raidInfo["Bosskills"][b]["BossId"] or "na") .. "/" .. tostring(compareRaid["Bosskills"][b]["BossId"] or "na") .. ", Diff: " .. tostring(raidInfo["Bosskills"][b]["Difficulty"] or "na") .. "/" .. tostring(compareRaid["Bosskills"][b]["Difficulty"] or "na"))
                                    b = #compareRaid["Bosskills"]
                                end
                            end

                            if bossesEquals then
                                return i
                            end
                        end
                    else
                        PLDKP_errln("Found match at '" .. tostring(i) .. "' but is older or newer than the current one (at least 1 day), searching matching raid")
                        --PLDKP_errln("Compare Start: " .. (compareRaid["StartTime"] or 0) .. " - Raidinfo start: " .. (raidInfo["StartTime"] or 0))
                    end
            end
        end
    else
        PLDKP_debug("MRT_RaidLog is not present")
    end

    PLDKP_debug("Could not find a matching MRT_RaidLog")
    return nil
end

-- -----------------------------------------------------------------------------
-- Check if the loot info of an item has already been recorded
--
function PLDKPBids:ExistingLootForRaid(raidNumber, itemInfo)
    
    if MRT_RaidLog[raidNumber] and MRT_RaidLog[raidNumber]["Loot"] then
        for i=1, #MRT_RaidLog[raidNumber]["Loot"] do
            local compareItem = MRT_RaidLog[raidNumber]["Loot"][i]

            if compareItem["ItemId"] == itemInfo["ItemId"] and compareItem["Looter"] == itemInfo["Looter"] and compareItem["ItemCount"] == itemInfo["ItemCount"] then
                return compareItem, i
            end
        end
    end

    return nil, nil
end

function PLDKPBids:IsSameZone(zone1, zone2)
    local ret = false;

    if(zone1 and zone2) then
        -- compare lcoale zone name and english version
        ret = (LBZR[zone1] or zone1) == (LBZR[zone2] or zone2)
    end

    return ret;
end

function PLDKPBids:IsSameBoss(bossName1, bossName2)
    local ret = false;

    if(bossName1 and bossName2) then
        -- compare lcoale boss name and english version
        ret = (LBBR[bossName1] or bossName1) == (LBBR[zone2] or bossName2)
    end

    return ret;
end