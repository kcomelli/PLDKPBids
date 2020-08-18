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

function PLDKPBids:getKeysSortedByValue(tbl, sortFunction)
	local keys = {}
	for key in pairs(tbl) do
	  table.insert(keys, key)
	end
  
	table.sort(keys, function(a, b)
	  return sortFunction(tbl[a], tbl[b])
	end)
  
	return keys
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

	-- make sure first Character is upper case
	nameOnly = characterName:sub(1,1):upper()..characterName:sub(2)
	characterName = nameOnly

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
		--PLDKP_debug("    isCraftingReagent: " .. (tostring(isCraftingReagent) or "na"))
		--PLDKP_debug("    expacID: " .. (tostring(expacID) or "na"))
		--PLDKP_debug("    bindType: " .. (tostring(bindType) or "na"))
		--PLDKP_debug("    itemSubClassID: " .. (tostring(itemSubClassID) or "na"))
		--PLDKP_debug("    classID: " .. (tostring(classID) or "na"))

		-- if the item is part of a set - the id of the set will be returned
		return itemSetID ~= nil
	end

	return false
end

function PLDKPBids:IsSetToken(itemLink)
	if itemLink ~= nil then
		local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo (itemId);
		
		--[[
		PLDKP_debug(" itemName: " .. (itemName or "n/a"))				-- 
		PLDKP_debug(" itemLink: " .. (itemLink or "n/a"))
		PLDKP_debug(" itemRarity: " .. (itemRarity or "n/a"))			-- 4
		PLDKP_debug(" itemLevel: " .. (itemLevel or "n/a"))				-- 1, 60
		PLDKP_debug(" itemMinLevel: " .. (itemMinLevel or "n/a"))		-- 0, 60
		PLDKP_debug(" itemType: " .. (itemType or "n/a"))				-- Quest, Miscellaneous
		PLDKP_debug(" itemSubType: " .. (itemSubType or "n/a"))			-- Quest, Junk
		PLDKP_debug(" itemStackCount: " .. (itemStackCount or "n/a"))	-- 1
		PLDKP_debug(" itemEquipLoc: " .. (itemEquipLoc or "n/a"))		-- empty
		PLDKP_debug(" itemTexture: " .. (itemTexture or "n/a"))
		--]]

		if( itemRarity == 4 ) then  -- epic item
			if( itemMinLevel == itemLevel ) then -- item level and min level are equal for tokens
				if( (itemType=="Miscellaneous") and ( itemSubType == "Junk") ) then -- token type
					if( itemStackCount == 1 ) then  -- stack count = 1
						if( itemEquipLoc == "") then  -- location = empty
							return true
						end
					end
				end
			elseif( itemMinLevel == 0 and  itemLevel == 1) then -- check for AQ40 equip set tokens
				if( (itemType=="Quest") and ( itemSubType == "Quest") ) then -- token type
					if( itemStackCount == 1 ) then  -- stack count = 1
						if( itemEquipLoc == "") then  -- location = empty
							return true
						end
					end
				end
			end
		end

	end

	return false
end

