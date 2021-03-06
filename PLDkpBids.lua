-------------------------------------------------------------------------------
-- PL DKP Bids
--
-- Author: Fuddler/Gimmeurgold - Primal Legion @ Destromath-EU
-- Version: 3.1
-- 
-------------------------------------------------------------------------------

local _, PLDKPBids = ...

-- Bid flags and current values
local _pldkp_bidRunning = false;
local _pldkp_acceptBids = false;
local _pldkp_currentMinBid = PLDKP_DEFAULT_MIN_BID;
local _pldkp_currentBidTime = PLDKP_MINIMUM_BID_TIME;
local _pldkp_currentItem = "";
local _pldkp_currentItemTexture = "";
local _pldkp_lastWinner = "";
local _pldkp_timeEnd = nil;
local _selectedTab = 1;
local _elapsed = 0;
local _whisperingMyself = false;

-- after player entering world, the realm name will be set
PLDKPBids.localRealm = PLDKPBids.localRealm or ""
-- after player entering world, the player name will be set
PLDKPBids.myName, PLDKPBids.myRealm, PLDKPBids.myServerName = ""

-- will reference dkp data object
PLDKPBids.dkp_data = PLDKPBids.dkp_data or nil
-- will reference dkp info object
PLDKPBids.dkp_info = PLDKPBids.dkp_info or nil


-- Groupstatus flag
-- N ... not in a group
-- R ... in a raidgrp
-- P ... in a party
local _grpStatus = "N";

-- Version 2
PLDKP_VS2 = string.find(GetBuildInfo(), "^2%.");
-- Version 3
PLDKP_VS3 = string.find(GetBuildInfo(), "^3%.");
-- WoW Classic
PLDKP_CLASSIC = string.find(GetBuildInfo(), "^1.13%.");

-- print state messages
PLDKP_PrintAll = true;

-- print errors
PLDKP_PrintError = true;

-- variables / AddOn loaded
PLDKP_Loaded = false;

-- Table for help view
PLDKP_HelpTable = {};

-- Table for scheduled actions
PLDKP_ScheduledActions = { };

-- Arrays for storing Bids
PLDKP_CurrentBids = {};

-- Temporary whisper buffer
PLDKP_OutBuffer = {}
PLDKP_InBuffer = {}

-- Twink translation table
PLDKP_TwinktranslationTable = {}

PLDKP_CurrentDate = nil;
PLDKP_CurrentZone = "";
PLDKP_CurrentRaidSize = 0;
PLDKP_CurrentRaidMode = "N"; -- N ... normal, H ... heroic
PLDKP_CurrentRaidID = "";

PLDKP_AllowTwinkBids = true;
PLDKP_CurItemIsSetToken = false;

PLDKP_WinnerNote = "";
PLDKP_WinnerNoteKey = "";

-- Function hooks
PLDKP_Saved_LootFrameItem_OnClick = nil;
PLDKP_Saved_ChatFrame_OnEvent = nil;

---------------------------------------------------------------------
-- event handlersand hooks MAINFRAME
---------------------------------------------------------------------
---------------------------------------------------------------------
-- function PLDkpBidsFrame_OnLoad()
--
-- Called when the Mod-Frame is loaded
--
-- Initializes the AddOn and registers for common events
---------------------------------------------------------------------
function PLDkpBidsFrame_OnLoad()
	
	SlashCmdList["PLDkpBids"] = PLDkpBidsFrame_OnCommand;
	SLASH_PLDkpBids1 = "/pldkp";
	
	_elapsed = 0;
	
	PLDkpBidsFrame:RegisterEvent("VARIABLES_LOADED");
	PLDkpBidsFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	PLDkpBidsFrame:RegisterEvent("CHAT_MSG_WHISPER");
	
	if ( PLDKP_VS2) then
		-- Version 2.0
		PLDKP_Saved_OnButtonClick = LootButton_OnClick;
		LootButton_OnClick = PLDKP_LootFrameItem_OnButtonClick;

		PLDKP_Saved_OnModifiedClick = LootButton_OnModifiedClick;
		LootButton_OnModifiedClick = PLDKP_LootFrameItem_OnModifiedClick;
	elseif ( PLDKP_VS3 ) then
		-- Lootwindow hook - OnClick on Item
		PLDKP_Saved_LootFrameItem_OnClick = LootFrameItem_OnClick;
		LootFrameItem_OnClick = PLDKP_LootFrameItem_OnClick;
	elseif( PLDKP_CLASSIC ) then
		PLDKP_Register_ShiftClickLootWindowHook()
	else
		PLDKP_debug("Unknown or unsupported WoW version!")
	end

	-- Chatframe hook
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", PLDKP_ChatFrame_OnWhisperIncoming)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", PLDKP_ChatFrame_OnWhisperOutgoing)
	
	PLDKP_InBuffer = {};
	PLDKP_OutBuffer = {};
end

function PLDKP_Register_ShiftClickLootWindowHook()
    --== For blizzard loot window ==--
	for i = 1, 20 do 
		lootButton = getglobal("LootButton"..i)
		if(lootButton ~= nil) then
			local oldClick = lootButton:GetScript("OnClick")
			lootButton:SetScript("OnClick", function(self, button, down) 
				if ( IsShiftKeyDown() ) then 
					PLDKP_LootFrameItem_OnButtonClick(self, button)
				end
				oldClick(self, button, down)
			end)
		else
			i = 21
		end
    end
end


---------------------------------------------------------------------
-- function PLDKP_HookHyperlinkClick()
--
-- Call this to hook hyperlink clicks
-- Info: Called after receiving VARIABLES_LOADED event
---------------------------------------------------------------------
function PLDKP_HookHyperlinkClick()
	-- hook click on itemlink
	PLDKP_Saved_OnHyperlinkClick = ChatFrame1:GetScript("OnHyperlinkClick");
	ChatFrame1:SetScript("OnHyperlinkClick", PLDKP_ItemLinkClick);

	for i = 2, 15 do
		if (getglobal("ChatFrame"..i)) then
			local cf = getglobal("ChatFrame"..i);
			cf:SetScript("OnHyperlinkClick", PLDKP_ItemLinkClick);
		end			
	end
end

---------------------------------------------------------------------
-- function PLDKP_ItemLinkClick()
--
-- Called if the user clicks an hyperlink (itemlink)
---------------------------------------------------------------------
function PLDKP_ItemLinkClick(chatframe, linktype, data, button)
	--PLDKP_debug("on clicked itemlink " .. button);
	
	
--	if ((PLDkpBidsOptions ~= nil) and (PLDkpBidsOptions["DebugMode"])) then
--		for txt in pairs(chatframe) do
--			PLDKP_debug("Txt: " .. tostring(txt) .." = " .. tostring(chatframe[txt]));
--		end
--
--		if ( linktype ~= nil ) then
--			PLDKP_debug("linktype = " .. linktype);
--		else
--			PLDKP_debug("linktype = nil");
--		end
--
--		if ( data ~= nil ) then
--			PLDKP_debug("data = " .. data);
--		else
--			PLDKP_debug("data = nil");
--		end
--
--		if ( button ~= nil ) then
--			PLDKP_debug("button = " .. button);
--		else
--			PLDKP_debug("button = nil");
--		end
--		
--		if ( arg5 ~= nil ) then
--			PLDKP_debug("arg5 = " .. arg5);
--		else
--			PLDKP_debug("arg5 = nil");
--		end
--
--		if ( IsShiftKeyDown() ) then
--			PLDKP_debug("Shift-Key down");
--		end
--	end

	-- if the linktype is an itemlink
	-- and the right mousbutton was used
	-- and the shift key
	-- take this itemlink and open it in the pldkp window
	if ( string.find(linktype, "^item:") and (button == "RightButton") and IsShiftKeyDown() ) then
		
	
		_grpStatus = PLDKP_GetMyGroupStatus();

		if(_grpStatus == "N") then
			-- not in a grp, can not make auctions !
			PLDKP_errln(PLDKP_ERROR_NOTGROUPED);
			return;
		end
				
		gitemName, gitemLink, gitemRarity, gitemLevel, gitemMinLevel, gitemType, gitemSubType, gitemStackCount, gitemEquipLoc, gitemTexture = GetItemInfo(linktype);
		
		PLDKPBidsFrame_CheckIfItemIsSetToken(data);
		if( PLDKP_CurItemIsSetToken ) then
			PLDKP_AllowTwinkBids = false;
		else
			PLDKP_AllowTwinkBids = true;
		end
		
		_pldkp_currentItem = data;
		_pldkp_currentItemTexture = gitemTexture;
		PLDKPForm_ShowAuctionInfo();
		PLDkpBidsFrame_SetVisible(true);
	else
		PLDKP_Saved_OnHyperlinkClick(chatframe, linktype, data, button);
	end

end

---------------------------------------------------------------------
-- function PLDKP_LootFrameItem_OnModifiedClick()
--
-- Called when a user clicks on an item in the loot window
---------------------------------------------------------------------
function PLDKP_LootFrameItem_OnModifiedClick(self, button)
	--PLDKP_debug("on modified click: " .. button);
	
	if ( button == "RightButton" ) then
		PLDKP_LootFrameItem_OnClick(self, button)
	end
	
	if(PLDKP_Saved_OnModifiedClick ~= nil) then
		PLDKP_Saved_OnModifiedClick(self, button);
	end	
end

---------------------------------------------------------------------
-- function PLDKP_LootFrameItem_OnButtonClick()
--
-- Called when a user clicks on an item in the loot window
---------------------------------------------------------------------
function PLDKP_LootFrameItem_OnButtonClick(self, button)
	--PLDKP_debug("on button click: " .. button);
	
	if ( button == "RightButton" ) then
		PLDKP_LootFrameItem_OnClick(self, button)
	end
	if(PLDKP_Saved_OnButtonClick ~= nil) then
		PLDKP_Saved_OnButtonClick(self, button);
	end
end

---------------------------------------------------------------------
-- function PLDKP_LootFrameItem_OnClick()
--
-- Called when a user clicks on an item in the loot window
---------------------------------------------------------------------
function PLDKP_LootFrameItem_OnClick(self, button)
	--PLDKP_debug("Looframe button click: " .. button);
	
	if ( button == "RightButton" ) then
		if ( IsShiftKeyDown() ) then
			PLDKP_debug("Shift-Key down");
			
			local index = self:GetID();
			local slot = PLDKP_LootFrameItem_Slot(index);
			local texture;
			local item;
			local quantity;
			local rarity;
			local itemlink;
			texture, item, quantity, rarity = GetLootSlotInfo(slot);
			itemlink = GetLootSlotLink(slot);
			
			
			--if ( PLDkpBidsOptions["IgnoreBidsOutsideGrp"] == true ) then
				_grpStatus = PLDKP_GetMyGroupStatus();

				if(_grpStatus == "N") then
					-- not in a grp, can not make auctions !
					PLDKP_errln(PLDKP_ERROR_NOTGROUPED);
					return;
				end
			--end
	
			PLDKPBidsFrame_CheckIfItemIsSetToken(itemlink);
			if( PLDKP_CurItemIsSetToken ) then
				PLDKP_AllowTwinkBids = false;
			else
				PLDKP_AllowTwinkBids = true;
			end
	
			LootFrame:Hide();
			
			_pldkp_currentItem = itemlink;
			_pldkp_currentItemTexture = texture;
			PLDKPForm_ShowAuctionInfo();
			PLDkpBidsFrame_SetVisible(true);
		end
	else
		if(PLDKP_Saved_LootFrameItem_OnClick ~= nil) then
			PLDKP_Saved_LootFrameItem_OnClick(button);
		end
	end
end

---------------------------------------------------------------------
-- function PLDKP_LootFrameItem_Slot(index)
--
-- Gets the item of the lootframe with the specified index
---------------------------------------------------------------------
function PLDKP_LootFrameItem_Slot(index)
	local numLootItems = LootFrame.numLootItems;
	--Logic to determine how many items to show per page
	local numLootToShow = LOOTFRAME_NUMBUTTONS;
	if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
		numLootToShow = numLootToShow - 1;
	end
	local slot = (numLootToShow * (LootFrame.page - 1)) + index;
	return slot;
end


---------------------------------------------------------------------
-- function PLDKP_ChatFrame_OnWhisperIncoming()
--
-- Called when an incoming chat event occurs
---------------------------------------------------------------------
function PLDKP_ChatFrame_OnWhisperIncoming(chatFrame, event, arg1, arg2)
	if(_whisperingMyself) then
		-- we are processing a whisper message we recently sended
		-- via this addon's PLDKP_sendWhisper() function to our own character
		_whisperingMyself = false;
		return false;
	end

	if (arg1 and arg2) then		
		if( PLDKP_InBuffer[arg2]==nil or PLDKP_InBuffer[arg2] ~= arg1) then
			PLDKP_debug("in-msg: " .. arg1);
			PLDKP_debug("in-player: " .. arg2);

			-- incoming whisper
			if ((string.find(arg1,"^** PLDKP: ")) and (arg2 == PLDKPBids:GetPlayerName("player"))) then
				PLDKP_InBuffer[arg2] = arg1;
				PLDKP_debug("1 filter incoming whisper...");
				return true;
			end

			if (PLDKP_processWhisper(arg2,arg1)) then
				PLDKP_InBuffer[arg2] = arg1;
				PLDKP_debug("2 filter incoming whisper...");
				return true;
			end
		else
			if ( PLDKP_InBuffer[arg2] and PLDKP_InBuffer[arg2] == arg1) then
				return true;
			end
		end
	end
end

