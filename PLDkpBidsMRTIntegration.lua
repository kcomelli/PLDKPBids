

local _, PLDKPBids = ...

function PLDKPBids:PLDKP_RegisterWithMRT()
    if ( MRT_RegisterItemCostHandler ~= nil ) then     
        MRT_RegisterItemCostHandler(PLDKPBids.MrtQueryItemCost, "PLDkpBids")
        return true
    end

    return false
end

function PLDKPBids:PLDKP_UnRegisterWithMRT()
    if ( MRT_UnregisterItemCostHandler ~= nil ) then     
        MRT_UnregisterItemCostHandler(PLDKPBids.MrtQueryItemCost)
    end
end

-- returns
-- local retOK, dkpValue_tmp, playerName_tmp, itemNote_tmp, lootAction_tmp, supressCostDialog_tmp
-- lootAction = MRT_LOOTACTION_BANK
-- lootAction = MRT_LOOTACTION_DISENCHANT
-- lootAction = MRT_LOOTACTION_DELETE
function PLDKPBids:MrtQueryItemCost(notifierInfo)

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

    --PLDKP_LastWinners[sDate] = {};
    --PLDKP_LastWinners[sDate]["Name"] = pName; 
    --PLDKP_LastWinners[sDate]["MainCharName"] = PLDkpBidsFrame_GetMainCharOfTwink(pName);
    --PLDKP_LastWinners[sDate]["RaidID"] = PLDKP_CurrentRaidID;
    --PLDKP_LastWinners[sDate]["Price"] = nPrice;
    --PLDKP_LastWinners[sDate]["Note"] = "";
    --PLDKP_LastWinners[sDate]["Date"] = date();
    --PLDKP_LastWinners[sDate]["ItemName"] = name;
    --PLDKP_LastWinners[sDate]["ItemLink"] = _pldkp_currentItem;
    --PLDKP_LastWinners[sDate]["ItemTexture"] = _pldkp_currentItemTexture;
    
    PLDKP_debug("MRT querying item price for: " ..  notifierInfo["ItemLink"] .. ", looted by " .. notifierInfo["Looter"])

    local queryData = PLDkpBidsFrame_GetLastWinnerDataOfCurrentRaid(notifierInfo["Looter"], notifierInfo["ItemLink"], notifierInfo["ItemCount"], notifierInfo["Time"])

    if queryData then 
        local lootAction = nil
        PLDKP_debug("Found price: " .. tostring(queryData["Price"]) .. " buyer " .. queryData["MainCharName"] or queryData["Name"])
        return true, queryData["Price"], queryData["MainCharName"] or queryData["Name"], queryData["Note"], lootAction, true
    else
        PLDKP_debug("No data found for item and looter")
    end

    return false
end
