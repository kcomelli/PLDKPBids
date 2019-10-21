local _, PLDKPBids = ...

-------------------------------------------------------------------------------
-- DKP related functions
-------------------------------------------------------------------------------


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

    return PLDKPBids.dkp_data.players[transName] ~= nill or PLDKPBids.dkp_data.players[transServerName] ~= nil
end

---------------------------------------------------------------------
-- function PLDKPBids:PlayerGetDkpData(name)
--
-- Get current DKP of player
---------------------------------------------------------------------
function PLDKPBids:PlayerGetDkpData(name) 
    local transName, transRealm, transServerName = PLDKPBids:CharaterNameTranslation(name)
    
    if(PLDKPBids:PlayerHasDkpData(name) == false) then
        return false
    end

    if(PLDKPBids.dkp_data.players[transName] ~= nill) then
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

    if(PLDKPBids.dkp_data.players[transName] ~= nill) then
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