---------------------------------------------------------------------
-- function PLDKP_ChatFrame_OnWhisperOutgoing()
--
-- Called when an outgoing chat event occurs
---------------------------------------------------------------------
function PLDKP_ChatFrame_OnWhisperOutgoing(chatFrame, event, arg1, arg2)

	if (arg1 and arg2) then
		if( PLDKP_OutBuffer[arg2]==nil or PLDKP_OutBuffer[arg2] ~= arg1) then
			
			PLDKP_debug("out-msg: " .. arg1);
			PLDKP_debug("out-player: " .. arg2);
	
			
			if (string.find(arg1,"^** PLDKP: ")) then
				PLDKP_OutBuffer[arg2] = arg1;
				PLDKP_debug("filter outgoing whisper...");
				return true;
			end
		else
			if ( PLDKP_OutBuffer[arg2] and PLDKP_OutBuffer[arg2] == arg1) then
				return true;
			end
		end
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_OnEvent(event)
--
-- Default eventhandler for the AddOn
--
-- Handels events for all Mods
---------------------------------------------------------------------
function PLDkpBidsFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD" ) then
		PLDKP_println(PLDKP_WelcomeMessage)

		PLDKPBids.localRealm = GetRealmName()
		PLDKPBids.myName, PLDKPBids.myRealm, PLDKPBids.myServerName = PLDKPBids:CharaterNameTranslation(UnitName("player"))

		if(not PLDKP_Loaded) then
			PLDKP_debug("PLDKP_Loaded=false"); 
			return;
		end
	end

	if (event == "VARIABLES_LOADED") then
		
		PLDkpBids_InitOptions();

		PLDKP_debug("OnEvent fired (loaded): "..event);

		PLDKP_HookHyperlinkClick();
	
		PLDKP_Loaded=true;
		
		if ( PLDKP_LastWinners == nil ) then
			PLDKP_LastWinners = {};
		end
		
		-- create help table
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text0);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text1);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text2);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text3);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text4);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text5);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text6);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text7);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text8);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text9);
		table.insert(PLDKP_HelpTable, PLDKP_Help_Text10);
		
		-- dkp plugin
		PLDKPBids:PLDKP_CheckGetDkp()
		if PLDkpBidsOptions["EnableMRTIntegration"] then
			-- check MRT integration
			if PLDKPBids:PLDKP_RegisterWithMRT() then
				--table.insert(PLDKP_HelpTable, PLDKP_Help_TextMRT);
			end
		end

		table.insert(PLDKP_HelpTable, PLDKP_Help_TextEND);
		
		_pldkp_currentMinBid = PLDkpBidsOptions["DefaultMinDKP"];
		_pldkp_currentBidTime = PLDkpBidsOptions["DefBidTSpan"];
		
		-- check if the LastWinners table has the 3.0 format
		for sRaidID in PLDKPBids:pairsByKeys(PLDKP_LastWinners, PLDKPBids_compareDesc) do 
			if(PLDKP_LastWinners[sRaidID]["RaidID"] == nil) then
				PLDKP_LastWinners = {};
				PLDKP_println(PLDKP_WINNERS_CLEARD_OLDVER);
				break;
			end
		end
	end
end

---------------------------------------------------------------------
-- function PLDKPBids_compareDesc(arg1, arg2)
--
-- Returns true if arg1 > arg2
---------------------------------------------------------------------
local function PLDKPBids_compareDesc(arg1, arg2)
	return (arg1 > arg2);
end

---------------------------------------------------------------------
-- function PLDKPBidsFrame_CheckIfItemIsSetToken(data)
--
-- checks if the item is a set token
---------------------------------------------------------------------
function PLDKPBidsFrame_CheckIfItemIsSetToken(data)

	PLDKP_CurItemIsSetToken = false;
	
	_,_, itemId = string.find(data, "item:(%d+):");
	g1itemName, g1itemLink, g1itemRarity, g1itemLevel, g1itemMinLevel, g1itemType, g1itemSubType, g1itemStackCount, g1itemEquipLoc, g1itemTexture = GetItemInfo("item:" .. itemId);
	
	if( g1itemRarity == 4 ) then  -- epic item
		if( g1itemMinLevel == g1itemLevel ) then -- item level and min level are equal for tokens
			if( (g1itemType=="Miscellaneous") and ( g1itemSubType == "Junk") ) then -- token type
				if( g1itemStackCount == 1 ) then  -- stack count = 1
					if( g1itemEquipLoc == "") then  -- location = empty
						PLDKP_CurItemIsSetToken = true;
					end
				end
			end
		end
	end
	
	if( PLDKP_CurItemIsSetToken ) then
		PLDKP_info(string.format(PLDKP_ITEM_TOKENINFO, data));
	end
	
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_GenerateTwinktranslationTable()
--
-- Reads the guild list and creates an mainchar - twink table
---------------------------------------------------------------------
function PLDkpBidsFrame_GenerateTwinktranslationTable()
	local nrOfGuildMember = 0;
	local bIsTwink = false;
	local mainName = "";
	
	if(table.getn(PLDKP_TwinktranslationTable) >= 1) then
		PLDKP_debug("Skip generating twink translation table because it already exists.")
	end

	if IsInGuild() then
		
		nrOfGuildMember = GetNumGuildMembers(true);
		
		for i = 1, nrOfGuildMember do
			bIsTwink = false;
			nname, nrank, nrankIndex, nlevel, nclass, nzone, nnote, nofficernote, nonline, nstatus = GetGuildRosterInfo(i);
			
			if( (nrank == "Twink") or (nrank == "Orga Twink") or (nrank == "Orga-Twink") ) then
				bIsTwink = true;
			else
				if( string.find(nnote, "aka") ~= nil) then
					bIsTwink = true;
				end
			end
			
			mainName = nname;
			
			if (bIsTwink) then
				
				startPos, endPos, firstWord, restOfString = string.find( nnote, "(%S+)[%s]*(.*)");
				
				if (restOfString == nil) or (firstWord == nil) then
					
					mainName = "UNBEKANNT";
					
				else
				
				
					mainName = firstWord;

					if (restOfString ~= nil) then
						startPos1, endPos1, mainCharName, restOfString1 = string.find( restOfString, "(%S+)[%s]*(.*)");

					
						mainName = mainCharName;
					end
				end
				
			end
			
			transName, transRealm, transServerName = PLDKPBids:CharaterNameTranslation(nname)

			PLDKP_TwinktranslationTable[transName] = mainName;
			PLDKP_TwinktranslationTable[transServerName] = mainName;
			
			PLDKP_debug( "" .. i .. ": " .. nname .. " (" .. nrank .. "): " .. nnote .. " (" .. nofficernote ..")") ;
		end 
	end
end


---------------------------------------------------------------------
-- function PLDkpBidsFrame_GetMainCharOfTwink(characterName)
--
-- Returns the name of the main character for a given character name 
---------------------------------------------------------------------
function PLDkpBidsFrame_GetMainCharOfTwink(characterName)
	local nameToCheck = characterName

	if( PLDKP_TwinktranslationTable[nameToCheck] ~= nil) then
		if( PLDKP_TwinktranslationTable[nameToCheck] ~= nameToCheck ) then
			return PLDKP_TwinktranslationTable[nameToCheck];
		end
	end

	-- check with realm name aswell
	nameToCheck = nameToCheck .. "-" .. _pldkp_localRealm

	if( PLDKP_TwinktranslationTable[nameToCheck] ~= nil) then
		if( PLDKP_TwinktranslationTable[nameToCheck] ~= nameToCheck ) then
			return PLDKP_TwinktranslationTable[nameToCheck];
		end
	end
	
	return characterName;
	
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_GenerateID()
--
-- Generates a unique raid ID which includes
--  the current date
--  the current raid size (5, 10, 25, 40)
--  the current difficulty level (N(ormal), H(eroic), E(pic))
--  the current zone text
---------------------------------------------------------------------
function PLDkpBidsFrame_GenerateID()
	local numRaidMembers = 0;
	local curDate = date("*t");
	local tempDate = date("*t")
	local difficulty = 1; -- Normal is default
	local tmp = "";
	

	if( PLDKP_VS2 or PLDKP_VS3 ) then
		difficulty = GetInstanceDifficulty()
	end

	-- gets the current zone name
	PLDKP_CurrentZone = GetRealZoneText();
	
	-- get raid size
	if ( UnitInRaid("player") ) then
		
		-- player is in a raid group
		-- normalize raid group size
		numRaidMembers = GetNumGroupMembers();
		
		if( (numRaidMembers <= 15) ) then
			PLDKP_CurrentRaidSize = 10;
		elseif ( (numRaidMembers > 15) and (numRaidMembers <= 30) ) then
			PLDKP_CurrentRaidSize = 25;
		else
			PLDKP_CurrentRaidSize = 40;
		end
		
	elseif ( (UnitInParty("player")) and (GetNumGroupMembers() > 0) ) then
		
		-- player is in normal group, set raid size to 5
		PLDKP_CurrentRaidSize = 5;
		
	end
	
	
	tempDate["hour"], tempDate["min"] = GetGameTime()
	
	if( (tempDate["hour"] >= 0) and (tempDate["hour"] <= 3) ) then
		curDate["day"] = (curDate["day"]-1);
	end
	
	PLDKP_CurrentDate = curDate["year"];
	
	tmp = tostring(curDate["month"]);
	if(strlen(tmp)<2) then
	   tmp = "0"..tmp;
	end
	  
	PLDKP_CurrentDate = PLDKP_CurrentDate .. tmp;
	
	tmp = tostring(curDate["day"]);
		if(strlen(tmp)<2) then
		   tmp = "0"..tmp;
		end
		  
	PLDKP_CurrentDate = PLDKP_CurrentDate .. tmp;
	
	
	if( difficulty == 1) then
		PLDKP_CurrentRaidMode = "N";
	elseif (difficulty == 2) then
		PLDKP_CurrentRaidMode = "H";
	elseif (difficulty == 3) then
		PLDKP_CurrentRaidMode = "E";
	else
		PLDKP_CurrentRaidMode = "N";
	end
	
	PLDKP_CurrentRaidID = PLDKP_CurrentDate .."|" .. PLDKP_CurrentRaidSize .. "|" .. PLDKP_CurrentRaidMode .. "|" .. PLDKP_CurrentZone;
	
end



---------------------------------------------------------------------
-- function PLDkpBidsFrame_OnUpdate(self, elapsed)
--
-- Eventhandler for the OnUpdate-Event
--
-- Called at periodic times. Used for UI-updates and timing issues
---------------------------------------------------------------------
function PLDkpBidsFrame_OnUpdate(self, elapsed)

	if (_pldkp_bidRunning == false) then
		return;
	end

	if(elapsed) then
		-- handle sheduled functions	
		_elapsed = _elapsed + elapsed;

		if ( _elapsed >= 0.1 ) then
			_elapsed = _elapsed - 0.1;
			local currTime = GetTime();
			
			if ( _selectedTab == 1 ) then
				local remain = _pldkp_timeEnd - GetTime();
				PLDKPFormAuctionTimeRemainingNRLabel:SetText(ceil(remain));
			end
		
			for k, v in pairs(PLDKP_ScheduledActions) do
				if ( currTime >= v[2] ) then
					tremove(PLDKP_ScheduledActions, k);
					if ( type(v[1]) == "function" ) then
						v[1](v[3]);
					else
						getglobal(v[1])(v[3]);
					end
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_OnCommand(msg)
--
-- Eventhandler for the slash-commands
--
-- Called if the user enters the AddOn's slash command
---------------------------------------------------------------------
function PLDkpBidsFrame_OnCommand(msg)
	local index, value;
	local showhelp = false;
	
	if (not msg or msg == "") then --Show Help
		showhelp = true;
		PLDKP_debug("Requesting help (no params)");
	else
		local command;
		local args;

		args = PLDKP_ParseArguments(msg);

		if (args[1] ~= nil) then
			command = string.lower(args[1]);
		end


		if (command == PLDKP_Command_Help) then
			showhelp = true;
			PLDKP_debug("Requesting help (param)");

		elseif (command == PLDKP_Command_Start) then
			PLDKP_StartBidding(args);

		elseif (command == PLDKP_Command_Set) then
			PLDKP_SetOptionVal(args)

		elseif (command == PLDKP_Command_Reset) then
			PLDKP_ResetBid();
			
		elseif (command == PLDKP_Command_ResetMod) then
			PLDKP_ResetMod();
			
		elseif (command == PLDKP_Command_Show) then
			PLDkpBidsFrame_SetVisible(true);
			
		elseif (command == PLDKP_Command_ClearWinners) then
			PLDKP_LastWinners = {};
			PLDKP_println(PLDKP_WINNERS_CLEARED);
			
		elseif (command == PLDKP_Command_Hide) then
			PLDkpBidsFrame_SetVisible(false);
			
		elseif (command == "note" ) then
			ShowUIPanel(PLDkpBidsNoteFrame);
			
		elseif (command == "showoptions" ) then
			if ( PLDkpBidsOptions == nil) then
				PLDKP_debug("PLDkpBidsOptions = nil");
			else
				for optName in pairs(PLDkpBidsOptions) do
					PLDKP_debug(optName.." = " .. tostring(PLDkpBidsOptions[optName]));
				end
			end
		elseif (command == PLDKP_Command_GetMain ) then
			PLDkpBidsFrame_GenerateTwinktranslationTable();
			
			if( args[2] ~= nil) then
			
				if( PLDKP_TwinktranslationTable[ args[2] ] ~= nil) then
					if( PLDKP_TwinktranslationTable[ args[2] ] == args[2] ) then
						PLDKP_println(string.format(PLDKP_TWINKINFO_MAINCHAR, args[2]));
					else
						PLDKP_println(string.format(PLDKP_TWINKINFO_TWINKOF, args[2], PLDKP_TwinktranslationTable[ args[2] ]));
					end
				else
					PLDKP_println(string.format(PLDKP_TWINKINFO_NOTFOUND, args[2]));
				end
			else
				PLDKP_println(PLDKP_TWINKINFO_ERRORNAME);
			end
			
		elseif (command == "test" ) then
			PLDKP_println("PLDKP: test command ...");
			PLDkpBidsFrame_GenerateTwinktranslationTable();
		end
	end

	if(showhelp) then
		PLDKP_ShowSlashHelp();
	end
end

---------------------------------------------------------------------
-- Bid functions
---------------------------------------------------------------------
---------------------------------------------------------------------
-- function PLDKP_StartBidding(args)
--
-- start bidding ( entered on console )
---------------------------------------------------------------------
function PLDKP_StartBidding(args)
	local playerName = PLDKPBids:GetPlayerName("player");

	--if ( PLDkpBidsOptions["IgnoreBidsOutsideGrp"] == true ) then
		_grpStatus = PLDKP_GetMyGroupStatus();

		if(_grpStatus == "N") then
			-- not in a grp, can not make auctions !
			PLDKP_errln(PLDKP_ERROR_NOTGROUPED);
			return;
		end
	--end
	
			
	if (args[2] ~= nil) then
		local minBidIndex = 3;
		local sItem = args[2];
		local bfound=false;
		local sItemTexture = "";
		
		_pldkp_currentBidTime = PLDkpBidsOptions["DefBidTSpan"];
		_pldkp_currentMinBid = PLDkpBidsOptions["DefaultMinDKP"];
		
		-- item link
		if ( string.find(args[2], "\|c")) then
			sItem = "";
			
			for i = 2, table.getn(args) do
				
				if ( bfound == false) then
					minBidIndex = i+1;
					sItem = sItem .. " " .. args[i];

					if ( string.find(args[i], "\|h\|r")) then
						bfound = true;
					end	
				end
			end
		else
			PLDKP_errln(PLDKP_ERROR_NOITEMLINK);
			return;
		end
		
		-- get item texture
		_,_, itemId = string.find(sItem, "item:(%d+):");
		if ( itemId ~= nil ) then	
			gitemName, gitemLink, gitemRarity, gitemLevel, gitemMinLevel, gitemType, gitemSubType, gitemStackCount, gitemEquipLoc, gitemTexture = GetItemInfo("item:"..itemId);
			sItemTexture = gitemTexture;
		end
		
		if( (args[minBidIndex] ~= nil) and ((string.lower(args[minBidIndex])=="true") or (string.lower(args[minBidIndex])=="false") or (string.lower(args[minBidIndex])=="ja") or (string.lower(args[minBidIndex])=="nein") or (string.lower(args[minBidIndex])=="yes") or (string.lower(args[minBidIndex])=="no") or (string.lower(args[minBidIndex])=="wahr") or (string.lower(args[minBidIndex])=="falsch")) ) then
			minBidIndex = minBidIndex + 1;
			
			if((string.lower(args[minBidIndex])=="true") or (string.lower(args[minBidIndex])=="ja") or (string.lower(args[minBidIndex])=="yes") or (string.lower(args[minBidIndex])=="wahr")) then
				PLDKP_AllowTwinkBids = true;
			else
				PLDKP_AllowTwinkBids = false;
			end
		end
		
		if ((args[minBidIndex] ~= nil) and (tonumber(args[minBidIndex]) ~= nil ))  then
			_pldkp_currentMinBid = tonumber(args[minBidIndex]);
		end
		
		if ((args[minBidIndex+1] ~= nil) and (tonumber(args[minBidIndex+1]) ~= nil ))  then
			_pldkp_currentBidTime = tonumber(args[minBidIndex+1]);
		end
		
		_pldkp_timeEnd = GetTime()+_pldkp_currentBidTime;
	
		PLDKP_StartAuction(sItem, sItemTexture, _pldkp_currentMinBid, _pldkp_currentBidTime);
	end
