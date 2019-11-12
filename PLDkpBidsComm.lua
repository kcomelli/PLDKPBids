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
end

function PLDKPBids.Sync:OnCommReceived(prefix, message, distribution, sender)
    if (prefix) then
        if prefix == "PLDKPBuildCheck" and sender ~= UnitName("player") then
			local LastVerCheck = time() - PLDKPBids.LastVerCheck;

			if LastVerCheck > 1800 then   					-- limits the Out of Date message from firing more than every 30 minutes 
				PLDKPBids.LastVerCheck = time();
				if tonumber(message) > PLDKP_BUILD_NUMBER then
					PLDKP_screen(PLDKP_BUILD_OUTOFDATE)
				end
			end

			if tonumber(message) < PLDKP_BUILD_NUMBER then
				PLDKPBids.Sync:SendData("PLDKPBuildCheck", tostring(PLDKP_BUILD_NUMBER))
			end
			return;
        end
    elseif prefix == "PLDKPDkpVersion" and sender ~= UnitName("player") then
        -- save sender data
        PLDKPBids.KnownVersions[sender] = tonumber(message)
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
            if tonumber(PLDKPBids.dkp_info.timestamp) >= tonumber(message) and 
                PLDKPBids.MostRecentDkpVersion >= tonumber(message)  then
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

            PLDKP_screen(string.format(PLDKP_RECEIVED_NEW_DKPDATA, PLDKPBids.dkp_info.date))
            -- update help table since DKP data is available
            PLDKPBids:CreateHelpTable()

            -- resend version in order to update known versions of other clients
            PLDKPBids.Sync:SendData("PLDKPDkpVersion", PLDKPBids.dkp_info.timestamp)
        else
            print(deserialized)  -- error reporting if string doesn't get deserialized correctly
        end
    elseif prefix == "PLDKPDkpWinner" and sender ~= UnitName("player") then
        decoded = LibCompress:Decompress(LibCompressAddonEncodeTable:Decode(message))
        local success, deserialized = LibAceSerializer:Deserialize(decoded);
        if success then
            PLDKP_LastWinners[deserialized.raidId] = deserialized.data
            PLDKP_screen(string.format(PLDKP_RECEIVED_WINNER_INFO, (deserialized.data["Name"] or "na") .. " - " .. (deserialized.data["ItemLink"] or "na") .. " - " .. (deserialized.data["Price"] or "na") .. "DKP"))
        else
            print(deserialized)  -- error reporting if string doesn't get deserialized correctly
        end
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
                PLDKP_debug("Cancel sending DKP data because another officer with the same version is currently online and elected to send");
            end
        end
    end

    if doSend == true then
        -- if I have a version higher than the requested
        local dkpData = {}
        dkpData.dkp_info = PLDKPBids.dkp_info
        dkpData.dkp_data = PLDKPBids.dkp_data

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
    -- if I have a version higher than the requested
    local winnerData = {}
    winnerData.raidId = raidId
    winnerData.data = winnerInfo

    -- send data
    PLDKPBids.Sync:SendData("PLDKPDkpWinner", winnerData)
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

		PLDKPBids.Sync:SendCommMessage(prefix, packet, "GUILD")

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