function PLDKPBids:IsSetWeaponToken(itemLink)
	if itemLink ~= nil then
		local itemId = PLDKPBids:GetItemIdFromLink(itemLink)
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemVendorPrice, classID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo (itemId);
		
		--[[
		PLDKP_debug(" itemName: " .. (itemName or "n/a"))				-- 
		PLDKP_debug(" itemLink: " .. (itemLink or "n/a"))
		PLDKP_debug(" itemRarity: " .. (itemRarity or "n/a"))			-- 4
		PLDKP_debug(" itemLevel: " .. (itemLevel or "n/a"))				-- 60
		PLDKP_debug(" itemMinLevel: " .. (itemMinLevel or "n/a"))		-- 60
		PLDKP_debug(" itemType: " .. (itemType or "n/a"))				-- Miscellaneous
		PLDKP_debug(" itemSubType: " .. (itemSubType or "n/a"))			-- Junk
		PLDKP_debug(" itemStackCount: " .. (itemStackCount or "n/a"))	-- 1
		PLDKP_debug(" itemEquipLoc: " .. (itemEquipLoc or "n/a"))		-- empty
		PLDKP_debug(" itemTexture: " .. (itemTexture or "n/a"))
		--]]

		if( itemRarity >= 4 ) then  -- epic item
			if( itemMinLevel == itemLevel ) then -- item level and min level are equal for tokens
				if( (itemType=="Miscellaneous") and ( itemSubType == "Junk") ) then -- token type
					if( itemStackCount == 1 ) then  -- stack count = 1
						if( itemEquipLoc == "") then  -- location = empty
							if( string.find(itemName, "Qiraji") or itemRarity > 4) then	-- weapon token in AQ40 or Atiesh fragments
								return true;
							end
						end
					end
				end
			end
		end

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

  function PLDKPBids:GetGuildRosterIndex(player)
	local guildSize,_,_ = GetNumGuildMembers();
  
	if IsInGuild() then
	  for i=1, tonumber(guildSize) do
		name,_,rank = GetGuildRosterInfo(i)
		name = strsub(name, 1, string.find(name, "-")-1)  -- required to remove server name from player (can remove in classic if this is not an issue)
		if name == player then
		  return i;
		end
	  end
	  return false;
	end
  end

  function PLDKPBids:GetClassOfPlayerInMyGuild(playerIndex)
	if (playerIndex == false) then
		return nil
	end

	local name, rank, rankIndex, level, class, zone, note, 
  			officernote, online, status, classFileName, 
			  achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(playerIndex)
			  
	return class
  end

  function PLDKPBids:GetClassOfPlayerInMyGroup(playerName, groupStatus)
	if (playerName == nil) then
		return nil
	end

	local checkName, checkRealm, checkServerName = PLDKPBids:CharaterNameTranslation(playerName)
	
	if( groupStatus == "R" ) then
		nMemberCnt = GetNumGroupMembers();
		
		for nCounter = 1, nMemberCnt do
			name, rank, subgroup, level, class, filename, zone, online, isdead = GetRaidRosterInfo(nCounter);
			
			if (name ~= nil) then
				if( name == checkName or name == checkServerName) then
					localizedClass, englishClass, classIndex = UnitClass("raid"..nCounter)
					return localizedClass;
				end
			end
		end
	end

	if( groupStatus == "P" ) then
		nMemberCnt = GetNumGroupMembers();

		for nCounter = 1, nMemberCnt do
			name = PLDKPBids:GetPlayerName("party"..nCounter);
			if (name ~= nil) then
				--PLDKP_debug( "cnt" .. nCounter .. " name=" .. name);
				
				if( name == checkName or name == checkServerName) then
					localizedClass, englishClass, classIndex = UnitClass("party"..nCounter)
					return localizedClass;
				end
			end
		end

	end
	
	return nil
  end

  function PLDKPBids:GetPartyPlayersOfClass(className, groupStatus)
	local players = {}

	if( groupStatus == "R" ) then
		nMemberCnt = GetNumGroupMembers();
		
		for nCounter = 1, nMemberCnt do
			name, rank, subgroup, level, class, filename, zone, online, isdead = GetRaidRosterInfo(nCounter);
			
			if (name ~= nil) then
				localizedClass, englishClass, classIndex = UnitClass("raid"..nCounter)
				if (localizedClass == className) then
					table.insert(players, name)
				end
			end
		end
	end

	if( groupStatus == "P" ) then
		nMemberCnt = GetNumGroupMembers();

		for nCounter = 1, nMemberCnt do
			name = PLDKPBids:GetPlayerName("party"..nCounter);
			if (name ~= nil) then
				localizedClass, englishClass, classIndex = UnitClass("party"..nCounter)
				if (localizedClass == className) then
					table.insert(players, name)
				end
			end
		end
	end

	return players
  end

  function PLDKPBids:GetGuildPlayersOfClass(className, top)
	local players = {}
	local count=0
	local guildSize,_,_ = GetNumGuildMembers();
  
	if IsInGuild() then
	  for i=1, tonumber(guildSize) do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, 
			  achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(i)

		if class == className then
			table.insert(players, name)
			count = count + 1
			if (count >= top) then
				return players
			end

		end
	  end
	end

	return players
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

  function PLDKPBids:GetTimestamp()
	return time()
end

function PLDKPBids:LoadItemAndRun(itemId, callback)
	if(itemId and itemId ~= "") then
		if (PLDKPItemCache ~= nil and PLDKPItemCache[itemId] ~= nil) then
			local itemName = PLDKPItemCache[itemId]["Name"]
			local itemLink = PLDKPItemCache[itemId]["ItemLink"]
			local itemIcon = PLDKPItemCache[itemId]["Texture"]

			if (type(callback) == "function") then
				pcall(callback, itemId, itemName, itemLink, itemIcon)
			end
		else
			local item = Item:CreateFromItemID(itemId)
				item:ContinueOnItemLoad(function()
					-- inside callback!
					local itemId = item:GetItemID()
					local itemName = item:GetItemName()
					local itemLink = item:GetItemLink()
					local itemIcon = item:GetItemIcon()

					if (PLDKPItemCache == nil) then
						PLDKPItemCache = {}
					end
					if (PLDKPItemCache[itemId] == nil) then
						PLDKPItemCache[itemId] = {}
					end

					PLDKPItemCache[itemId]["Name"] = itemName
					PLDKPItemCache[itemId]["ItemLink"] = itemLink
					PLDKPItemCache[itemId]["Texture"] = itemIcon

					if (type(callback) == "function" and item:IsItemEmpty() ~= true) then
						pcall(callback, itemId, itemName, itemLink, itemIcon)
					end
				end)
		end
	end
end