end

---------------------------------------------------------------------
-- function PLDKP_StartAuction(itemLink, itemTexture, minPrice, sec)
--
-- starts the auction for the item
---------------------------------------------------------------------
function PLDKP_StartAuction(itemLink, itemTexture, minPrice, sec)
	local playerName = PLDKPBids:GetPlayerName("player");

	-- always recreate this table before start an auction
	PLDKP_TwinktranslationTable = {}

	-- Generate twink table
	PLDkpBidsFrame_GenerateTwinktranslationTable();
	
	-- generate raid id
	PLDkpBidsFrame_GenerateID();
	
	PLDKP_InBuffer = {};
	PLDKP_OutBuffer = {};
	PLDKP_CurrentBids = {};
	_pldkp_currentBidTime = sec;
	_pldkp_currentMinBid = minPrice;
	_pldkp_currentItem = itemLink;
	_pldkp_currentItemTexture = itemTexture;

	SendChatMessage(PLDKP_BID_OPENING1, PLDKP_GetAnnounceChannel());
	SendChatMessage(string.format(PLDKP_BID_OPENING2, _pldkp_currentBidTime), PLDKP_GetAnnounceChannel());
	
	if(PLDKP_AllowTwinkBids) then
		SendChatMessage(PLDKP_BID_OPENING5, PLDKP_GetAnnounceChannel());
	else
		SendChatMessage(PLDKP_BID_OPENING6, PLDKP_GetAnnounceChannel());
	end
	
	SendChatMessage(string.format(PLDKP_BID_OPENING3, itemLink), PLDKP_GetAnnounceChannel());
	SendChatMessage(string.format(PLDKP_BID_OPENING4, playerName, _pldkp_currentMinBid), PLDKP_GetAnnounceChannel());

	if ( _pldkp_currentBidTime > 20) then
		PLDkpBidsFrame_Schedule("PLDKP_Warnings", _pldkp_currentBidTime-20, "20secWarning");
	end

	if ( _pldkp_currentBidTime > 10) then
		PLDkpBidsFrame_Schedule("PLDKP_Warnings", _pldkp_currentBidTime-10, "10secWarning");
	end

	if ( _pldkp_currentBidTime > 5) then
		PLDkpBidsFrame_Schedule("PLDKP_Warnings", _pldkp_currentBidTime-5, "5secWarning");
	end

	PLDkpBidsFrame_Schedule("PLDKP_Warnings", _pldkp_currentBidTime, "endofBids");

	_pldkp_bidRunning = true;
	_pldkp_acceptBids = true;
	
	PLDKPForm_ShowAuctionInfo();
		
end

---------------------------------------------------------------------
-- function PLDKP_SetOptionVal(args)
--
-- sets the value of an option flag
---------------------------------------------------------------------
function PLDKP_SetOptionVal(args)
	
	if (args[2] ~= nil) then
		local newval;
		local optname;
		local i2;
		i2 = string.find(args[2], "=");
		
		if (i2) then
			optname = string.sub(args[2], 0, i2-1);
			newval = string.sub(args[2], i2+1);
			PLDkpBidsOptions[optname] = newval;
			
			PLDKP_println(string.format(PLDKP_OPTION_SET, optname, newval));
		else
			PLDKP_errln(PLDKP_ERROR_OPTIONPARAM);
		end
	else
		PLDKP_errln(PLDKP_ERROR_OPTIONPARAM);
	end
end

---------------------------------------------------------------------
-- function PLDKP_ResetBid(args)
--
-- resets the current auction
---------------------------------------------------------------------
function PLDKP_ResetBid(args)
	if(_pldkp_bidRunning) then
		SendChatMessage(PLDKP_BID_ABORTED, PLDKP_GetAnnounceChannel());
	end
	
	_pldkp_bidRunning = false;
	_pldkp_acceptBids = false;
	_pldkp_timeEnd=nil;
	
	PLDkpBidsFrame_UnSchedule("PLDKP_Warnings");
	
	PLDKP_CurrentBids = {};
	PLDKP_InBuffer = {};
	PLDKP_OutBuffer = {};
	--_pldkp_currentItem = "";
end

---------------------------------------------------------------------
-- function PLDKP_ResetMod()
--
-- resets the mod to default values
---------------------------------------------------------------------
function PLDKP_ResetMod()
	PLDkpBidsOptions = {};
	PLDkpBidsOptions["DefaultMinDKP"] = _pldkp_currentMinBid;
	PLDkpBidsOptions["DefBidTSpan"] = _pldkp_currentBidTime;
	PLDkpBidsOptions["AnnounceChannel"] = "AUTO";
	
	PLDkpBidsFrame_UnSchedule("PLDKP_Warnings");
	
	if(_pldkp_bidRunning) then
		SendChatMessage(PLDKP_BID_ABORTED, PLDKP_GetAnnounceChannel());
	end
	
	_pldkp_bidRunning = false;
	_pldkp_acceptBids = false;
	PLDKP_CurrentBids = {};
	_pldkp_currentItem = "";
end

---------------------------------------------------------------------
-- function PLDKP_Warnings(event)
--
-- display timed warnings
---------------------------------------------------------------------
function PLDKP_Warnings(event)

	if ( event == "20secWarning" ) then
		if ( (PLDkpBidsOptions["ShowCountDownInRaidWarning"] == true) and (PLDKP_GetMyGroupStatus() == "R") ) then
			--SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 20), PLDKP_GetAnnounceChannel());
			SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 20), "RAID_WARNING");
		else
			SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 20), PLDKP_GetAnnounceChannel());
		end
	end
	
	if ( event == "10secWarning" ) then
		if ( (PLDkpBidsOptions["ShowCountDownInRaidWarning"] == true) and (PLDKP_GetMyGroupStatus() == "R") ) then
			--SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 10), PLDKP_GetAnnounceChannel());
			SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 10), "RAID_WARNING");
		else		
			SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 10), PLDKP_GetAnnounceChannel());
		end
	end
	
	if ( event == "5secWarning" ) then
		if ( (PLDkpBidsOptions["ShowCountDownInRaidWarning"] == true) and (PLDKP_GetMyGroupStatus() == "R") ) then
			--SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 5), PLDKP_GetAnnounceChannel());
			SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 5), "RAID_WARNING");
		else		
			SendChatMessage(string.format(PLDKP_BID_CLOSING_INFO, 5), PLDKP_GetAnnounceChannel());
		end
	end
	
	if ( event == "endofBids" ) then
		PLDKP_EndOfBids();
	end
end

---------------------------------------------------------------------
-- function PLDKP_EndOfBids(event)
--
-- bidding is over, calculate the winner of the item
---------------------------------------------------------------------
function PLDKP_EndOfBids()
	_pldkp_bidRunning = false;
	_pldkp_acceptBids = false;
	PLDkpBidsFrame_UnSchedule("PLDKP_Warnings");
	
	SendChatMessage(PLDKP_BID_CLOSING, PLDKP_GetAnnounceChannel());
	
	local winners = nil;
	local biggestBid = 0;
	local price = _pldkp_currentMinBid;
	local nCount = PLDKP_CountBids();
	local nCountWinners = 0;
	local sWinners = "";
	local trWinner = "";
	
	_pldkp_lastWinner = "";
	
	if ( nCount > 0 ) then
		biggestBid = PLDKP_BiggestBid();
		winners = PLDKP_GetBidWinner(biggestBid);
		price = PLDKP_Price(biggestBid) + PLDkpBidsOptions["PriceAddVal"];
		
		nCountWinners = table.getn(winners);
		
		if( nCountWinners > 1 ) then
			for i = 1, table.getn(winners) do
				if ( i>1) then
					sWinners = sWinners .. ", ";
				end
				
				trWinner = winners[i];
											
				if( PLDkpBidsFrame_GetMainCharOfTwink(winners[i]) ~= trWinner) then
					trWinner = winners[i] .. " (" .. PLDKP_INFO_TWINKOF .. " " .. PLDkpBidsFrame_GetMainCharOfTwink(winners[i]) .. ")";
				end
				
				sWinners = sWinners .. trWinner;
			end
			
			if ( (PLDkpBidsOptions["UseDKPOnEqualBids"] == true) and (PLDKPBids:IsDkpDataLoaded()) ) then
				
				local nCurHighDKP = 0;
				local nWCount = 0;
				
				for i = 1, table.getn(winners) do
					local mainCharName = PLDkpBidsFrame_GetMainCharOfTwink(winners[i]) 
					if ( mainCharName~= nil and PLDKPBids:PlayerHasDkpData(mainCharName) ~= nil ) then
						local charDkp = PLDKPBids:PlayerGetDkpData(mainCharName)

						if ( charDkp >= nCurHighDKP ) then
							nCurHighDKP = charDkp;
						end
					end
				end
				
				sWinners = "";
				
				for i = 1, table.getn(winners) do
				
					local mainCharName = PLDkpBidsFrame_GetMainCharOfTwink(winners[i]) 

					if ( mainCharName~= nil and PLDKPBids:PlayerHasDkpData(mainCharName) ~= nil ) then
						local charDkp = PLDKPBids:PlayerGetDkpData(mainCharName)

						if ( charDkp >= nCurHighDKP ) then
						
							if ( nWCount > 0) then
								sWinners = sWinners .. ", ";
							end
							
							trWinner = winners[i];
							
							if( PLDkpBidsFrame_GetMainCharOfTwink(winners[i]) ~= trWinner) then
								trWinner = winners[i] .. " (" .. PLDKP_INFO_TWINKOF .. " " .. PLDkpBidsFrame_GetMainCharOfTwink(winners[i]) .. ")";
							end
							
							sWinners = sWinners .. trWinner;
							nWCount = nWCount + 1;
						end
					end
				end
				
				SendChatMessage(string.format(PLDKP_BID_WINNER1, _pldkp_currentItem), PLDKP_GetAnnounceChannel());
				
				if ( nWCount > 1 ) then
					SendChatMessage(string.format(PLDKP_BID_WINNER3, sWinners, price), PLDKP_GetAnnounceChannel());
					_pldkp_lastWinner = string.gsub(string.format(PLDKP_BID_WINNER3, sWinners, price), "*** ", "");
				else
					SendChatMessage(string.format(PLDKP_BID_WINNER4, sWinners, price), PLDKP_GetAnnounceChannel());
					_pldkp_lastWinner = string.gsub(string.format(PLDKP_BID_WINNER2, sWinners, price), "*** ", "");
				end
				
				PLDKP_AddLastWinner(sWinners, price);

			else
				SendChatMessage(string.format(PLDKP_BID_WINNER1, _pldkp_currentItem), PLDKP_GetAnnounceChannel());
				SendChatMessage(string.format(PLDKP_BID_WINNER3, sWinners, price), PLDKP_GetAnnounceChannel());
				_pldkp_lastWinner = string.gsub(string.format(PLDKP_BID_WINNER3, sWinners, price), "*** ", "");
				
				PLDKP_AddLastWinner(sWinners, price);
			end
		else
			if ( (nCount == 1) and (nCountWinners == 1) ) then
				
				gamerInfo = winners[1];

				if( PLDkpBidsFrame_GetMainCharOfTwink(winners[1]) ~= gamerInfo) then
					gamerInfo = winners[1] .. " (" .. PLDKP_INFO_TWINKOF .. " " .. PLDkpBidsFrame_GetMainCharOfTwink(winners[1]) .. ")";
				end
							
				price = _pldkp_currentMinBid; -- + PLDkpBidsOptions["PriceAddVal"];
				
				SendChatMessage(string.format(PLDKP_BID_WINNER1, _pldkp_currentItem), PLDKP_GetAnnounceChannel());
				SendChatMessage(string.format(PLDKP_BID_WINNER2, gamerInfo, price), PLDKP_GetAnnounceChannel());
				_pldkp_lastWinner = string.gsub(string.format(PLDKP_BID_WINNER2, gamerInfo, price), "*** ", "");
				
				PLDKP_AddLastWinner(winners[1], price);
			else
				--price = _pldkp_currentMinBid + PLDkpBidsOptions["PriceAddVal"];
				
				gamerInfo = winners[1];

				if( PLDkpBidsFrame_GetMainCharOfTwink(winners[1]) ~= gamerInfo) then
					gamerInfo = winners[1] .. " (" .. PLDKP_INFO_TWINKOF .. " " .. PLDkpBidsFrame_GetMainCharOfTwink(winners[1]) .. ")";
				end
				
				SendChatMessage(string.format(PLDKP_BID_WINNER1, _pldkp_currentItem), PLDKP_GetAnnounceChannel());
				SendChatMessage(string.format(PLDKP_BID_WINNER2, gamerInfo, price), PLDKP_GetAnnounceChannel());
				_pldkp_lastWinner = string.gsub(string.format(PLDKP_BID_WINNER2, gamerInfo, price), "*** ", "");
				
				PLDKP_AddLastWinner(winners[1], price);
			end
		end
	else
		SendChatMessage(PLDKP_BID_NOBIDS, PLDKP_GetAnnounceChannel());
		_pldkp_lastWinner = string.gsub(PLDKP_BID_NOBIDS, "*** ", "");
	end
	
	PLDKPFormStartStopAuction:SetText(PLDKP_BUTTON_STARTAUCTION);
	PLDKPForm_ShowAuctionInfo();
	
	--PLDKP_CurrentBids = {};
end

