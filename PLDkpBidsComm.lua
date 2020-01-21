local _, PLDKPBids = ...

PLDKPBids.Sync = LibStub("AceAddon-3.0"):NewAddon("PLDKPBids", "AceComm-3.0")

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibCompressAddonEncodeTable = LibCompress:GetAddonEncodeTable()

-------------------------------------------------
-- Register Broadcast Prefixs
-------------------------------------------------

function PLDKPBids.Sync:OnEnable()
    PLDKPBids.Sync:RegisterComm("PLDKPBuildCheck", PLDKPBids.Sync:OnCommReceived())		        -- broadcasts Addon build number to inform others an update is available.
    PLDKPBids.Sync:RegisterComm("PLDKPDkpVersion", PLDKPBids.Sync:OnCommReceived())		    -- broadcasts dkp data version in order to sync standings
    PLDKPBids.Sync:RegisterComm("PLDKPDkpVRequest", PLDKPBids.Sync:OnCommReceived())	-- request DKP version data
    PLDKPBids.Sync:RegisterComm("PLDKPDkpSync", PLDKPBids.Sync:OnCommReceived())	        -- DKP data sync
    PLDKPBids.Sync:RegisterComm("PLDKPDkpWinner", PLDKPBids.Sync:OnCommReceived())	        -- A new winner data was sent after an auction
    PLDKPBids.Sync:RegisterComm("PLMRTItemLoot", PLDKPBids.Sync:OnCommReceived())	        -- A new item loot info from another raidtracker has been received
    PLDKPBids.Sync:RegisterComm("PLDKPDelWinner", PLDKPBids.Sync:OnCommReceived())	        -- Delete a winner info
    PLDKPBids.Sync:RegisterComm("PLDKPEdtWinner", PLDKPBids.Sync:OnCommReceived())	        -- Edit a winner info
    PLDKPBids.Sync:RegisterComm("PLDKPSettings", PLDKPBids.Sync:OnCommReceived())	        -- Edit a winner info
end

