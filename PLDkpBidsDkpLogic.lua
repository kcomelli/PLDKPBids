local _, PLDKPBids = ...

local LBZ = LibStub("LibBabble-Zone-3.0");
local LBZR = LBZ:GetReverseLookupTable();

-------------------------------------------------------------------------------
-- DKP related functions
-------------------------------------------------------------------------------

function PLDKPBids:EnsureDkpData() 
    -- dkp pulgins - add here
    PLDKPBids:PLDKP_CheckGetDkp()

    -- check if saved variable dkp info version
    if PLDKPBids:IsDkpDataLoaded() then
        if PLDKP_DkpInfo then
            -- check if stored version or loaded needs to be updated
            if tonumber(PLDKP_DkpInfo.timestamp) > tonumber(PLDKPBids.dkp_info.timestamp) then
                -- use saved variable DKP data because it is newer
                PLDKPBids.dkp_info = PLDKP_DkpInfo
                PLDKPBids.dkp_data = PLDKP_DkpData
            elseif tonumber(PLDKP_DkpInfo.timestamp) < tonumber(PLDKPBids.dkp_info.timestamp) then
                -- update save variable dkp data
                PLDKP_DkpInfo = PLDKPBids.dkp_info
                PLDKP_DkpData = PLDKPBids.dkp_data    
            end
        else
            -- save current dkp info and data since none is stored yet
            PLDKP_DkpInfo = PLDKPBids.dkp_info
            PLDKP_DkpData = PLDKPBids.dkp_data
        end

        -- store my current DKP version as most recent one
        PLDKPBids.MostRecentDkpVersion = tonumber(PLDKPBids.dkp_info.timestamp)

        return true
    end

    return false
end

function PLDKPBids:InitiateDkpVersionComms() 
    if PLDKPBids:IsDkpDataLoaded() then
        -- broadcast my version
        PLDKPBids.Sync:SendData("PLDKPDkpVersion", tostring(PLDKPBids.MostRecentDkpVersion))
    else
        -- i do not have any DKP data
        -- request a version
        PLDKPBids.Sync:VerifyAndRequestVersion(nil)
    end
end

---------------------------------------------------------------------
-- function PLDKPBids:IsDkpDataLoaded()
--
-- Check if DKP data is available
---------------------------------------------------------------------
function PLDKPBids:IsDkpDataLoaded() 
    return PLDKPBids.dkp_data ~= nil and PLDKPBids.dkp_info ~= nil
end

---------------------------------------------------------------------
-- function PLDKPBids:PlayerHasDkpData(name)
--
-- Check if a character has dkp data
---------------------------------------------------------------------
function PLDKPBids:PlayerHasDkpData(name) 
    local transName, transRealm, transServerName = PLDKPBids:CharaterNameTranslation(name)
    
    if(PLDKPBids:IsDkpDataLoaded() == false) then
        return false
    end

    return PLDKPBids.dkp_data.players[transName] ~= nil or PLDKPBids.dkp_data.players[transServerName] ~= nil
end

---------------------------------------------------------------------
-- function PLDKPBids:PlayerGetDkpData(name)
--
-- Get current DKP of player
---------------------------------------------------------------------
function PLDKPBids:PlayerGetDkpData(name) 
    local transName, transRealm, transServerName = PLDKPBids:CharaterNameTranslation(name)
    
    if(PLDKPBids:PlayerHasDkpData(name) == false) then
        return 0
    end

    if(PLDKPBids.dkp_data.players[transName] ~= nil) then
        return PLDKPBids.dkp_data.players[transName].dkp_current
    else
        return PLDKPBids.dkp_data.players[transServerName].dkp_current
    end
end

---------------------------------------------------------------------
-- function PLDKPBids:PlayerGetDkpClass(name)
--
-- Get player's class from DKP system
---------------------------------------------------------------------
function PLDKPBids:PlayerGetDkpClass(name) 
    local transName, transRealm, transServerName = PLDKPBids:CharaterNameTranslation(name)
    
    if(PLDKPBids:PlayerHasDkpData(name) == false) then
        return false
    end

    if(PLDKPBids.dkp_data.players[transName] ~= nil) then
        return PLDKPBids.dkp_data.players[transName].class
    else
        return PLDKPBids.dkp_data.players[transServerName].class
    end
end

---------------------------------------------------------------------
-- function PLDKPBids:CountDKPEntries()
--
-- counts the number of DKP entries
-- Requires GetDKP
---------------------------------------------------------------------
function PLDKPBids:CountDKPEntries()
	local nRet = 0;
	
	if ( PLDKPBids:IsDkpDataLoaded() ) then

		for pName in pairs(PLDKPBids.dkp_data.players) do
			nRet=nRet+1;
		end
	end
	
	return nRet;
end

---------------------------------------------------------------------
-- function PLDKPBids:HasCustomizedZoneDKP(zoneName)
--
-- true if the zone has customized zone min dkp
---------------------------------------------------------------------
function PLDKPBids:HasCustomizedZoneDKP(zoneName)
    if(not zoneName or zoneName == "Default") then
        return false
    end

    return (PLDkpBidsOptions["MinDKPPerZone"] and PLDkpBidsOptions["MinDKPPerZone"][zoneName])
end