---------------------------------------------------------------------
-- function PLDKP_AddLastWinner(pName, nPrice)
--
-- adds the winner to the last winner array 
---------------------------------------------------------------------
function PLDKP_AddLastWinner(pName, nPrice)
	local sDate = date("%Y%m%d %H:%M:%S");
	
	if ( PLDKP_LastWinners == nil ) then
		PLDKP_LastWinners = {};
	end
	
	color, item, name = string.gmatch(_pldkp_currentItem, "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r")
	
	PLDKP_LastWinners[sDate] = {};
	PLDKP_LastWinners[sDate]["Name"] = pName; 
	PLDKP_LastWinners[sDate]["MainCharName"] = PLDkpBidsFrame_GetMainCharOfTwink(pName);
	PLDKP_LastWinners[sDate]["RaidID"] = PLDKP_CurrentRaidID;
	PLDKP_LastWinners[sDate]["Price"] = nPrice;
	PLDKP_LastWinners[sDate]["Note"] = "";
	PLDKP_LastWinners[sDate]["Date"] = date("%y-%m-%d %H:%M:%S");
	PLDKP_LastWinners[sDate]["ItemName"] = name;
	PLDKP_LastWinners[sDate]["ItemLink"] = _pldkp_currentItem;
	PLDKP_LastWinners[sDate]["ItemTexture"] = _pldkp_currentItemTexture;
end



---------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------
---------------------------------------------------------------------
-- function PLDkpBids_InitOptions()
--
-- init mod options
---------------------------------------------------------------------
function PLDkpBids_InitOptions()
	
	if ( PLDkpBidsOptions == nil ) then
		PLDkpBidsOptions = {};
	end
	
	if ( not PLDkpBidsOptions["DefaultMinDKP"]) then
		PLDkpBidsOptions["DefaultMinDKP"] = _pldkp_currentMinBid;
	end
	
	if ( not PLDkpBidsOptions["AnnounceChannel"] ) then
		PLDkpBidsOptions["AnnounceChannel"] = "AUTO";
	end
	
	if ( not PLDkpBidsOptions["DefBidTSpan"] ) then
		PLDkpBidsOptions["DefBidTSpan"] = _pldkp_currentBidTime;
	end
	
	if ( not PLDkpBidsOptions["TestMode"] ) then
		PLDkpBidsOptions["TestMode"] = 0;
	end
	
	if ( not PLDkpBidsOptions["MaxBids"] ) then
		PLDkpBidsOptions["MaxBids"] = 50000;
	end
	
	if ( not PLDkpBidsOptions["PriceAddVal"] ) then
		PLDkpBidsOptions["PriceAddVal"] = 5;
	end
	
	if ( not PLDkpBidsOptions["ValueStep"] ) then
		PLDkpBidsOptions["ValueStep"] = 5;
	end
	
	if ( not PLDkpBidsOptions["Visible"] ) then
		PLDkpBidsOptions["Visible"] = false;
	end
	
	if ( not PLDkpBidsOptions["UseDKPOnEqualBids"] ) then
		PLDkpBidsOptions["UseDKPOnEqualBids"] = true;
	end
	
	if ( not PLDkpBidsOptions["IgnoreBidsOutsideGrp"] ) then
		PLDkpBidsOptions["IgnoreBidsOutsideGrp"] = true;
	end
	
	if ( not PLDkpBidsOptions["AllowBidsGreaterThanDKP"] ) then
		PLDkpBidsOptions["AllowBidsGreaterThanDKP"] = false;
	end
	
	if ( not PLDkpBidsOptions["MaxMinusDKP"] ) then
		PLDkpBidsOptions["MaxMinusDKP"] = 0;
	end
	
	if ( not PLDkpBidsOptions["AllowBidDelete"] ) then
		PLDkpBidsOptions["AllowBidDelete"] = true;
	end
	
	if ( not PLDkpBidsOptions["ShowCountDownInRaidWarning"] ) then
		PLDkpBidsOptions["ShowCountDownInRaidWarning"] = false;
	end

	if ( not PLDkpBidsOptions["AllwaysAllowMinBid"] ) then
		PLDkpBidsOptions["AllwaysAllowMinBid"] = true;
	end
	
	if ( not PLDkpBidsOptions["AllowHigherBidOverwrite"] ) then
		PLDkpBidsOptions["AllowHigherBidOverwrite"] = false;
	end
	
	if ( not PLDkpBidsOptions["DebugMode"] ) then
		PLDkpBidsOptions["DebugMode"] = true;
	end

	if not PLDkpBidsOptions["EnableMRTIntegration"] then
		-- enable MRT integration if addon found
		PLDkpBidsOptions["EnableMRTIntegration"] = ( MRT_RegisterItemCostHandler ~= nil )
	end
	
	
	PLDkpBidsFrame_SetVisible(PLDkpBidsOptions["Visible"]);
end

---------------------------------------------------------------------
-- function PLDKP_GetItemID(itemLink)
--
-- extracts the item ID from an itemlink
---------------------------------------------------------------------
function PLDKP_GetItemID(itemLink)
	local sRet = "";
	
	_,_, itemId = string.find(itemLink, "item:(%d+):");

	sRet = "item:"..itemId;
	
	return sRet;
end

---------------------------------------------------------------------
-- function PLDKP_CountBids()
--
-- counts the number of recorded bids
---------------------------------------------------------------------
function PLDKP_CountBids()
	local cnt = 0;
	
	for plName in pairs(PLDKP_CurrentBids) do
		if ( plName ) then
			cnt = cnt+1;
		end
	end	
	
	return cnt;
end

---------------------------------------------------------------------
-- function PLDKP_BiggestBid()
--
-- gets the biggest bid
---------------------------------------------------------------------
function PLDKP_BiggestBid()
	local bid = 0;

	for plName in pairs(PLDKP_CurrentBids) do
		if ( PLDKP_CurrentBids[plName] and (PLDKP_CurrentBids[plName] > bid) ) then
			bid = PLDKP_CurrentBids[plName];
		end
	end	
	
	return bid;
end

---------------------------------------------------------------------
-- function PLDKP_GetBidWinner(biggestBid)
--
-- gets the name of the winners
---------------------------------------------------------------------
function PLDKP_GetBidWinner(biggestBid)
	local bid = 0;
	local winnerNames = {};

	local nCount = PLDKP_CountBids();
	
	for plName in pairs(PLDKP_CurrentBids) do
		
		if ( nCount == 1 ) then
			table.insert(winnerNames, plName);
		else
			if ( PLDKP_CurrentBids[plName] == biggestBid ) then
				table.insert(winnerNames, plName);
			end
		end
	end	
	
	return winnerNames;
end

---------------------------------------------------------------------
-- function PLDKP_Price(biggestBid)
--
-- gets the price of the item 
---------------------------------------------------------------------
function PLDKP_Price(biggestBid)
	local bid = 0;

	local nCount = PLDKP_CountBids();
	local biggesBidCount = 0;
	
	if ( nCount == 1) then
		bid = _pldkp_currentMinBid;
	end
	
	if ( nCount > 1) then
		for plName in pairs(PLDKP_CurrentBids) do
			if ( PLDKP_CurrentBids[plName] and (PLDKP_CurrentBids[plName] > bid) and (PLDKP_CurrentBids[plName] < biggestBid) ) then
				bid = PLDKP_CurrentBids[plName];
			end
			
			if ( PLDKP_CurrentBids[plName] and PLDKP_CurrentBids[plName] == biggestBid) then
				biggesBidCount = biggesBidCount + 1;
			end
		end
	else
		bid = biggestBid;
	end

	if ( ( nCount > 1) and (biggestBid > _pldkp_currentMinBid) and (bid == 0) ) then
		bid = biggestBid;
	end
	
	if ( ( nCount > 1) and (bid == 0) ) then
		bid = _pldkp_currentMinBid;
	end
	
	if ( ( nCount > 1 ) and ( biggesBidCount > 1 ) ) then
		bid = biggestBid;
	end
	
	return bid;
end

---------------------------------------------------------------------
-- function PLDKP_GetAnnounceChannel()
--
-- gets the announcing channel for the mod
---------------------------------------------------------------------
function PLDKP_GetAnnounceChannel()
	if ( PLDkpBidsOptions["AnnounceChannel"] == nil ) then
		PLDkpBidsOptions["AnnounceChannel"] = "AUTO";
	end
	
	if ( PLDkpBidsOptions["AnnounceChannel"] == "AUTO" ) then
		local ngrpStatus = PLDKP_GetMyGroupStatus();
		
		if ( ngrpStatus == "R" ) then
			return "RAID";
		elseif ( ngrpStatus == "P" ) then
			return "PARTY";
		elseif ( IsInGuild() ) then
			return "GUILD";
		else
			return "SAY";
		end
	end
	
	return PLDkpBidsOptions["AnnounceChannel"];
end

---------------------------------------------------------------------
-- function PLDKP_GetMyGroupStatus()
--
-- check if the player running the addon is grouped or not
---------------------------------------------------------------------
function PLDKP_GetMyGroupStatus()
	local status = "N";
	
	if ( UnitInRaid("player") ) then
		status = "R";
		PLDKP_debug("I'm in a raid-group");
	elseif ( (UnitInParty("player")) and (GetNumGroupMembers() > 0) ) then
		status = "P";
		PLDKP_debug("I'm in a party");
	end
	
	return status;
end

---------------------------------------------------------------------
-- function PLDKP_GetPlayerGroupStatus(name)
--
-- check if the player "name" is in the group of me
---------------------------------------------------------------------
function PLDKP_GetPlayerGroupStatus(pName)
	local status = "N";
	local ownStatus = PLDKP_GetMyGroupStatus();
	local nMemberCnt = 0;
	local nCounter=0;
	
	PLDKP_debug("Checking player status of " .. pName)
	
	if ( ownStatus ~= "N") then
		
		if( ownStatus == "R" ) then
			nMemberCnt = GetNumGroupMembers();
			
			for nCounter = 1, nMemberCnt do
				name, rank, subgroup, level, class, filename, zone, online, isdead = GetRaidRosterInfo(nCounter);
				
				if (name ~= nil) then
					if( name == pName) then
						status = "R";
						return status;
					end
				end
			end
		end
		
		if( ownStatus == "P" ) then
			PLDKP_debug("Playername is " .. PLDKPBids:GetPlayerName("player"))
			if( pName == PLDKPBids:GetPlayerName("player") ) then
				status = "P";
				return status;
			end
			
			nMemberCnt = GetNumGroupMembers();
			
			PLDKP_debug("num party members: " .. nMemberCnt);
			
			for nCounter = 1, nMemberCnt do
				--unitID = GetPartyMember(nCounter);
				--name = UnitName("party"..unitID);
				name = PLDKPBids:GetPlayerName("party"..nCounter);
				
				PLDKP_debug( "cnt" .. nCounter .. " unitid=" .. nCounter);
				
				
				if (name ~= nil) then
					PLDKP_debug( "cnt" .. nCounter .. " name=" .. name);
					
					if( name == pName) then
						status = "P";
						return status;
					end
				end
			end
		end
	end
	
	return status;
end