function PLDKPBids.Sync:OnCommReceived(prefix, message, distribution, sender)
    PLDKP_debug("Receiving comms with prefix '" .. (prefix or "nil") .. "' from player '" .. (sender or "nil") .. "' ...")
    if (prefix) then
        if prefix == "PLDKPBuildCheck" and sender ~= UnitName("player") then
			local LastVerCheck = time() - PLDKPBids.LastVerCheck;

			if LastVerCheck > 1800 then   					-- limits the Out of Date message from firing more than every 30 minutes 
                PLDKPBids.LastVerCheck = time();
                PLDKP_debug("Buildnumber received is: " .. message .. ", local buildnumber is: " .. tostring(PLDKP_BUILD_NUMBER))
				if tonumber(message) > PLDKP_BUILD_NUMBER then
					PLDKP_println(PLDKP_BUILD_OUTOFDATE)
				end
			end

			if tonumber(message) < PLDKP_BUILD_NUMBER then
				PLDKPBids.Sync:SendData("PLDKPBuildCheck", tostring(PLDKP_BUILD_NUMBER))
			end
			return;
        elseif prefix == "PLDKPDkpVersion" and sender ~= UnitName("player") then
            -- save sender data
            PLDKPBids.KnownVersions[sender] = tonumber(message)
            PLDKP_debug("Received DKP version is " .. message)
            if PLDKPBids:IsDkpDataLoaded() then
                if tonumber(PLDKPBids.dkp_info.timestamp) > tonumber(message) then
                    -- I have a newer version of DKP data
                    -- broadcast my version
                    PLDKPBids.Sync:SendData("PLDKPDkpVersion", PLDKPBids.dkp_info.timestamp)
                elseif tonumber(PLDKPBids.dkp_info.timestamp) < tonumber(message) then
                    -- I have an older version
                    -- send DKP request
                    PLDKPBids.Sync:VerifyAndRequestVersion(tonumber(message))
                end
            else
                -- I do not have any DKP data yet
                -- send DKP request for the version currently catched
                PLDKPBids.Sync:VerifyAndRequestVersion(tonumber(message))
            end
        elseif prefix == "PLDKPDkpVRequest" and sender ~= UnitName("player") then
            if PLDKPBids:IsDkpDataLoaded() then
                if tonumber(PLDKPBids.dkp_info.timestamp) >= tonumber(message) then
                    -- 2 seconds delay before sending actual DKP data (see PLDkpBidsFrame_OnUpdate)
                    -- this will allow addOn sync if multiple versions are installed
                    -- to detect the highest version
                    PLDKPBids.TriggerSentDkpData = time() + 2 
                else
                    -- reset send timer - we do not have or own the version requests
                    -- typically if someone else will send the latest data and we will receive it
                    PLDKPBids.TriggerSentDkpData = 0 
                end
            end
        elseif prefix == "PLDKPDkpSync" and sender ~= UnitName("player") then
            PLDKPBids.TriggerSentDkpData = 0
            decoded = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(message))
            local success, deserialized = LibAceSerializer:Deserialize(decoded);
            if success then
                PLDKPBids.dkp_info = deserialized.dkp_info
                PLDKPBids.dkp_data= deserialized.dkp_data
                -- saved variables override

                PLDKP_DkpInfo = PLDKPBids.dkp_info
                PLDKP_DkpData = PLDKPBids.dkp_data   

                PLDKPBids.MostRecentDkpVersion = tonumber(PLDKPBids.dkp_info.timestamp)

                PLDKP_println(string.format(PLDKP_RECEIVED_NEW_DKPDATA, PLDKPBids.dkp_info.date, sender))
                -- update help table since DKP data is available
                PLDKPBids:CreateHelpTable()
                PLDKPBids:UpdateMyDkpStanding()

                -- resend version in order to update known versions of other clients
                PLDKPBids.Sync:SendData("PLDKPDkpVersion", PLDKPBids.dkp_info.timestamp)
            else
                print(deserialized)  -- error reporting if string doesn't get deserialized correctly
            end
        elseif (prefix == "PLDKPDkpWinner" or prefix == "PLDKPEdtWinner") and sender ~= UnitName("player") then
            decoded = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(message))
            local success, deserialized = LibAceSerializer:Deserialize(decoded);
            if success then
                if prefix == "PLDKPDkpWinner" then
                    if PLDKP_CurrentRaidID ~= deserialized.data["RaidID"] then
                        -- activiate raid id
                        -- important if MRT asks for prize
                        PLDKP_CurrentRaidID = deserialized.data["RaidID"]
                    end
                end 

                -- fix if not receiving texture informations
                if not deserialized.data["ItemTexture"] and deserialized.data["ItemLink"] then
                    local itemId = PLDKPBids:GetItemIdFromLink(deserialized.data["ItemLink"])
                    local gitemName, gitemLink, gitemRarity, gitemLevel, gitemMinLevel, gitemType, gitemSubType, gitemStackCount, gitemEquipLoc, gitemTexture = GetItemInfo(itemId);
                    deserialized.data["ItemTexture"] = gitemTexture
                end

                PLDKP_LastWinners[deserialized.raidId] = deserialized.data
                PLDKP_println(string.format(PLDKP_RECEIVED_WINNER_INFO, ((deserialized.data["Name"] or "na") .. " - " .. (deserialized.data["ItemLink"] or "na") .. " - " .. (deserialized.data["Price"] or "na") .. "DKP"), sender))
            else
                print(deserialized)  -- error reporting if string doesn't get deserialized correctly
            end
        elseif prefix == "PLDKPDelWinner" and sender ~= UnitName("player") then
            decoded = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(message))
            local success, deserialized = LibAceSerializer:Deserialize(decoded);
            if success then
                if PLDKP_LastWinners[deserialized.raidId] then
                    PLDKP_LastWinners[deserialized.raidId] = nil
                    PLDKP_println(string.format(PLDKP_RECEIVED_DEL_WINNER, ((deserialized.data["Name"] or "na") .. " - " .. (deserialized.data["ItemLink"] or "na") .. " - " .. (deserialized.data["Price"] or "na") .. "DKP"), sender))
                end
            else
                print(deserialized)  -- error reporting if string doesn't get deserialized correctly
            end
        elseif prefix == "PLMRTItemLoot" and sender ~= UnitName("player") then
            decoded = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(message))
            local success, deserialized = LibAceSerializer:Deserialize(decoded);
            if success then

                PLDKP_println(string.format(PLDKP_RECEIVED_MRT_LOOT_INFO, ((deserialized["itemInfo"].ItemName or "na") .. " - " .. (deserialized["itemInfo"].ItemLink or "na") .. " - looted by " .. (deserialized["itemInfo"].Looter or "na") .. " for " .. (deserialized["itemInfo"].DKPValue or "na") .. "DKP"), sender))
                if(PLDKPBids.MrtReceivedLootNotification) then
                    PLDKPBids:MrtReceivedLootNotification(sender, deserialized["raidInfo"], deserialized["itemInfo"], tonumber(deserialized["callType"] or "0"), tonumber(deserialized["raidNumber"] or "-1"), tonumber(deserialized["lootNumber"] or "-1"), deserialized["oldItemInfo"])
                end
            else
                PLDKP_debug("Error deserializing: " .. deserialized)
                print(deserialized)  -- error reporting if string doesn't get deserialized correctly
            end
        elseif prefix == "PLDKPSettings" and sender ~= UnitName("player") then
            decoded = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(message))
            local success, deserialized = LibAceSerializer:Deserialize(decoded);
            if success then
                -- copy relevant options from sender to local options
                PLDkpBidsOptions["DefBidTSpan"] = deserialized["DefBidTSpan"] or PLDkpBidsOptions["DefBidTSpan"]
                PLDkpBidsOptions["DefaultMinDKP"] = deserialized["DefaultMinDKP"] or PLDkpBidsOptions["DefaultMinDKP"]
                PLDkpBidsOptions["PriceAddVal"] = deserialized["PriceAddVal"] or PLDkpBidsOptions["PriceAddVal"]
                PLDkpBidsOptions["ValueStep"] = deserialized["ValueStep"] or PLDkpBidsOptions["ValueStep"]
                PLDkpBidsOptions["UseDKPOnEqualBids"] = deserialized["UseDKPOnEqualBids"] or PLDkpBidsOptions["UseDKPOnEqualBids"]
                PLDkpBidsOptions["IgnoreBidsOutsideGrp"] = deserialized["IgnoreBidsOutsideGrp"] or PLDkpBidsOptions["IgnoreBidsOutsideGrp"]
                PLDkpBidsOptions["AllowBidsGreaterThanDKP"] = deserialized["AllowBidsGreaterThanDKP"] or PLDkpBidsOptions["AllowBidsGreaterThanDKP"]
                PLDkpBidsOptions["MaxMinusDKP"] = deserialized["MaxMinusDKP"] or PLDkpBidsOptions["MaxMinusDKP"]
                PLDkpBidsOptions["AllwaysAllowMinBid"] = deserialized["AllwaysAllowMinBid"] or PLDkpBidsOptions["AllwaysAllowMinBid"]
                PLDkpBidsOptions["AllowHigherBidOverwrite"] = deserialized["AllowHigherBidOverwrite"] or PLDkpBidsOptions["AllowHigherBidOverwrite"]
                PLDkpBidsOptions["MinDKPOneHand"] = deserialized["MinDKPOneHand"] or PLDkpBidsOptions["MinDKPOneHand"]
                PLDkpBidsOptions["MinDKPTwoHand"] = deserialized["MinDKPTwoHand"] or PLDkpBidsOptions["MinDKPTwoHand"]
                PLDkpBidsOptions["MinDKPSetEquip"] = deserialized["MinDKPSetEquip"] or PLDkpBidsOptions["MinDKPSetEquip"]
                PLDkpBidsOptions["MinDKPEquip"] = deserialized["MinDKPEquip"] or PLDkpBidsOptions["MinDKPEquip"]

                if(deserialized["MinDKPSpecial"]) then
                    for itemId in pairs(deserialized["MinDKPSpecial"]) do
                        PLDkpBidsOptions["MinDKPSpecial"][itemId] = deserialized["MinDKPSpecial"][itemId]
                    end
                end

                if(deserialized["MinDKPPerZone"]) then
                    for zoneName in pairs(deserialized["MinDKPPerZone"]) do
                        PLDkpBidsOptions["MinDKPPerZone"][zoneName] = deserialized["MinDKPPerZone"][zoneName]
                    end
                end

                PLDKP_println(string.Format(PLDKP_RECEIVED_OPTIONS, sender))
            else
                PLDKP_debug("Error deserializing: " .. deserialized)
                print(deserialized)  -- error reporting if string doesn't get deserialized correctly
            end
        end
    end