---------------------------------------------------------------------
-- function   PLDKPBids:GetMinDkpOption(zoneName, dkpSetting)
--
-- gets the min dkp from the settings based on the zone or default as fallback
---------------------------------------------------------------------
function PLDKPBids:GetMinDkpOption(zoneName, dkpSetting)
    return (PLDkpBidsOptions["MinDKPPerZone"] and PLDkpBidsOptions["MinDKPPerZone"][zoneName] and PLDkpBidsOptions["MinDKPPerZone"][zoneName][dkpSetting]) or PLDkpBidsOptions[dkpSetting] or PLDkpBidsOptions["DefaultMinDKP"]
end

---------------------------------------------------------------------
-- function   PLDKPBids:SetMinDkpOption(zoneName, dkpSetting, minDkp)
--
-- sets the min dkp setting for a given zone or the default values
---------------------------------------------------------------------
function PLDKPBids:SetMinDkpOption(zoneName, dkpSetting, minDkp)
    if minDkp ~= nil then
        if(not zoneName or zoneName == "Default") then
            PLDkpBidsOptions[dkpSetting] = minDkp
        else
            if not PLDkpBidsOptions["MinDKPPerZone"] then
                PLDkpBidsOptions["MinDKPPerZone"] = {}
            end
            if not PLDkpBidsOptions["MinDKPPerZone"][zoneName] then
                PLDkpBidsOptions["MinDKPPerZone"][zoneName] = {}
            end

            PLDkpBidsOptions["MinDKPPerZone"][zoneName][dkpSetting] = minDkp
        end
    else
        if (zoneName and zoneName ~= "Default") then
            if not PLDkpBidsOptions["MinDKPPerZone"] then
                PLDkpBidsOptions["MinDKPPerZone"] = {}
            end
            if not PLDkpBidsOptions["MinDKPPerZone"][zoneName] then
                PLDkpBidsOptions["MinDKPPerZone"][zoneName] = {}
            end

			PLDkpBidsOptions["MinDKPPerZone"][zoneName][dkpSetting] = nil -- remove entry
		end
    end
end

---------------------------------------------------------------------
-- function PLDKPBids:ClearCustomizedZoneDKP(zoneName)
--
-- clear all zone related min dkp settings
---------------------------------------------------------------------
function PLDKPBids:ClearCustomizedZoneDKP(zoneName)
    PLDkpBidsOptions["MinDKPPerZone"][zoneName] = nil;
end

---------------------------------------------------------------------
-- function  PLDKPBids:CalculateMinBidPrice(itemLink)
--
-- extracts the minimum DKP of an item based on configuration
-- uses current zone to identify different sets of min dkp
---------------------------------------------------------------------
function PLDKPBids:CalculateMinBidPrice(itemLink)
    local nRet = PLDkpBidsOptions["DefaultMinDKP"]
    local currentZone = GetRealZoneText()

    -- use english name for zone
    currentZone = LBZR[currentZone] or currentZone
    PLDKP_debug("Current zone is: " .. currentZone)

    if itemLink ~= nil then
        local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
        local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID = GetItemInfo (itemId);

        -- check if the item id is part of the special table
        if PLDkpBidsOptions["MinDKPSpecial"] and PLDkpBidsOptions["MinDKPSpecial"][itemId] then
            PLDKP_debug("Item id " .. tostring(itemId) .. " has configured min-DKP of " .. tostring(PLDkpBidsOptions["MinDKPSpecial"][itemId]));
            return PLDkpBidsOptions["MinDKPSpecial"][itemId]
        end

        if PLDKPBids:IsTwoHand(itemLink) and PLDKPBids:GetMinDkpOption(currentZone, "MinDKPTwoHand") then
            PLDKP_debug("Item id " .. tostring(itemId) .. " identified as 2H Weapon with configured min-DKP of " .. tostring(PLDKPBids:GetMinDkpOption(currentZone, "MinDKPTwoHand") .. " for zone '" .. (currentZone or "Default") .. "'"));
            return PLDKPBids:GetMinDkpOption(currentZone, "MinDKPTwoHand")
        end

        if PLDKPBids:IsOneHand(itemLink) and PLDKPBids:GetMinDkpOption(currentZone, "MinDKPOneHand") then
            PLDKP_debug("Item id " .. tostring(itemId) .. " identified as 1H Weapon/Shield/Offhand/Wand/Gun/Bow with configured min-DKP of " .. tostring(PLDKPBids:GetMinDkpOption(currentZone, "MinDKPTwoHand") .. " for zone '" .. (currentZone or "Default") .. "'"));
            return PLDKPBids:GetMinDkpOption(currentZone, "MinDKPOneHand")
        end

        if PLDKPBids:IsEquip(itemLink)  then
            PLDKP_debug("Item id " .. tostring(itemId) .. " identified as equipment ");

            if PLDKPBids:IsSetItem(itemLink) and PLDKPBids:GetMinDkpOption(currentZone, "MinDKPSetEquip") then
                PLDKP_debug("Item id " .. tostring(itemId) .. " identified as SET with configured min-DKP of " .. tostring(PLDKPBids:GetMinDkpOption(currentZone, "MinDKPSetEquip") .. " for zone '" .. (currentZone or "Default")  .. "'"));
                return PLDKPBids:GetMinDkpOption(currentZone, "MinDKPSetEquip")
            elseif PLDKPBids:GetMinDkpOption(currentZone, "MinDKPEquip") then
                PLDKP_debug("Item id " .. tostring(itemId) .. " identified as Equipment configured min-DKP of " .. tostring( PLDKPBids:GetMinDkpOption(currentZone, "MinDKPEquip") .. " for zone '" .. (currentZone or "Default") .. "'"));
                return  PLDKPBids:GetMinDkpOption(currentZone, "MinDKPEquip")
            end
        end
    end

    return nRet
end