---------------------------------------------------------------------
-- function PLDKP_processWhisper(name, message)
--
-- processes an incoming whisper
---------------------------------------------------------------------
function PLDKP_processWhisper(name, message)
	local lmsg = string.lower(message);
	local biddenNumber = nil; 
	local partyCheck = "N";
	local mainCharName = ""; 
	
	PLDKP_debug("PLDKP_processWhisper from " .. name .. "(" .. message .. ")...");
	
	if ( _pldkp_acceptBids == false ) then
		PLDKP_debug("_pldkp_acceptBids == false");

		local dkpIndex = string.find(lmsg, "dkp", 1, true)
		if ( dkpIndex == 1 ) then
			PLDKP_FindAndAnswerPlayerDkp(name)
			return false;
		end

		return false;  
	end
	
	if ( PLDkpBidsOptions["IgnoreBidsOutsideGrp"] == true ) then
		-- if the player is in your party or raidgroup
		-- If not return false and show normal whisper !
		PLDKP_debug("IgnoreBidsOutsideGrp = true");
		
		_grpStatus = PLDKP_GetMyGroupStatus();
		
		PLDKP_debug("grpstatus = ".._grpStatus);
		
		if(_grpStatus == "N") then
			-- I'm not in a grp, can not make auctions !
			PLDKP_debug("not in group, ignore whisper");
			return false;
		end
		
		partyCheck = PLDKP_GetPlayerGroupStatus(name);
		
		PLDKP_debug("partycheck = "..partyCheck);
		
		if(partyCheck == "N" ) then
			-- the player whith this name is not in my party or raidgrp
			PLDKP_debug("not in same group as auctionator, ignore whisper");
			PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID8, message))
			return false;
		end
	end
	
	if ( string.find(lmsg, "dkp") ) then
		--lmsg,_ = string.gsub(lmsg, "dkp", "");
		-- ignore whispers with "dkp" in the text
		PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID9, message, PLDKPBids.myName, _pldkp_currentMinBid))
		return false;
	end
	
	lmsg,_ = string.gsub(lmsg, " ", "");
	
	if ( string.find(lmsg, "del") and PLDkpBidsOptions["AllowBidDelete"] ) then
		if (PLDKP_CurrentBids[name] ~= nil) then
			PLDKP_CurrentBids[name] = nil;
			PLDKP_sendWhisper(name, PLDKP_BID_DELETED);
			PLDKP_info(string.format(PLDKP_BID_DELETED_SCREEN, name));
		end
	else
	
		if (string.len ( lmsg ) > 5 ) then
			PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID5, lmsg));
			PLDKP_info(string.format(PLDKP_BID_INVALID5_SCRREN, name));
		else

			biddenNumber = tonumber(lmsg);
			
			PLDKP_debug("bid from "..name .. ": " .. biddenNumber);
			
			if ( biddenNumber == nil ) then
				PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID, message));
				PLDKP_info(string.format(PLDKP_BID_INVALID_SCRREN, name));
			else
				mainCharName = PLDkpBidsFrame_GetMainCharOfTwink(name);
				gamerInfo = name;

				if(mainCharName ~= name) then
					PLDKP_debug(name .. " is the twink of " .. mainCharName);
					gamerInfo = name .. "(" .. PLDKP_INFO_TWINKOF .. " " .. mainCharName .. ")";
				else
					PLDKP_debug(name .. " is a main character");
				end
				
				if ( (PLDKP_CurrentBids[name] == nil) or (PLDkpBidsOptions["AllowHigherBidOverwrite"] == true) ) then

					if( (mainCharName ~= name) and (PLDKP_AllowTwinkBids == false) ) then
						PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID7, biddenNumber));
						PLDKP_info(string.format(PLDKP_BID_INVALID7_SCRREN, name));
						return true;
					end
									
					if ( biddenNumber < _pldkp_currentMinBid ) then
						PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID1, biddenNumber, _pldkp_currentMinBid));
						PLDKP_info(string.format(PLDKP_BID_INVALID1_SCRREN, name));
					else
						if ( (PLDKP_CurrentBids[name] ~= nil) and ( biddenNumber < PLDKP_CurrentBids[name]) ) then	
							PLDKP_sendWhisper(name, string.format(PLDKP_BID_ALREADYOV, PLDKP_CurrentBids[name]));
							PLDKP_info(string.format(PLDKP_BID_ALREADYOV_SCREEN, gamerInfo));
						else
							if (  PLDkpBidsOptions["TestMode"] == "1" )  then
								if ( biddenNumber > PLDkpBidsOptions["MaxBids"] ) then
									PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID3, biddenNumber, PLDkpBidsOptions["MaxBids"]));
									PLDKP_info(string.format(PLDKP_BID_INVALID3_SCRREN, name));
								else
									if (  mod (biddenNumber, PLDkpBidsOptions["ValueStep"] ) == 0 ) then
										PLDKP_CurrentBids[name] = biddenNumber;	
										PLDKP_sendWhisper(name, PLDKP_BID_ACCEPTED);
										PLDKP_info(string.format(PLDKP_BID_ACCEPTED_SCREEN, gamerInfo));
									else
										PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID4, biddenNumber, PLDkpBidsOptions["ValueStep"]));
										PLDKP_info(string.format(PLDKP_BID_INVALID4_SCRREN, gamerInfo, PLDkpBidsOptions["ValueStep"]));
									end
								end
							else
								if ( PLDKPBids:IsDkpDataLoaded() ) then
								
									if ( PLDKPBids:PlayerHasDkpData(mainCharName) ~= nil ) then
										local charCurrentDkp = PLDKPBids:PlayerGetDkpData(mainCharName)

										if ( PLDkpBidsOptions["AllowBidsGreaterThanDKP"] == false ) then
											if (  biddenNumber > charCurrentDkp ) then
												if ( (biddenNumber == _pldkp_currentMinBid) and (PLDkpBidsOptions["AllwaysAllowMinBid"]==true) ) then
													if (  mod (biddenNumber, PLDkpBidsOptions["ValueStep"] ) == 0 ) then
														PLDKP_CurrentBids[name] = biddenNumber;	
														PLDKP_sendWhisper(name, PLDKP_BID_ACCEPTED);
														PLDKP_info(string.format(PLDKP_BID_ACCEPTED_SCREEN, gamerInfo));
													else
														PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID4, biddenNumber, PLDkpBidsOptions["ValueStep"]));
														PLDKP_info(string.format(PLDKP_BID_INVALID4_SCRREN, gamerInfo, PLDkpBidsOptions["ValueStep"]));
													end
												else
													PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID2, biddenNumber, charCurrentDkp));
													PLDKP_info(string.format(PLDKP_BID_INVALID2_SCRREN, gamerInfo));
												end
											else
												if (  mod (biddenNumber, PLDkpBidsOptions["ValueStep"] ) == 0 ) then
													PLDKP_CurrentBids[name] = biddenNumber;	
													PLDKP_sendWhisper(name, PLDKP_BID_ACCEPTED);
													PLDKP_info(string.format(PLDKP_BID_ACCEPTED_SCREEN, gamerInfo));
												else
													PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID4, biddenNumber, PLDkpBidsOptions["ValueStep"]));
													PLDKP_info(string.format(PLDKP_BID_INVALID4_SCRREN, gamerInfo, PLDkpBidsOptions["ValueStep"]));
												end
											end
										else
											if (  ((charCurrentDkp-biddenNumber) < PLDkpBidsOptions["MaxMinusDKP"] ) and (PLDkpBidsOptions["MaxMinusDKP"] > 0) ) then
												PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID6, biddenNumber, (charCurrentDkp-biddenNumber)));
												PLDKP_info(string.format(PLDKP_BID_INVALID6_SCRREN, gamerInfo));
											else
												if (  mod (biddenNumber, PLDkpBidsOptions["ValueStep"] ) == 0 ) then
													PLDKP_CurrentBids[name] = biddenNumber;	
													PLDKP_sendWhisper(name, PLDKP_BID_ACCEPTED);
													PLDKP_info(string.format(PLDKP_BID_ACCEPTED_SCREEN, gamerInfo));
												else
													PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID4, biddenNumber, PLDkpBidsOptions["ValueStep"]));
													PLDKP_info(string.format(PLDKP_BID_INVALID4_SCRREN, gamerInfo, PLDkpBidsOptions["ValueStep"]));
												end
											end
										end
									else
										-- player not in DKP-System = 0 DKP start	
										if ( PLDkpBidsOptions["AllowBidsGreaterThanDKP"] == false ) then
											if ( (biddenNumber == _pldkp_currentMinBid) and (PLDkpBidsOptions["AllwaysAllowMinBid"]==true) ) then
												if (  mod (biddenNumber, PLDkpBidsOptions["ValueStep"] ) == 0 ) then
													PLDKP_CurrentBids[name] = biddenNumber;	
													PLDKP_sendWhisper(name, PLDKP_BID_ACCEPTED);
													PLDKP_info(string.format(PLDKP_BID_ACCEPTED_SCREEN, gamerInfo));
												else
													PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID4, biddenNumber, PLDkpBidsOptions["ValueStep"]));
													PLDKP_info(string.format(PLDKP_BID_INVALID4_SCRREN, gamerInfo, PLDkpBidsOptions["ValueStep"]));
												end

											else
												PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID2, biddenNumber, 0));
												PLDKP_info(string.format(PLDKP_BID_INVALID2_SCRREN, gamerInfo));
											end
										else
											if ((  (0-biddenNumber) < PLDkpBidsOptions["MaxMinusDKP"] ) and (PLDkpBidsOptions["MaxMinusDKP"] > 0) ) then
												PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID6, biddenNumber, (0-biddenNumber)));
												PLDKP_info(string.format(PLDKP_BID_INVALID6_SCRREN, gamerInfo));
											else
												if (  mod (biddenNumber, PLDkpBidsOptions["ValueStep"] ) == 0 ) then
													PLDKP_CurrentBids[name] = biddenNumber;	
													PLDKP_sendWhisper(name, PLDKP_BID_ACCEPTED);
													PLDKP_info(string.format(PLDKP_BID_ACCEPTED_SCREEN, gamerInfo));
												else
													PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID4, biddenNumber, PLDkpBidsOptions["ValueStep"]));
													PLDKP_info(string.format(PLDKP_BID_INVALID4_SCRREN, gamerInfo, PLDkpBidsOptions["ValueStep"]));
												end
											end
										end
									end
								else
									if (  mod (biddenNumber, PLDkpBidsOptions["ValueStep"] ) == 0 ) then
										PLDKP_CurrentBids[name] = biddenNumber;	
										PLDKP_sendWhisper(name, PLDKP_BID_ACCEPTED);
										PLDKP_info(string.format(PLDKP_BID_ACCEPTED_SCREEN, gamerInfo));
									else
										PLDKP_sendWhisper(name, string.format(PLDKP_BID_INVALID4, biddenNumber, PLDkpBidsOptions["ValueStep"]));
										PLDKP_info(string.format(PLDKP_BID_INVALID4_SCRREN, gamerInfo, PLDkpBidsOptions["ValueStep"]));
									end
								end
							end
						end
					end
				else
					PLDKP_sendWhisper(name, string.format(PLDKP_BID_ALREADY, PLDKP_CurrentBids[name]));
					PLDKP_info(string.format(PLDKP_BID_ALREADY_SCREEN, gamerInfo));
				end
			end
		end
	end
	
	return true;
end

---------------------------------------------------------------------
-- function PLDKP_sendWhisper(name, message)
--
-- sends a whisper to a player
---------------------------------------------------------------------
function PLDKP_sendWhisper(name, message)
	if(name == PLDKPBids.myServerName) then
		_whisperingMyself = true
	end

    SendChatMessage(message, "WHISPER", nil, name)
end

---------------------------------------------------------------------
-- function PLDKP_ParseArguments(msg)
--
-- Parse Slashcommand arguments
---------------------------------------------------------------------
function PLDKP_ParseArguments(msg)
	local args = {};
	local tmp = {};

	-- Find all space delimited words.
	for value in string.gmatch(msg, "[^ ]+") do
		table.insert(tmp, value);
	end
	
	-- Make a pass through the table, and concatenate all words that have quotes.
	local quoteOpened = false;
	local quotedArg = "";
	for i = 1, table.getn(tmp) do
		if (string.find(tmp[i], "\"") == nil) then
			if (quoteOpened) then
				quotedArg = quotedArg.." "..string.gsub(tmp[i], "\"", "");
			else
				table.insert(args, tmp[i]);
			end
		else
			for value in string.gmatch(tmp[i], "\"") do
				quoteOpened = not quoteOpened;
			end

			if (quoteOpened) then
				quotedArg = string.gsub(tmp[i], "\"", "");
			else
				if (string.len(quotedArg) > 0) then
					quotedArg = quotedArg.." "..string.gsub(tmp[i], "\"", "");
				else
					quotedArg = string.gsub(tmp[i], "\"", "");
				end
				
				table.insert(args, quotedArg);
				quotedArg = "";
			end
		end
	end
	
	if (string.len(quotedArg) > 0) then
		table.insert(args, quotedArg);
	end
	
	return args;
end

-------------------------------------------------------------------------------
-- UI functions
-------------------------------------------------------------------------------

---------------------------------------------------------------------
-- function PLDkpBidsFrame_DisplayTooltip( Message)
--
-- Displays the AddOn's tooltip window
---------------------------------------------------------------------
function PLDkpBidsFrame_DisplayTooltip( Message)
	PLDkpBids_Tooltip:SetOwner(PLDkpBidsFrame, "ANCHOR_BOTTOMLEFT");
	--PLDkpBids_Tooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	PLDkpBids_Tooltip:ClearLines();
	PLDkpBids_Tooltip:SetText(Message);
	PLDkpBids_Tooltip:Show();
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_SetVisible(visible)
--
-- Toggles visibility of the main UI-Form
---------------------------------------------------------------------
function PLDkpBidsFrame_SetVisible(visible)
	PLDkpBidsOptions["Visible"] = visible;
	

	if (visible) then
		ShowUIPanel(PLDKPForm);
		PLDKPFormAllowTwinkBidsCheck:SetChecked(PLDKP_AllowTwinkBids);
	else
		HideUIPanel(PLDKPForm);
		PLDKP_println(PLDKP_ClosedMessage);
	end
end

---------------------------------------------------------------------
-- function PLDKP_ShowCurrentItemToolTip()
--
-- Shows an item-tooltip for the current auction item
---------------------------------------------------------------------
function PLDKP_ShowCurrentItemToolTip()
	
	if ( (_pldkp_currentItem ~= nil) and (_pldkp_currentItem ~= "") ) then
		PLDkpBids_Tooltip:SetOwner(PLDkpBidsFrame, "ANCHOR_BOTTOMRIGHT");
		--PLDkpBids_Tooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
		PLDkpBids_Tooltip:ClearLines();
		PLDkpBids_Tooltip:SetHyperlink(PLDKP_GetItemID(_pldkp_currentItem));
		PLDkpBids_Tooltip:Show();
	end
end

---------------------------------------------------------------------
-- function PLDKP_ShowLastWinnerstItemToolTip(buttonID)
--
-- Shows an item-tooltip for the current last-winner item
---------------------------------------------------------------------
function PLDKP_ShowLastWinnerstItemToolTip(buttonID)
	
	local index = buttonID + FauxScrollFrame_GetOffset(LastWinnersListFrame);
	local sDate = PLDkpBidsFrame_GetLastWinnerByIndex(index);
	if ( sDate ~= nil ) then
		
		if ( (PLDKP_LastWinners[sDate]["ItemLink"] ~= nil) and (PLDKP_LastWinners[sDate]["ItemLink"] ~= "") ) then
			PLDkpBids_Tooltip:SetOwner(PLDkpBidsFrame, "ANCHOR_BOTTOMRIGHT");
			--PLDkpBids_Tooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
			PLDkpBids_Tooltip:ClearLines();
			PLDkpBids_Tooltip:SetHyperlink(PLDKP_GetItemID(PLDKP_LastWinners[sDate]["ItemLink"]));
			PLDkpBids_Tooltip:Show();
		end
	end
end

---------------------------------------------------------------------
-- function PLDkpBids_OnDelWinner(buttonID)
--
-- Deletes a winner entry
---------------------------------------------------------------------
function PLDkpBids_OnDelWinner(buttonID)
	local index = buttonID + FauxScrollFrame_GetOffset(LastWinnersListFrame);
	local sDate = PLDkpBidsFrame_GetLastWinnerByIndex(index);
	
	if ( sDate ~= nil ) then
		
		if ( (PLDKP_LastWinners[sDate] ~= nil) ) then
			PLDKP_LastWinners[sDate] = nil;
		end
	end
	
	PLDkpBidsFrame_FillLastWinners();
end

---------------------------------------------------------------------
-- function PLDkpBids_OnDelWinner(buttonID)
--
-- Deletes a winner entry
---------------------------------------------------------------------
function PLDkpBids_OnSetWinnerNote(buttonID)
	local index = buttonID + FauxScrollFrame_GetOffset(LastWinnersListFrame);
	local sDate = PLDkpBidsFrame_GetLastWinnerByIndex(index);
	
	
	if ( sDate ~= nil ) then

		if ( (PLDKP_LastWinners[sDate] ~= nil) ) then
			PLDKP_WinnerNote = PLDKP_LastWinners[sDate].Note;
			PLDKP_WinnerNoteKey = sDate;
			ShowUIPanel(PLDkpBidsNoteFrame);			
		end
	end
	
	PLDkpBidsNoteFrame_SetNote(PLDKP_WinnerNote);
end


---------------------------------------------------------------------
-- function PLDKPForm_OnLoad()
--
-- Called when the Mod-Frame is loaded
--
-- Initializes the AddOn and registers for common events
---------------------------------------------------------------------
function PLDKPForm_OnLoad()

	PLDKPForm:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 0.8);
	PLDKPForm:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 1.0);
	
	PLDKPForm:RegisterEvent("VARIABLES_LOADED");
	PLDKPForm:RegisterEvent("PLAYER_ENTERING_WORLD");
end

---------------------------------------------------------------------
-- function PLDKPForm_OnEvent(event)
--
-- Default eventhandler for the AddOn
--
-- Handels events for all Mods
---------------------------------------------------------------------
function PLDKPForm_OnEvent(self, event, ...)
	local playerName = PLDKPBids:GetPlayerName("player");
	
	if (event == "VARIABLES_LOADED") then
	
		PLDKPForm_InitUI();

	end
	
	if(not PLDKP_Loaded) then
		return;
	end
end

---------------------------------------------------------------------
-- PLDKPForm_OnMouseDown(arg1)
--
-- Eventhandler called if the user clicks a mouse-button within
-- the BossMod-UI.
---------------------------------------------------------------------
function PLDKPForm_OnMouseDown(arg1)
	if (arg1 == "LeftButton") then
		PLDKPForm:StartMoving();
	end
end

---------------------------------------------------------------------
-- PLDKPForm_OnMouseUp(arg1)
--
-- Eventhandler called if the user releases a mouse-button within
-- the BossMod-UI.
---------------------------------------------------------------------
function PLDKPForm_OnMouseUp(arg1)
	if (arg1 == "LeftButton") then
		PLDKPForm:StopMovingOrSizing();
		--PLBossMods_SavePosition();
	end
