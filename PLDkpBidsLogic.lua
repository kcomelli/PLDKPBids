local _, PLDKPBids = ...

---------------------------------------------------------------------
-- function PLDKPBids:pairsByKeys(t, f)
--
-- This function will replace the pairs function in a for statement.
-- Sorts the output by key name
---------------------------------------------------------------------
function PLDKPBids:pairsByKeys (t, f)
	local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
	return iter
end



-------------------------------------------------------------------------------
-- player/character functions
-------------------------------------------------------------------------------

---------------------------------------------------------------------
-- function PLDKPBids:GetPlayerName(unitId, showServer)
--
-- Returns the unit name
---------------------------------------------------------------------
function PLDKPBids:GetPlayerName(unitId, showServer)
	showServer = showServer or true
	name, realm = UnitName(unitId)

	if(name == nil) then
		return "unkown-player"
	end

	if(reaml == nil) then
		realm = PLDKPBids.localRealm
	end

	return name .. "-" .. realm
end

---------------------------------------------------------------------
-- function PLDKPBids:CharaterNameTranslation(characterName)
--
-- takes a character name and splits/transform the name in the player name
-- and realm name returning
-- nameOnly, realmName, serverName
---------------------------------------------------------------------
function PLDKPBids:CharaterNameTranslation(characterName)
	local nameOnly
	local realmName
	local serverName

	nameOnly = characterName

	local dashIndex = string.find(characterName, "-", 1, true)

	if(dashIndex ~= nil and dashIndex >= 1) then
		nameOnly = string.sub(characterName, 1, dashIndex-1)
		realmName = string.sub(characterName, dashIndex+1)
		serverName = nameOnly .. "-" .. realmName
	else
		nameOnly = characterName
		realmName = PLDKPBids.localRealm
		serverName = nameOnly .. "-" .. realmName
	end

	return nameOnly, realmName, serverName
end