end

function PLDKPBids.Sync:BroadcastDkpSettings()
    if (PLDKPBids.IsOfficer) then
        PLDKP_debug("Broadcasting DKP settings in guild AddOn channel")
        -- send data
        PLDKPBids.Sync:SendData("PLDKPSettings", PLDkpBidsOptions)
    else
        PLDKP_debug("Broadcasting DKP settings not available. You need to be an officer!")
    end
end

function PLDKPBids.Sync:BroadcastDkpData()

    -- only send data if I am the highest officer online
    local doSend = true
    local rankIndex = PLDKPBids:GetGuildRankIndex(PLDKPBids.myName)
    local myVersion = tonumber(PLDKPBids.dkp_info.timestamp)

    for key, value in pairs(PLDKPBids.KnownVersions) do

        if value > myVersion then
            doSend = false
            PLDKP_debug("Cancel sending DKP data another player has a newer data version");
        elseif myVersion == value then
            -- there is another player who has the same version
            -- use a simple logic to elect who will send the data
            -- election alogirthm:
            --   sort by guild rank index ASC then by name ASC of online players of the guild
            --   first who match will send
            local otherName, otherRealm, otherServerName = PLDKPBids:CharaterNameTranslation(key)
            local otherRank = PLDKPBids:GetGuildRankIndex(otherName)

            if otherRank < rankIndex or (otherRank == rankIndex and otherName < PLDKPBids.myName and PLDKPBids:IsGuildPlayerOnline(otherName)) then
                doSend = false
                PLDKP_debug("Cancel sending DKP data because another officer with the same version is currently online and elected to send data");
            end
        end
    end

    if doSend == true then
        -- if I have a version higher than the requested
        local dkpData = {}
        dkpData.dkp_info = PLDKPBids.dkp_info
        dkpData.dkp_data = PLDKPBids.dkp_data

        PLDKP_debug("Broadcasting DKP data in guild AddOn channel")
        -- send data
        PLDKPBids.Sync:SendData("PLDKPDkpSync", dkpData)
    end