end

---------------------------------------------------------------------
-- function PLDKPForm_OnUpdate(elapsed)
--
-- Eventhandler for the OnUpdate-Event
--
-- Called at periodic times. Used for UI-updates and timing issues
---------------------------------------------------------------------
function PLDKPForm_OnUpdate(elapsed)

	if (PLDkpBidsOptions == nil) then
		return;
	end
	
	PLDKPForm_UpdateSortArrowVisibility();
	PLDKPForm_UpdateScrollbars();
	PLDKPForm_UpdateButtonVisibility();
	

	if ( _selectedTab == 2 ) then
		PLDkpBidsFrame_FillCurBids();
	end
	
	if ( _selectedTab == 3 ) then
		PLDkpBidsFrame_FillLastWinners();
	end
	
	if ( _selectedTab == 4 ) then
		PLDkpBidsFrame_FillDKPList();
	end
end

---------------------------------------------------------------------
-- function PLDKPForm_InitUI()
--
-- Init form
--
---------------------------------------------------------------------
function PLDKPForm_InitUI()
	ButtonOptions:SetText(PLDKP_BUTTON_OPTIONS);
	ButtonSave:SetText(PLDKP_BUTTON_SAVE);
	
	PLDKPFormTitleLabel:SetText(PLDKP_VERSION_STRING);
	PLDKPFormInfoLabel:SetText(PLDKP_TOOLTIP_INFO);
	
	PLDKPFormTabAuction:SetText(PLDKP_TABLABEL_AUCTION);
	PLDKPFormTabCurBids:SetText(PLDKP_TABLABEL_CURBIDS);
	PLDKPFormTabLastWinners:SetText(PLDKP_TABLABEL_LASTWINNERS);
	PLDKPFormTabDKPList:SetText(PLDKP_TABLABEL_DKPLIST);
	
	CurBidsNameButton:SetText(PLDKP_TABBUTTON_NAME);
	LastWinnersNameButton:SetText(PLDKP_TABBUTTON_NAME);
	DKPListNameButton:SetText(PLDKP_TABBUTTON_NAME);
	CurBidsClassButton:SetText(PLDKP_TABBUTTON_CLASS);
	DKPListClassButton:SetText(PLDKP_TABBUTTON_CLASS);
	CurBidsBidButton:SetText(PLDKP_TABBUTTON_CURBID);
	CurBidsDKPButton:SetText(PLDKP_TABBUTTON_DKP);
	DKPListDKPButton:SetText(PLDKP_TABBUTTON_DKP);
	LastWinnersItemButton:SetText(PLDKP_TABBUTTON_ITEM);
	LastWinnersDateButton:SetText(PLDKP_TABBUTTON_DATE);
	LastWinnersPriceButton:SetText(PLDKP_TABBUTTON_PRICE);
	
	PLDKPFormAuctionItemLabel:SetText(PLDKP_TABBUTTON_ITEM..":");
	PLDKPFormAuctionAcceptTimeLabel:SetText(PLDKP_LABEL_TIME);
	PLDKPFormAuctionMinDKPLabel:SetText(PLDKP_LABEL_MINDKP);
	
	PLDKPFormAuctionAcceptTimeUnitLabel:SetText(PLDKP_LABEL_TIMESEC);
	PLDKPFormAuctionMinDKPUnitLabel:SetText(PLDKP_LABEL_DKP);

	PLDKPFormAuctionAcceptTimeEditBtn:Hide();
	PLDKPFormAuctionMinDKPEditBtn:Hide();
			
	PLDKPFormStartStopAuction:SetText(PLDKP_BUTTON_STARTAUCTION);
	
	PLDKPFormAuctionTimeRemainingLabel:SetText(PLDKP_LABEL_TIMEREMAINING);
	
	PLDKPFormAuctionWinnerLabel:Hide();
	
	PLDKPFormAllowTwinkBidsLabel:SetText(PLDKP_TOOLTIP_TWINKCHK);
	
	PLDkpBidsFrame_ClickTab(1);
	
	if ( PLDKPBids:IsDkpDataLoaded() == false) then
		PLDKPFormTabDKPList:Hide();
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_ToggleStartStopAuction()
--
-- starts or stops the auction for the current item
---------------------------------------------------------------------
function PLDkpBidsFrame_ToggleStartStopAuction()
	-- start or stop auction for current item !!
	
	if ( _pldkp_bidRunning ) then
	
		PLDKP_ResetBid();	
		--PLDKPFormAuctionAcceptTimeEdit:Enable();
		--PLDKPFormAuctionMinDKPEdit:Enable();
		
		PLDKPFormAuctionAcceptTimeEdit:Hide();
		PLDKPFormAuctionMinDKPEdit:Hide();
		
		PLDKPFormAuctionAcceptTimeEditBtn:Show();
		PLDKPFormAuctionMinDKPEditBtn:Show();
		
		PLDKPFormAuctionAcceptTimeELLabel:Hide();
		PLDKPFormAuctionMinDKPEL:Hide();
		
		PLDKPFormAuctionTimeRemainingLabel:Hide();
		PLDKPFormAuctionTimeRemainingNRLabel:Hide();
		
		PLDKPFormAuctionWinnerLabel:Show();
		
		PLDKPFormStartStopAuction:SetText(PLDKP_BUTTON_STARTAUCTION);
		
		PLDKPFormAllowTwinkBidsCheck:Enable();

	else
		
		local tmp = PLDKPFormAuctionAcceptTimeEdit:GetText();
		if( tonumber(tmp) ~= nil ) then
			_pldkp_currentBidTime = tonumber(tmp);
		end
		
		tmp = PLDKPFormAuctionMinDKPEdit:GetText();
		if( tonumber(tmp) ~= nil ) then
			_pldkp_currentMinBid = tonumber(tmp);
		end
		
		--if ( PLDkpBidsOptions["IgnoreBidsOutsideGrp"] == true ) then
			_grpStatus = PLDKP_GetMyGroupStatus();

			if(_grpStatus == "N") then
				-- not in a grp, can not make auctions !
				PLDKP_errln(PLDKP_ERROR_NOTGROUPED);
				return;
			end
		--end
	
		PLDKPFormAuctionAcceptTimeEdit:ClearFocus();
		PLDKPFormAuctionMinDKPEdit:ClearFocus();
		
		PLDKPFormAuctionAcceptTimeEdit:Hide();
		PLDKPFormAuctionMinDKPEdit:Hide();
		
		PLDKPFormAuctionAcceptTimeEditBtn:Hide();
		PLDKPFormAuctionMinDKPEditBtn:Hide();
		
		PLDKPFormAuctionAcceptTimeELLabel:Show();
		PLDKPFormAuctionMinDKPELLabel:Show();
		
		PLDKPFormAuctionAcceptTimeELLabel:SetText(_pldkp_currentBidTime.."");
		PLDKPFormAuctionMinDKPELLabel:SetText(_pldkp_currentMinBid.."");
		
		PLDKPFormAuctionTimeRemainingLabel:Show();
		PLDKPFormAuctionTimeRemainingNRLabel:Show();
		
		_pldkp_timeEnd = GetTime()+_pldkp_currentBidTime;
		
		PLDKPFormStartStopAuction:SetText(PLDKP_BUTTON_ABORTAUCTION);
		
		PLDKP_StartAuction(_pldkp_currentItem, _pldkp_currentItemTexture, _pldkp_currentMinBid, _pldkp_currentBidTime);
		PLDKPFormAuctionWinnerLabel:Hide();
		
		PLDKPFormAllowTwinkBidsCheck:Disable();
	end
end

