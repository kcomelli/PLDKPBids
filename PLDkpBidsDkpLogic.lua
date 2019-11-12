local _, PLDKPBids = ...

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
    end
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
-- function  PLDKPBids:CalculateMinBidPrice(itemLink)
--
-- extracts the minimum DKP of an item based on configuration
---------------------------------------------------------------------
function PLDKPBids:CalculateMinBidPrice(itemLink)
    local nRet = PLDkpBidsOptions["DefaultMinDKP"]

    if itemLink ~= nil then
        local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
        local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID = GetItemInfo (itemId);

        -- check if the item id is part of the special table
        if PLDkpBidsOptions["MinDKPSpecial"] and PLDkpBidsOptions["MinDKPSpecial"][itemId] then
            PLDKP_debug("Item id " .. tostring(itemId) .. " has configured min-DKP of " .. tostring(PLDkpBidsOptions["MinDKPSpecial"][itemId]));
            return PLDkpBidsOptions["MinDKPSpecial"][itemId]
        end

        if PLDKPBids:IsTwoHand(itemLink) and PLDkpBidsOptions["MinDKPTwoHand"] then
            PLDKP_debug("Item id " .. tostring(itemId) .. " identified as 2H Weapon with configured min-DKP of " .. tostring(PLDkpBidsOptions["MinDKPTwoHand"]));
            return PLDkpBidsOptions["MinDKPTwoHand"]
        end

        if PLDKPBids:IsOneHand(itemLink) and PLDkpBidsOptions["MinDKPOneHand"] then
            PLDKP_debug("Item id " .. tostring(itemId) .. " identified as 1H Weapon/Shield/Offhand/Wand/Gun/Bow with configured min-DKP of " .. tostring(PLDkpBidsOptions["MinDKPOneHand"]));
            return PLDkpBidsOptions["MinDKPOneHand"]
        end

        if PLDKPBids:IsEquip(itemLink)  then
            PLDKP_debug("Item id " .. tostring(itemId) .. " identified as equipment ");

            if PLDKPBids:IsSetItem(itemLink) and PLDkpBidsOptions["MinDKPSetEquip"] then
                PLDKP_debug("Item id " .. tostring(itemId) .. " identified as SET with configured min-DKP of " .. tostring(PLDkpBidsOptions["MinDKPSetEquip"]));
                return PLDkpBidsOptions["MinDKPSetEquip"]
            elseif PLDkpBidsOptions["MinDKPEquip"] then
                return PLDkpBidsOptions["MinDKPEquip"]
            end
        end
    end

    return nRet
end