end

function PLDKPBids.Sync:VerifyAndRequestVersion(versionInfoReceived)
    if versionInfoReceived == nil then
        -- request any version
        PLDKPBids.Sync:SendData("PLDKPDkpVRequest", "0")
    else
        if PLDKPBids.MostRecentDkpVersion < versionInfoReceived then
            PLDKPBids.MostRecentDkpVersion = versionInfoReceived
            PLDKPBids.Sync:SendData("PLDKPDkpVRequest", tostring(versionInfoReceived))
        end
    end
end

function PLDKPBids.Sync:BroadCastLastWinnerData(raidId, winnerInfo)
    local winnerData = {}
    winnerData.raidId = raidId
    winnerData.data = winnerInfo

    -- send data
    PLDKPBids.Sync:SendData("PLDKPDkpWinner", winnerData)
end

function PLDKPBids.Sync:BroadCastEditLastWinnerData(raidId, winnerInfo)
    local winnerData = {}
    winnerData.raidId = raidId
    winnerData.data = winnerInfo

    -- send data
    PLDKPBids.Sync:SendData("PLDKPEdtWinner", winnerData)
end

function PLDKPBids.Sync:BroadCastDeleteLastWinnerData(raidId, winnerInfo)
    local winnerData = {}
    winnerData.raidId = raidId
    winnerData.data = winnerInfo

    -- send data
    PLDKPBids.Sync:SendData("PLDKPDelWinner", winnerData)