---------------------------------------------------------------------
-- function PLDKPForm_ShowAuctionInfo()
--
-- shows auction infos on the first tab
---------------------------------------------------------------------
function PLDKPForm_ShowAuctionInfo()
	if ( _selectedTab ~= 1 ) then
		return;
	end
	
	if ( _pldkp_currentItem == "" ) then
		PLDKPForm_SetUIVisibility(true);
		PLDKPFormAuctionItemLabel:Hide();
		PLDKPFormAuctionItemLinkLabel:Hide();
		PLDKPFormAuctionItemButton:Hide();
		PLDKPFormAuctionAcceptTimeLabel:Hide();
		PLDKPFormAuctionMinDKPLabel:Hide();
		PLDKPFormAuctionAcceptTimeEdit:Hide();
		PLDKPFormAuctionMinDKPEdit:Hide();
		PLDKPFormAuctionAcceptTimeUnitLabel:Hide();
		PLDKPFormAuctionMinDKPUnitLabel:Hide();
		PLDKPFormAuctionAcceptTimeELLabel:Hide();
		PLDKPFormAuctionMinDKPELLabel:Hide();
		PLDKPFormStartStopAuction:Hide();
		PLDKPFormAuctionAcceptTimeEditBtn:Hide();
		PLDKPFormAuctionMinDKPEditBtn:Hide();
		
		PLDKPFormAllowTwinkBids:Hide();
		PLDKPFormAllowTwinkBidsCheck:Hide();
	else
		PLDKPForm_SetUIVisibility(false);
		PLDKPFormAuctionItemLabel:Show();
		PLDKPFormAuctionItemLinkLabel:Show();
		PLDKPFormAuctionAcceptTimeLabel:Show();
		PLDKPFormAuctionMinDKPLabel:Show();
		
		PLDKPFormAllowTwinkBids:Show();
		PLDKPFormAllowTwinkBidsCheck:Show();
		
		PLDKPFormAllowTwinkBidsCheck:SetChecked(PLDKP_AllowTwinkBids);
		
		if ( _pldkp_bidRunning == false ) then
			PLDKPFormAuctionAcceptTimeEdit:Hide();
			PLDKPFormAuctionMinDKPEdit:Hide();
			PLDKPFormAuctionAcceptTimeEditBtn:Show();
			PLDKPFormAuctionMinDKPEditBtn:Show();
			PLDKPFormAuctionAcceptTimeELLabel:Hide();
			PLDKPFormAuctionMinDKPELLabel:Hide();
			PLDKPFormAuctionTimeRemainingLabel:Hide();
			PLDKPFormAuctionTimeRemainingNRLabel:Hide();
			
			PLDKPFormAllowTwinkBidsCheck:Enable();
		else
			PLDKPFormAuctionAcceptTimeEdit:Hide();
			PLDKPFormAuctionMinDKPEdit:Hide();
			PLDKPFormAuctionAcceptTimeEditBtn:Hide();
			PLDKPFormAuctionMinDKPEditBtn:Hide();
			PLDKPFormAuctionAcceptTimeELLabel:Show();
			PLDKPFormAuctionMinDKPELLabel:Show();
			PLDKPFormAuctionTimeRemainingLabel:Show();
			PLDKPFormAuctionTimeRemainingNRLabel:Show();
			
			PLDKPFormAllowTwinkBidsCheck:Disable();
		end
		
		PLDKPFormAuctionAcceptTimeUnitLabel:Show();
		PLDKPFormAuctionMinDKPUnitLabel:Show();
		PLDKPFormStartStopAuction:Show();
		
		PLDKPFormAuctionAcceptTimeEdit:SetText(_pldkp_currentBidTime);
		PLDKPFormAuctionMinDKPEdit:SetText(_pldkp_currentMinBid);
		PLDKPFormAuctionAcceptTimeELLabel:SetText(_pldkp_currentBidTime);
		PLDKPFormAuctionMinDKPELLabel:SetText(_pldkp_currentMinBid);
		PLDKPFormAuctionAcceptTimeEditBtn:SetText(_pldkp_currentBidTime);
		PLDKPFormAuctionMinDKPEditBtn:SetText(_pldkp_currentMinBid);
		
		PLDKPFormAuctionItemLinkLabel:SetText(_pldkp_currentItem);
		
		if ( _pldkp_currentItemTexture ~= "" ) then
			PLDKPFormAuctionItemButton:SetNormalTexture(_pldkp_currentItemTexture);
			PLDKPFormAuctionItemButton:SetPushedTexture(_pldkp_currentItemTexture);
			PLDKPFormAuctionItemButton:SetDisabledTexture(_pldkp_currentItemTexture);
			PLDKPFormAuctionItemButton:Show();
		end
		
		if ( _pldkp_lastWinner ~= "" ) then
			PLDKPFormAuctionWinnerLabel:SetText(_pldkp_lastWinner);
			PLDKPFormAuctionWinnerLabel:Show();
		else
			PLDKPFormAuctionWinnerLabel:SetText(_pldkp_lastWinner);
			PLDKPFormAuctionWinnerLabel:Hide();
		end
		
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_ShowMinDKPEdit()
--
-- Button clicked for typing in the minimum DKP
--
---------------------------------------------------------------------
function PLDkpBidsFrame_ShowMinDKPEdit()
	PLDKPFormAuctionMinDKPEdit:Show();
	PLDKPFormAuctionMinDKPEditBtn:Hide();
	PLDKPFormAuctionMinDKPELLabel:Hide();
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_ShowAcceptTimeEdit()
--
-- Button clicked for typing in the accept time
--
---------------------------------------------------------------------
function PLDkpBidsFrame_ShowAcceptTimeEdit()
	PLDKPFormAuctionAcceptTimeEdit:Show();
	PLDKPFormAuctionAcceptTimeEditBtn:Hide();
	PLDKPFormAuctionAcceptTimeELLabel:Hide();
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_MinDKPEditESC()
--
-- ESC button clicked min. DKP edit box
--
---------------------------------------------------------------------
function PLDkpBidsFrame_MinDKPEditESC()
	PLDKPFormAuctionMinDKPEdit:Hide();
	PLDKPFormAuctionMinDKPEdit:SetText(_pldkp_currentMinBid);
	PLDKPFormAuctionMinDKPEditBtn:Show();
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_MinDKPEditENTER()
--
-- ENTER button clicked min. DKP edit box
--
---------------------------------------------------------------------
function PLDkpBidsFrame_MinDKPEditENTER()
	PLDKPFormAuctionMinDKPEdit:Hide();
	tmp = PLDKPFormAuctionMinDKPEdit:GetText();
	if( tonumber(tmp) ~= nil ) then
		_pldkp_currentMinBid = tonumber(tmp);
	end
	PLDKPFormAuctionMinDKPEditBtn:SetText(_pldkp_currentMinBid);
	PLDKPFormAuctionMinDKPEditBtn:Show();
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_AcceptTimeEditESC()
--
-- ESC button clicked accept time edit box
--
---------------------------------------------------------------------
function PLDkpBidsFrame_AcceptTimeEditESC()
	PLDKPFormAuctionAcceptTimeEdit:Hide();
	PLDKPFormAuctionAcceptTimeEdit:SetText(_pldkp_currentBidTime);
	PLDKPFormAuctionAcceptTimeEditBtn:Show();
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_AcceptTimeEditENTER()
--
-- ENTER button clicked accept time edit box
--
---------------------------------------------------------------------
function PLDkpBidsFrame_AcceptTimeEditENTER()
	PLDKPFormAuctionAcceptTimeEdit:Hide();
	tmp = PLDKPFormAuctionAcceptTimeEdit:GetText();
	if( tonumber(tmp) ~= nil ) then
		_pldkp_currentBidTime = tonumber(tmp);
	end
	PLDKPFormAuctionAcceptTimeEditBtn:SetText(_pldkp_currentBidTime);
	PLDKPFormAuctionAcceptTimeEditBtn:Show();
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_AllowTwinkBids()
--
-- Button clicked for allowing twink bids
--
---------------------------------------------------------------------
function PLDkpBidsFrame_AllowTwinkBids()
	if( PLDKP_AllowTwinkBids) then
		PLDKP_AllowTwinkBids = false;
	else
		PLDKP_AllowTwinkBids = true;
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_ClickTab(tabID)
--
-- Clicked Tab-Button
--
---------------------------------------------------------------------
function PLDkpBidsFrame_ClickTab(tabID)

	if (tabID == 1) then
		_selectedTab = 1;
		PLDKP_debug("Clicked auction tab");
		
	
		CurBidsNameButton:Hide();
		CurBidsClassButton:Hide();
		CurBidsBidButton:Hide();
		CurBidsDKPButton:Hide();
		CurBidsListFrame:Hide();
		
		LastWinnersNameButton:Hide();
		LastWinnersItemButton:Hide();
		LastWinnersDateButton:Hide();
		LastWinnersPriceButton:Hide()
		LastWinnersListFrame:Hide();
		
		DKPListNameButton:Hide();
		DKPListClassButton:Hide();
		DKPListDKPButton:Hide();
		DKPListListFrame:Hide();
		
		DKPListListButton1:Hide();
		DKPListListButton2:Hide();
		DKPListListButton3:Hide();
		DKPListListButton4:Hide();
		DKPListListButton5:Hide();
		DKPListListButton6:Hide();

		CurBidsListButton1:Hide();
		CurBidsListButton2:Hide();
		CurBidsListButton3:Hide();
		CurBidsListButton4:Hide();
		CurBidsListButton5:Hide();
		CurBidsListButton6:Hide();
		
		LastWinnersListButton1:Hide();
		LastWinnersListButton2:Hide();
		LastWinnersListButton3:Hide();
		LastWinnersListButton4:Hide();
		LastWinnersListButton5:Hide();
		LastWinnersListButton6:Hide();
		
	
		if ( _pldkp_bidRunning ) then
			PLDKPFormAuctionTimeRemainingLabel:Show();
			PLDKPFormAuctionTimeRemainingNRLabel:Show();
			PLDKPFormAuctionAcceptTimeEdit:Hide();
			PLDKPFormAuctionMinDKPEdit:Hide();
			PLDKPFormAuctionAcceptTimeELLabel:Show();
			PLDKPFormAuctionMinDKPELLabel:Show();
			PLDKPFormAuctionAcceptTimeEditBtn:Hide();
			PLDKPFormAuctionMinDKPEditBtn:Hide();
			
			PLDKPFormAuctionWinner:Hide();
			
			--PLDKPFormAllowTwinkBids:Hide();
			PLDKPFormAllowTwinkBidsCheck:Disable();
		else
			PLDKPFormAuctionTimeRemainingLabel:Hide();
			PLDKPFormAuctionTimeRemainingNRLabel:Hide();
			PLDKPFormAuctionAcceptTimeEdit:Hide();
			PLDKPFormAuctionMinDKPEdit:Hide();
			PLDKPFormAuctionAcceptTimeELLabel:Hide();
			PLDKPFormAuctionMinDKPELLabel:Hide();
			PLDKPFormAuctionAcceptTimeEditBtn:Show();
			PLDKPFormAuctionMinDKPEditBtn:Show();
			
			--PLDKPFormAllowTwinkBids:Show();
			PLDKPFormAllowTwinkBidsCheck:Enable();
			
			PLDKPFormAuctionWinner:Show();
		end
		
		PLDKPFormAuctionWinnerLabel:Hide();
		
		PLDKPForm_ShowAuctionInfo();
	end
	
	if (tabID == 2) then
		_selectedTab = 2;
		PLDKP_debug("Clicked cur bids tab");
		
		PLDKPFormAuctionItemLabel:Hide();
		PLDKPFormAuctionItemLinkLabel:Hide();
		PLDKPFormAuctionItemButton:Hide();
		PLDKPFormAuctionAcceptTimeLabel:Hide();
		PLDKPFormAuctionMinDKPLabel:Hide();
		PLDKPFormAuctionAcceptTimeEdit:Hide();
		PLDKPFormAuctionMinDKPEdit:Hide();
		PLDKPFormAuctionAcceptTimeEditBtn:Hide();
		PLDKPFormAuctionMinDKPEditBtn:Hide();
		PLDKPFormAuctionAcceptTimeUnitLabel:Hide();
		PLDKPFormAuctionMinDKPUnitLabel:Hide();
		PLDKPFormStartStopAuction:Hide();
		PLDKPFormAuctionAcceptTimeELLabel:Hide();
		PLDKPFormAuctionMinDKPELLabel:Hide();
		PLDKPFormAuctionTimeRemainingLabel:Hide();
		PLDKPFormAuctionTimeRemainingNRLabel:Hide();
		PLDKPFormAuctionWinnerLabel:Hide();
		PLDKPForm_SetUIVisibility(false);
		
		PLDKPFormAllowTwinkBids:Hide();
		PLDKPFormAllowTwinkBidsCheck:Hide();
		
		
		CurBidsNameButton:Show();
		CurBidsClassButton:Show();
		CurBidsBidButton:Show();
		CurBidsDKPButton:Show();
		CurBidsListFrame:Show();
		
		LastWinnersNameButton:Hide();
		LastWinnersItemButton:Hide();
		LastWinnersDateButton:Hide();
		LastWinnersPriceButton:Hide()
		LastWinnersListFrame:Hide();
		
		DKPListNameButton:Hide();
		DKPListClassButton:Hide();
		DKPListDKPButton:Hide();
		DKPListListFrame:Hide();
		
		DKPListListButton1:Hide();
		DKPListListButton2:Hide();
		DKPListListButton3:Hide();
		DKPListListButton4:Hide();
		DKPListListButton5:Hide();
		DKPListListButton6:Hide();
		
		LastWinnersListButton1:Hide();
		LastWinnersListButton2:Hide();
		LastWinnersListButton3:Hide();
		LastWinnersListButton4:Hide();
		LastWinnersListButton5:Hide();
		LastWinnersListButton6:Hide();
		
		PLDkpBidsFrame_FillCurBids();
	end
	
	if (tabID == 3) then
		_selectedTab = 3;
		PLDKP_debug("Clicked last winners tab");
		
		PLDKPFormAuctionItemLabel:Hide();
		PLDKPFormAuctionItemLinkLabel:Hide();
		PLDKPFormAuctionItemButton:Hide();
		PLDKPFormAuctionAcceptTimeLabel:Hide();
		PLDKPFormAuctionMinDKPLabel:Hide();
		PLDKPFormAuctionAcceptTimeEdit:Hide();
		PLDKPFormAuctionMinDKPEdit:Hide();
		PLDKPFormAuctionAcceptTimeEditBtn:Hide();
		PLDKPFormAuctionMinDKPEditBtn:Hide();
		PLDKPFormAuctionAcceptTimeUnitLabel:Hide();
		PLDKPFormAuctionMinDKPUnitLabel:Hide();
		PLDKPFormStartStopAuction:Hide();
		PLDKPFormAuctionAcceptTimeELLabel:Hide();
		PLDKPFormAuctionMinDKPELLabel:Hide();
		PLDKPFormAuctionTimeRemainingLabel:Hide();
		PLDKPFormAuctionTimeRemainingNRLabel:Hide();
		PLDKPFormAuctionWinnerLabel:Hide();
		PLDKPForm_SetUIVisibility(false);
		
		PLDKPFormAllowTwinkBids:Hide();
		PLDKPFormAllowTwinkBidsCheck:Hide();
		
		CurBidsNameButton:Hide();
		CurBidsClassButton:Hide();
		CurBidsBidButton:Hide();
		CurBidsDKPButton:Hide();
		CurBidsListFrame:Hide();
		
		LastWinnersNameButton:Show();
		LastWinnersItemButton:Show();
		LastWinnersDateButton:Show();
		LastWinnersPriceButton:Show()
		LastWinnersListFrame:Show();
		
		DKPListNameButton:Hide();
		DKPListClassButton:Hide();
		DKPListDKPButton:Hide();
		DKPListListFrame:Hide();
		
		DKPListListButton1:Hide();
		DKPListListButton2:Hide();
		DKPListListButton3:Hide();
		DKPListListButton4:Hide();
		DKPListListButton5:Hide();
		DKPListListButton6:Hide();
		
		CurBidsListButton1:Hide();
		CurBidsListButton2:Hide();
		CurBidsListButton3:Hide();
		CurBidsListButton4:Hide();
		CurBidsListButton5:Hide();
		CurBidsListButton6:Hide();
		
		PLDkpBidsFrame_FillLastWinners();
	end
	
	if (tabID == 4) then
		_selectedTab = 4;
		PLDKP_debug("Clicked dkp-list tab");
		
		PLDKPFormAuctionItemLabel:Hide();
		PLDKPFormAuctionItemLinkLabel:Hide();
		PLDKPFormAuctionItemButton:Hide();
		PLDKPFormAuctionAcceptTimeLabel:Hide();
		PLDKPFormAuctionMinDKPLabel:Hide();
		PLDKPFormAuctionAcceptTimeEdit:Hide();
		PLDKPFormAuctionMinDKPEdit:Hide();
		PLDKPFormAuctionAcceptTimeEditBtn:Hide();
		PLDKPFormAuctionMinDKPEditBtn:Hide();
		PLDKPFormAuctionAcceptTimeUnitLabel:Hide();
		PLDKPFormAuctionMinDKPUnitLabel:Hide();
		PLDKPFormStartStopAuction:Hide();
		PLDKPFormAuctionAcceptTimeELLabel:Hide();
		PLDKPFormAuctionMinDKPELLabel:Hide();
		PLDKPFormAuctionTimeRemainingLabel:Hide();
		PLDKPFormAuctionTimeRemainingNRLabel:Hide();
		PLDKPFormAuctionWinnerLabel:Hide();
		PLDKPForm_SetUIVisibility(false);
		
		PLDKPFormAllowTwinkBids:Hide();
		PLDKPFormAllowTwinkBidsCheck:Hide();
		
		CurBidsNameButton:Hide();
		CurBidsClassButton:Hide();
		CurBidsBidButton:Hide();
		CurBidsDKPButton:Hide();
		CurBidsListFrame:Hide();
		
		LastWinnersNameButton:Hide();
		LastWinnersItemButton:Hide();
		LastWinnersDateButton:Hide();
		LastWinnersPriceButton:Hide()
		LastWinnersListFrame:Hide();
		
		DKPListNameButton:Show();
		DKPListClassButton:Show();
		DKPListDKPButton:Show();
		DKPListListFrame:Show();
		
		CurBidsListButton1:Hide();
		CurBidsListButton2:Hide();
		CurBidsListButton3:Hide();
		CurBidsListButton4:Hide();
		CurBidsListButton5:Hide();
		CurBidsListButton6:Hide();
		
		LastWinnersListButton1:Hide();
		LastWinnersListButton2:Hide();
		LastWinnersListButton3:Hide();
		LastWinnersListButton4:Hide();
		LastWinnersListButton5:Hide();
		LastWinnersListButton6:Hide();
		
		PLDkpBidsFrame_FillDKPList();
	end
end


---------------------------------------------------------------------
-- function PLDkpBidsFrame_UpdateDKPListScrollbars()
--
-- Called regulary to update scrollbars of the mod-list
---------------------------------------------------------------------
function PLDkpBidsFrame_UpdateDKPListScrollbars()

	if (_selectedTab == 2 ) then
		FauxScrollFrame_Update(CurBidsListFrame, PLDkpBidsFrame_CountBidEntries(), PLBDKP_BIDLIST_NR, PLBDKP_BID_HEIGHT);
	end
	
	if (_selectedTab == 3 ) then
		FauxScrollFrame_Update(LastWinnersListFrame, PLDkpBidsFrame_CountWinnerEntries(), PLBDKP_WINNERLIST_NR, PLBDKP_WINNER_HEIGHT);
	end
	
	if (_selectedTab == 4 ) then
		FauxScrollFrame_Update(DKPListListFrame, PLDKPBids:CountDKPEntries(), PLBDKP_DKPLIST_NR, PLBDKP_DKP_HEIGHT);
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_ShowOptions(elapsed)
--
-- Show options dialog
--
---------------------------------------------------------------------
function PLDkpBidsFrame_ShowOptions()
	ShowUIPanel(PLDkpBidsOptionFrame);
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_SaveVariables()
--
-- Show options dialog
--
---------------------------------------------------------------------
function PLDkpBidsFrame_SaveVariables()
	ReloadUI();
end



---------------------------------------------------------------------
-- function PLDKPForm_UpdateScrollbars()
--
-- Called regulary to update scrollbars of the mod-list
---------------------------------------------------------------------
function PLDKPForm_UpdateScrollbars()
	PLDkpBidsFrame_UpdateDKPListScrollbars();
end

---------------------------------------------------------------------
-- function PLDKPForm_UpdateSortArrowVisibility()
--
-- Hides sort arrows
---------------------------------------------------------------------
function PLDKPForm_UpdateSortArrowVisibility()

	-- hide Sorting arrows of the column headers
	
	--if (NameSortButtonArrow) then
	--	NameSortButtonArrow:Hide();
	--end
	--if (ActionSortButtonArrow) then
	--	ActionSortButtonArrow:Hide();
	--end
end

---------------------------------------------------------------------
-- function PLDKPForm_UpdateButtonVisibility()
--
-- Updates entry visibility of the mod-list
---------------------------------------------------------------------
function PLDKPForm_UpdateButtonVisibility()
	--for i = 1, 5 do
	--	local itemIndex = i + FauxScrollFrame_GetOffset(BossModsListFrame);
	--	PLBossModsListButton_SetVisible(i, (itemIndex <= PLBossMods_CountFilteredMods()));
	--end
end

