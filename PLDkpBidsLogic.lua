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



function PLDKPBids:GetItemIdFromName(itemName)
	if itemName then
		local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, _, _, _, _, itemVendorPrice, classID = GetItemInfo (itemName);

		local itemId = string.match(itemLink, "Hitem:(%d+):")

		if itemId then
			return tonumber(itemId)
		end
	end

	return nil
end

function PLDKPBids:GetItemIdFromLink(itemLink)
	if itemLink then
		local itemId = string.match(itemLink, "Hitem:(%d+):")

		if itemId then
			return tonumber(itemId)
		end
	end

	return nil
end

function PLDKPBids:IsOneHand(itemLink)
	if itemLink ~= nil then
		local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
		local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID = GetItemInfo (itemId);
		
		if itemEquipLoc == "INVTYPE_WEAPON" or -- One-Hand
		   itemEquipLoc == "INVTYPE_SHIELD" or -- Shield
		   itemEquipLoc == "INVTYPE_WEAPONMAINHAND" or -- Main-Hand Weapon
		   itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or -- Off-Hand Weapon
		   itemEquipLoc == "INVTYPE_HOLDABLE" or -- Held In Off-Hand
		   itemEquipLoc == "INVTYPE_RANGED" or -- Bows
		   itemEquipLoc == "INVTYPE_THROWN" or -- Ranged
		   itemEquipLoc == "INVTYPE_RELIC" or -- Relics
		   itemEquipLoc == "INVTYPE_RANGEDRIGHT" then -- Wands, Guns, and Crossbows	

			return true
		end
	end

	return false
end

function PLDKPBids:IsTwoHand(itemLink)
	if itemLink ~= nil then
		local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
		local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID = GetItemInfo (itemId);
		
		if itemEquipLoc == "INVTYPE_2HWEAPON" then -- Two-Handed
			return true
		end
	end

	return false
end

function PLDKPBids:IsEquip(itemLink)
	if itemLink ~= nil then
		local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
		local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID = GetItemInfo (itemId);
		
		if itemEquipLoc == "INVTYPE_HEAD" or -- Head
		   itemEquipLoc == "INVTYPE_NECK" or -- Neck
		   itemEquipLoc == "INVTYPE_SHOULDER" or -- Shoulder
		   itemEquipLoc == "INVTYPE_BODY" or -- Shirt
		   itemEquipLoc == "INVTYPE_CHEST" or -- Chest
		   itemEquipLoc == "INVTYPE_ROBE" or -- Chest
		   itemEquipLoc == "INVTYPE_WAIST" or -- Waist
		   itemEquipLoc == "INVTYPE_LEGS" or -- Legs
		   itemEquipLoc == "INVTYPE_FEET" or -- Feet
		   itemEquipLoc == "INVTYPE_WRIST" or -- Wrist
		   itemEquipLoc == "INVTYPE_HAND" or -- Hands
		   itemEquipLoc == "INVTYPE_FINGER" or -- Rings
		   itemEquipLoc == "INVTYPE_TRINKET" or -- Trinkets
		   itemEquipLoc == "INVTYPE_CLOAK" then -- Cloaks
			return true
		end
	end

	return false
end

function PLDKPBids:IsSetItem(itemLink)
	if itemLink ~= nil then
		local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
		local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo (itemId);
		
		--PLDKP_debug("    Name: " .. itemName)
		--PLDKP_debug("    Type: " .. itemType)
		--PLDKP_debug("    Subtype: " .. itemSubType)
		--PLDKP_debug("    Loc: " .. itemEquipLoc)
		--PLDKP_debug("    SetId: " .. (tostring(itemSetID) or "na"))

		-- if the item is part of a set - the id of the set will be returned
		return itemSetID ~= nil
	end

	return false
end

function PLDKPBids:GetGuildRank(player)
	local name, rank, rankIndex;
	local guildSize;
  
	if IsInGuild() then
	  guildSize = GetNumGuildMembers();
	  for i=1, guildSize do
		name, rank, rankIndex = GetGuildRosterInfo(i)
		name = strsub(name, 1, string.find(name, "-")-1)  -- required to remove server name from player (can remove in classic if this is not an issue)
		if name == player then
		  return rank, rankIndex;
		end
	  end
	  return "NOTINGUILD";
	end
	return "NOGUILD"
  end
  
  function PLDKPBids:GetGuildRankIndex(player)
	local name, rank;
	local guildSize,_,_ = GetNumGuildMembers();
  
	if IsInGuild() then
	  for i=1, tonumber(guildSize) do
		name,_,rank = GetGuildRosterInfo(i)
		name = strsub(name, 1, string.find(name, "-")-1)  -- required to remove server name from player (can remove in classic if this is not an issue)
		if name == player then
		  return rank+1;
		end
	  end
	  return false;
	end
  end

  function PLDKPBids:IsGuildPlayerOnline(player)
	local name, rank, rankIndex;
	local guildSize;
  
	if IsInGuild() then
	  guildSize = GetNumGuildMembers();
	  for i=1, guildSize do
		name, rank, rankIndex, _, _, _, _, _, isOnline, _, _, _, _, isMobile = GetGuildRosterInfo(i)
		name = strsub(name, 1, string.find(name, "-")-1)  -- required to remove server name from player (can remove in classic if this is not an issue)
		if name == player and isOnline == true and isMobile == false then
		  return true
		end
	  end
	  return false
	end
	return false
  end

function PLDKPBids:CheckOfficer()      -- checks if user is an officer IF core.IsOfficer is empty. Use before checks against core.IsOfficer
	if PLDKPBids.IsOfficer == "" then      -- used as a redundency as it should be set on load in init.lua GUILD_ROSTER_UPDATE event
	  if PLDKPBids:GetGuildRankIndex(UnitName("player")) == 1 then       -- automatically gives permissions above all settings if player is guild leader
		PLDKPBids.IsOfficer = true
		return;
	  end
	  if IsInGuild() then
		local curPlayerRank = PLDKPBids:GetGuildRankIndex(UnitName("player"))
		if curPlayerRank then
			PLDKPBids.IsOfficer = C_GuildInfo.GuildControlGetRankFlags(curPlayerRank)[12]
		end
	  else
		PLDKPBids.IsOfficer = false;
	  end
	end
  end