end

function PLDKPBids.Sync:SendData(prefix, data)
    PLDKPBids:CheckOfficer()

	if IsInGuild() then
        if prefix == "PLDKPBuildCheck" or prefix == "PLDKPDkpVersion" or prefix == "PLDKPDkpVRequest" then
            PLDKP_debug("Broadcasted " .. prefix)
			PLDKPBids.Sync:SendCommMessage(prefix, data, "GUILD")
			return;
		end
	end

    --if IsInGuild() and PLDKPBids.IsOfficer then
    if IsInGuild() then
		local serialized = nil;
		local packet = nil;
		local verInteg1 = false;
		local verInteg2 = false;

		if data then
			serialized = LibAceSerializer:Serialize(data);	-- serializes tables to a string
		end

		-- compress serialized string with both possible compressions for comparison
		-- I do both in case one of them doesn't retain integrity after decompression and decoding, the other is sent
		local huffmanCompressed = LibCompress:CompressHuffman(serialized);
		if huffmanCompressed then
			huffmanCompressed = LibCompressAddonEncodeTable:Encode(huffmanCompressed);
		end
		local lzwCompressed = LibCompress:CompressLZW(serialized);
		if lzwCompressed then
			lzwCompressed = LibCompressAddonEncodeTable:Encode(lzwCompressed);
		end

		-- Decode to test integrity
		local test1 = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(huffmanCompressed))
		if test1 == serialized then
			verInteg1 = true
		end
		local test2 = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(lzwCompressed))
		if test2 == serialized then
			verInteg2 = true
		end
		-- check which string with verified integrity is shortest. Huffman usually is
		if (strlen(huffmanCompressed) < strlen(lzwCompressed) and verInteg1 == true) then
			packet = huffmanCompressed;
		elseif (strlen(huffmanCompressed) > strlen(lzwCompressed) and verInteg2 == true) then
			packet = lzwCompressed
		elseif (strlen(huffmanCompressed) == strlen(lzwCompressed)) then
			if verInteg1 == true then packet = huffmanCompressed
			elseif verInteg2 == true then packet = lzwCompressed end
		end

		--debug lengths, uncomment to see string lengths of each uncompressed, Huffman and LZQ compressions
		--[[print("Uncompressed: ", strlen(serialized))
		print("Huffman: ", strlen(huffmanCompressed))
		print("LZQ: ", strlen(lzwCompressed)) --]]

        local channel = "GUILD"

        if prefix == "PLDKPDkpWinner" or prefix == "PLDKPDelWinner" or prefix == "PLDKPEdtWinner" or prefix == "PLMRTItemLoot" then
            if UnitInRaid("player") then
                channel = "RAID"
            elseif UnitInParty("player") then
                channel = "PARTY"
            end
        end

        PLDKP_debug("Sending packet using prefix '" .. prefix .. "' in channel '" ..  channel .. "' ...")
		PLDKPBids.Sync:SendCommMessage(prefix, packet, channel)

		--[[if prefix == "PLDKPBidsDataSync" then
			if core.UpToDate == true then
				PLDKPBids:UpdateSeeds()
			end
		end--]]

		-- Verify Send
		if (prefix == "PLDKPDkpSync") then
			PLDKP_debug("Broadcasted DKP data")
		end
	end
end