---------------------------------------------------------------------
-- function PLDKPForm_UpdateButtonVisibility()
--
-- Updates entry visibility of the mod-list
---------------------------------------------------------------------
function PLDKPForm_SetUIVisibility(bInfoText)
	
	if(bInfoText) then
		PLDKPFormInfo:Show();
	else
		PLDKPFormInfo:Hide();
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_CountBidEntries()
--
-- gets the number of bids
---------------------------------------------------------------------
function PLDkpBidsFrame_CountBidEntries()
	local nRet = 0;
	
	if ( PLDKP_CurrentBids ~= nil ) then
		for pName in pairs(PLDKP_CurrentBids) do
			nRet = nRet + 1
		end
	end
	
	return nRet;
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_CountWinnerEntries()
--
-- gets the number of winners
---------------------------------------------------------------------
function PLDkpBidsFrame_CountWinnerEntries()
	local nRet = 0;
	
	if ( PLDKP_LastWinners ~= nil ) then
		for pDate in pairs(PLDKP_LastWinners) do
			nRet = nRet + 1
		end
	end
	
	return nRet;
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_FillDKPList()
--
-- fills the DKP-list
---------------------------------------------------------------------
function PLDkpBidsFrame_FillDKPList()
	--PLB_debug("FillModUI");
  	local nameOffset = FauxScrollFrame_GetOffset(DKPListListFrame);
	local nameIndex;
	
	for i=1, PLBDKP_DKPLIST_NR do
		local itemIndex = i + FauxScrollFrame_GetOffset(DKPListListFrame);
		
		--PLB_debug("UI i=" .. i .. ", itemIndex="..itemIndex..", tablecount="..table.getn(filteredMods));
		
		if (itemIndex <= PLDKPBids:CountDKPEntries()) then
			local pName = PLDkpBidsFrame_GetDKPPlayerByIndex(itemIndex);
			local className = PLDKPBids:PlayerGetDkpClass(pName)
			local curDkp = PLDKPBids:PlayerGetDkpData(pName)

			getglobal("DKPListListButton"..i.."Name"):SetText(pName);
			getglobal("DKPListListButton"..i.."Class"):SetText(className);
			getglobal("DKPListListButton"..i.."DKP"):SetText(curDkp);
			
			if ( curDkp >= 0 ) then
				getglobal("DKPListListButton"..i.."DKP"):SetTextColor(0,0.8196079,0);
			else
				getglobal("DKPListListButton"..i.."DKP"):SetTextColor(0.8196079,0,0);
			end

			getglobal("DKPListListButton"..i):Show();
		end
	end	
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_FillCurBids()
--
-- fills the current bids
---------------------------------------------------------------------
function PLDkpBidsFrame_FillCurBids()
  	local nameOffset = FauxScrollFrame_GetOffset(CurBidsListFrame);
	local nameIndex;
	
	for i=1, PLBDKP_BIDLIST_NR do
		local itemIndex = i + FauxScrollFrame_GetOffset(CurBidsListFrame);
		
		--PLB_debug("UI i=" .. i .. ", itemIndex="..itemIndex..", tablecount="..table.getn(filteredMods));
		
		if (itemIndex <= PLDkpBidsFrame_CountBidEntries()) then
			local pName = PLDkpBidsFrame_GetBidPlayerByIndex(itemIndex);
			
			local mainCharName = PLDkpBidsFrame_GetMainCharOfTwink(pName);
			
			getglobal("CurBidsListButton"..i.."Name"):SetText(pName);
			
			if ( PLDKPBids:PlayerHasDkpData(pName) ) then
				local curDkp = PLDKPBids:PlayerGetDkpData(pName)
				local className = PLDKPBids:PlayerGetDkpClass(pName)

				getglobal("CurBidsListButton"..i.."Class"):SetText(className);
				getglobal("CurBidsListButton"..i.."DKP"):SetText(curDkp);
				
				if ( curDkp >= 0 ) then
					getglobal("CurBidsListButton"..i.."DKP"):SetTextColor(0,0.8196079,0);
				else
					getglobal("CurBidsListButton"..i.."DKP"):SetTextColor(0.8196079,0,0);
				end
				
			else
				getglobal("CurBidsListButton"..i.."Class"):SetText(UnitClass(pName));
				getglobal("CurBidsListButton"..i.."DKP"):SetText("?");
				
				if ( PLDKPBids:PlayerHasDkpData(mainCharName) ) then
					local curDkp = PLDKPBids:PlayerGetDkpData(mainCharName)
				    local className = PLDKPBids:PlayerGetDkpClass(mainCharName)

					getglobal("CurBidsListButton"..i.."Class"):SetText(className);
					getglobal("CurBidsListButton"..i.."DKP"):SetText(curDkp);

					if ( curDkp >= 0 ) then
						getglobal("CurBidsListButton"..i.."DKP"):SetTextColor(0,0.8196079,0);
					else
						getglobal("CurBidsListButton"..i.."DKP"):SetTextColor(0.8196079,0,0);
					end

				end
			end
			
			if ( _pldkp_bidRunning == true ) then
				getglobal("CurBidsListButton"..i.."BID"):SetText("???");
			else
				getglobal("CurBidsListButton"..i.."BID"):SetText(PLDKP_CurrentBids[pName]);
			end
				
			getglobal("CurBidsListButton"..i):Show();
		end
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_FillLastWinners()
--
-- fills the last winners
---------------------------------------------------------------------
function PLDkpBidsFrame_FillLastWinners()
  	local nameOffset = FauxScrollFrame_GetOffset(LastWinnersListFrame);
	local nameIndex;
	
	for i=1, PLBDKP_WINNERLIST_NR do
		local itemIndex = i + FauxScrollFrame_GetOffset(LastWinnersListFrame);
		
		--PLB_debug("UI i=" .. i .. ", itemIndex="..itemIndex..", tablecount="..table.getn(filteredMods));
		
		if (itemIndex <= PLDkpBidsFrame_CountWinnerEntries()) then
			local sDate = PLDkpBidsFrame_GetLastWinnerByIndex(itemIndex);
			
			if ( sDate ~= nil ) then
				getglobal("LastWinnersListButton"..i.."Date"):SetText(sDate);
				getglobal("LastWinnersListButton"..i.."Name"):SetText(PLDKP_LastWinners[sDate]["Name"]);
				getglobal("LastWinnersListButton"..i.."Price"):SetText(PLDKP_LastWinners[sDate]["Price"]);
				
				--getglobal("LastWinnersListButton"..i.."Item"):SetText(PLDKP_LastWinners[sDate]["ItemName"]);
				
				getglobal("LastWinnersListButton"..i.."Item"):SetNormalTexture(PLDKP_LastWinners[sDate]["ItemTexture"]);
				getglobal("LastWinnersListButton"..i.."Item"):SetPushedTexture(PLDKP_LastWinners[sDate]["ItemTexture"]);
				getglobal("LastWinnersListButton"..i.."Item"):SetDisabledTexture(PLDKP_LastWinners[sDate]["ItemTexture"]);

				getglobal("LastWinnersListButton"..i):Show();
			end
		end
	end
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_GetBidPlayerByIndex(index)
--
-- Returns the playername by index
---------------------------------------------------------------------
function PLDkpBidsFrame_GetBidPlayerByIndex(index)
	local nCount=0;
	local playerName=nil;
	
	for pName in pairs(PLDKP_CurrentBids) do
		nCount=nCount+1;

		if(nCount==index) then
			playerName = pName;
		end
	end
	
	return playerName;
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_GetLastWinnerByIndex(index)
--
-- Returns the playername by index
---------------------------------------------------------------------
function PLDkpBidsFrame_GetLastWinnerByIndex(index)
	local nCount=0;
	local sEntryDate=nil;
	
	if ( PLDKP_LastWinners ~= nil ) then
		-- desc sorting with PLDKPBids_compareDesc()
		for sRaidID in PLDKPBids:pairsByKeys(PLDKP_LastWinners, PLDKPBids_compareDesc) do 
			nCount=nCount+1;

			if(nCount==index) then
				sEntryDate = sRaidID;
			end
		end
	end
	
	return sEntryDate;
end

---------------------------------------------------------------------
-- function PLDkpBidsFrame_GetLastWinnerByIndex(index)
--
-- Returns the playername by index
---------------------------------------------------------------------
function PLDkpBidsFrame_GetLastWinnerDataOfCurrentRaid(playerName, itemLink, itemCount, lootTime)
	local nCount=0;
	
	if ( PLDKP_LastWinners ~= nil ) then
		-- desc sorting with PLDKPBids_compareDesc()
		for sRaidID in PLDKPBids:pairsByKeys(PLDKP_LastWinners, PLDKPBids_compareDesc) do 
			local winnerData = PLDKP_LastWinners[sRaidId]

			if winnerData then
				local checkName, checkRealm, checkServerName = PLDKPBids:CharaterNameTranslation(playerName)
				local winnerName, winnerRealm, winnerServerName = PLDKPBids:CharaterNameTranslation(winnerData["Name"])

				if checkServerName == winnerServerName and itemLink ==  winnerData["ItemLink"] and winnerData["RaidID"] == PLDKP_CurrentRaidID then
					return winnerData
				end
			end
		end
	end
	
	return nil
end

-------------------------------------------------------------------------------
-- sheduling functions
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- function PLDkpBidsFrame_Schedule( nameOrFunction, timeUntil, optParam )
--
-- Function to schedule a function
-------------------------------------------------------------------------------
function PLDkpBidsFrame_Schedule(nameOrFunction, timeUntil, optParam)
	tinsert(PLDKP_ScheduledActions, { nameOrFunction, GetTime()+timeUntil, optParam });
end

-------------------------------------------------------------------------------
-- function PLDkpBidsFrame_Schedule( nameOrFunction, timeUntil, optParam )
--
-- Function to unschedule all functions where the first index is "name"
-------------------------------------------------------------------------------
function PLDkpBidsFrame_UnSchedule(name, optParam)
	for k, v in pairs(PLDKP_ScheduledActions) do
		if ( v[1] == name and ( not optParam or v[3] == optParam ) ) then
			tremove(PLDKP_ScheduledActions, k);
		end
	end
end

-------------------------------------------------------------------------------
-- DKP related functions
-------------------------------------------------------------------------------

---------------------------------------------------------------------
-- function PLDkpBidsFrame_GetDKPPlayerByIndex(index)
--
-- Returns the DKP-bject by indes
---------------------------------------------------------------------
function PLDkpBidsFrame_GetDKPPlayerByIndex(index)
	local nCount=0;
	local playerName=nil;
    
    if(PLDKPBids:IsDkpDataLoaded()) then
        for pName in PLDKPBids:pairsByKeys(PLDKPBids.dkp_data.players) do
            nCount=nCount+1;

            if(nCount==index) then
                playerName = pName;
            end
        end
    end
	
	return playerName;
end

---------------------------------------------------------------------
-- function PLDKP_FindAndAnswerPlayerDkp(name)
--
-- Search DKP value for given character name and respond with its DKP
-- twinks are supported
---------------------------------------------------------------------
function PLDKP_FindAndAnswerPlayerDkp(name)

    if(PLDKPBids:IsDkpDataLoaded() == false) then
		-- send no DKP data laoded
		return
    end

	PLDkpBidsFrame_GenerateTwinktranslationTable()

	PLDKP_debug("Name: " .. name)
	local incName, incRealm, incFullName = PLDKPBids:CharaterNameTranslation(name)
	PLDKP_debug("Name1: " .. incName)
	PLDKP_debug("Name2: " .. incRealm)
	PLDKP_debug("Name3: " .. incFullName)
	local mainChar = PLDkpBidsFrame_GetMainCharOfTwink(incName)
	PLDKP_debug("Main: " .. mainChar)

	pointUpdateDateInfo = PLDKP_DKPINFO_BEGINOFRAID

	if(PLDKPBids.dkp_info and PLDKPBids.dkp_info.date) then
		pointUpdateDateInfo = string.format(PLDKP_DKPINFO_LASTUPDATE, DKPInfo.date)
	end  
 
    if ( PLDKPBids:PlayerHasDkpData(incName) ) then
        local charDkp = PLDKPBids:PlayerGetDkpData(incName) 

		-- a main is requesting dkp
		PLDKP_sendWhisper(name, string.format(PLDKP_DKPINFO_SEND, charDkp, pointUpdateDateInfo))
		return
	else

		if( mainChar ~= incName) then
            if ( PLDKPBids:PlayerHasDkpData(mainChar) ) then
                local charDkp = PLDKPBids:PlayerGetDkpData(mainChar)

				-- a twink is requesting dkp
				PLDKP_sendWhisper(name, string.format(PLDKP_DKPINFO_TWINKDETECT, mainChar))	
				PLDKP_sendWhisper(name, string.format(PLDKP_DKPINFO_SENDTWINK, mainChar, charDkp, pointUpdateDateInfo))	
				return
			end
		else
            if ( PLDKPBids:PlayerHasDkpData(incName) ~= nil ) then
                local charDkp = PLDKPBids:PlayerGetDkpData(incName)

				-- a main is requesting dkp
				PLDKP_sendWhisper(name, string.format(PLDKP_DKPINFO_SEND, charDkp, pointUpdateDateInfo))	
				return
			end
		end
		
	end

	-- unkown player or no dkp
	PLDKP_sendWhisper(name, PLDKP_DKPINFO_PLAYERUNKNOWN)	
end


-------------------------------------------------------------------------------
-- printing functions
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- function PLDKP_debug( Message)
--
-- Prints a debug message
-------------------------------------------------------------------------------
function PLDKP_debug( Message)
	if ((PLDkpBidsOptions ~= nil) and (PLDkpBidsOptions["DebugMode"])) then
		DEFAULT_CHAT_FRAME:AddMessage(PLDKP_CHAT_WHITE .. Message .. PLDKP_CHAT_END, 0.1, 0.1, 1);
	end
end

-------------------------------------------------------------------------------
-- function PLDKP_println( Message)
--
-- Prints a chatframe message
-------------------------------------------------------------------------------
function PLDKP_println( Message)
	if (PLDKP_PrintAll) then
		DEFAULT_CHAT_FRAME:AddMessage(PLDKP_CHAT_YELLOW .. Message .. PLDKP_CHAT_END, 1, 1, 1);
	end
end

-------------------------------------------------------------------------------
-- function PLDKP_info( Message)
--
-- Prints a chatframe message
-------------------------------------------------------------------------------
function PLDKP_info( Message)
	DEFAULT_CHAT_FRAME:AddMessage(PLDKP_CHAT_BLUE .. Message .. PLDKP_CHAT_END, 1, 1, 1);
end
-------------------------------------------------------------------------------
-- function PLDKP_errln( Message)
--
-- Prints an error message
-------------------------------------------------------------------------------
function PLDKP_errln( Message)
	if (PLDKP_PrintError) then
		DEFAULT_CHAT_FRAME:AddMessage(PLDKP_CHAT_RED .. Message .. PLDKP_CHAT_END, 1, 0.1, 0.1);
	end
end

-------------------------------------------------------------------------------
-- function PLDKP_screen( Message)
--
-- Prints a message within the error screen.
-------------------------------------------------------------------------------
function PLDKP_screen( Message )
	UIErrorsFrame:AddMessage(Message, 1.0, 1.0, 0.0, 1.0, UIERRORS_HOLD_TIME);
end


-------------------------------------------------------------------------------
-- function PLDKP_ShowSlashHelp( Message)
--
-- Prints a message within the error screen.
-------------------------------------------------------------------------------
function PLDKP_ShowSlashHelp()
	
	for i = 1, table.getn(PLDKP_HelpTable) do
		PLDKP_println( PLDKP_HelpTable[i] );
	end
end