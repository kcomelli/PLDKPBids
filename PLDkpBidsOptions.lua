-------------------------------------------------------------------------------
-- PL DKP Bids Options Frame
--
-- Author: Fuddler/Gimmeurgold - Primal Legion @ Destromath-EU
-- Version: 3.0
-- 
-------------------------------------------------------------------------------

local _, PLDKPBids = ...

---------------------------------------------------------------------
-- event handlersand hooks Options Frame
---------------------------------------------------------------------
---------------------------------------------------------------------
-- function PLDkpBidsOptionFrame_OnLoad()
--
-- Called when the Mod-Frame is loaded
--
-- Initializes the AddOn and registers for common events
---------------------------------------------------------------------
function PLDkpBidsOptionFrame_OnLoad()
	PLDkpBidsOptionFrame:RegisterEvent("VARIABLES_LOADED");
end

---------------------------------------------------------------------
-- function PLDkpBidsOptionFrame_OnEvent(event)
--
-- Default eventhandler for the Frame
--
-- Handels events for all Mods
---------------------------------------------------------------------
function PLDkpBidsOptionFrame_OnEvent(event)
	local playerName = UnitName("player");
	
	if (event == "VARIABLES_LOADED") then
		
		if ( PLDkpBidsOptions == nil) then
			PLDkpBids_InitOptions();
		end
		
		PLDkpBidsOptionFrameHeaderString:SetText( PLDKP_OPTIONS_UI_HEADER );
		PLDkpBidsOptionFrameCloseButton:SetText( PLDKP_OPTIONS_CLOSE );
		
		PLDkpBidsOptionFrameAuctionAcceptTimeLabel:SetText(PLDKP_OPTIONS_DEF_TS);
		PLDkpBidsOptionFrameAuctionMinDKPLabel:SetText(PLDKP_OPTIONS_DEF_MINDP);
		
		PLDkpBidsOptionFrameAuctionAcceptTimeUnitLabel:SetText(PLDKP_LABEL_TIMESEC);
		PLDkpBidsOptionFrameAuctionMinDKPUnitLabel:SetText(PLDKP_LABEL_DKP);
		
		PLDkpBidsOptionFrameAuctionAcceptTimeEdit:Hide();
		PLDkpBidsOptionFrameAuctionMinDKPEdit:Hide();
		
		PLDkpBidsOptionFrameAuctionMinDKPEditBtn:SetText(PLDkpBidsOptions["DefaultMinDKP"]);
		PLDkpBidsOptionFrameAuctionAcceptTimeEditBtn:SetText(PLDkpBidsOptions["DefBidTSpan"]);
		
		PLDkpBidsOptionFrameValueAddLabel:SetText(PLDKP_OPTIONS_VAL_ADD);
		PLDkpBidsOptionFrameValueAddUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameValueAddEdit:Hide();
		PLDkpBidsOptionFrameValueAddEditBtn:SetText(PLDkpBidsOptions["PriceAddVal"]);
		
		PLDkpBidsOptionFrameValueStepLabel:SetText(PLDKP_OPTIONS_VAL_STEP);
		PLDkpBidsOptionFrameValueStepUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameValueStepEdit:Hide();
		PLDkpBidsOptionFrameValueStepEditBtn:SetText(PLDkpBidsOptions["ValueStep"]);
		

		
	
		PLDkpBidsOptionFrameAllowMinBidLabel:SetText(PLDKP_OPTIONS_ALLOW_MINBID);
		PLDkpBidsOptionFrameAllowMinBidCheck:SetChecked(PLDkpBidsOptions["AllwaysAllowMinBid"]);
		
		PLDkpBidsOptionFrameAllowHighOverwriteLabel:SetText(PLDKP_OPTIONS_ALLOW_HIGHOV);
		PLDkpBidsOptionFrameAllowHighOverwriteCheck:SetChecked(PLDkpBidsOptions["AllowHigherBidOverwrite"]);
		
		PLDkpBidsOptionFrameRaidWarningLabel:SetText(PLDKP_OPTIONS_RAIDWARNING);
		PLDkpBidsOptionFrameRaidWarningCheck:SetChecked(PLDkpBidsOptions["ShowCountDownInRaidWarning"]);
		
		PLDkpBidsOptionFrameAllowDeleteLabel:SetText(PLDKP_OPTIONS_ALLOWDELETE);
		PLDkpBidsOptionFrameAllowDeleteCheck:SetChecked(PLDkpBidsOptions["AllowBidDelete"]);
		
		PLDkpBidsOptionFrameDKPonEqualBidsLabel:SetText(PLDKP_OPTIONS_USEDKPONEQUAL);
		PLDkpBidsOptionFrameDKPonEqualBidsCheck:SetChecked(PLDkpBidsOptions["UseDKPOnEqualBids"]);
		
		PLDkpBidsOptionFrameHighBidsLabel:SetText(PLDKP_OPTIONS_ALLOWMAXDKPBIDS);
		PLDkpBidsOptionFrameHighBidsCheck:SetChecked(PLDkpBidsOptions["AllowBidsGreaterThanDKP"]);
		
		PLDkpBidsOptionFrameMaxMinusDKPLabel:SetText(PLDKP_OPTIONS_MAXMINUSDKP);
		PLDkpBidsOptionFrameMaxMinusDKPUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameMaxMinusDKPEdit:Hide();
		PLDkpBidsOptionFrameMaxMinusDKPEditBtn:SetText(PLDkpBidsOptions["MaxMinusDKP"]);
		
		PLDkpBidsOptionFrameDKPAddOnNotInstalledLabel:SetText(PLDKP_OPTIONS_NODKPPOINTS);
		
		if ( PLDKPBids:IsDkpDataLoaded() == false ) then
			-- GetDKP is not installed
			PLDkpBidsOptionFrameDKPonEqualBidsLabel:Hide();
			PLDkpBidsOptionFrameDKPonEqualBidsCheck:Hide();
			
			PLDkpBidsOptionFrameHighBidsLabel:Hide();
			PLDkpBidsOptionFrameHighBidsCheck:Hide();
			
			PLDkpBidsOptionFrameMaxMinusDKPLabel:Hide();
			PLDkpBidsOptionFrameMaxMinusDKPUnitLabel:Hide();
			PLDkpBidsOptionFrameMaxMinusDKPEditBtn:Hide();
		else
			PLDkpBidsOptionFrameDKPAddOnNotInstalledLabel:Hide()
		end
		
		UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, 1);
		
		PLDkpBidsOptionFrameChannelLabel:SetText(PLDKP_OPTIONS_ANNCHANNEL);
		if ( PLDkpBidsOptions["AnnounceChannel"] == "AUTO" ) then
			UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, 1);
			UIDropDownMenu_SetText(PLDkpBidsOptionFrameChannelDropDown, "AUTO");
		elseif ( PLDkpBidsOptions["AnnounceChannel"] == "RAID" ) then
			UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, 2);
			UIDropDownMenu_SetText(PLDkpBidsOptionFrameChannelDropDown, "RAID");
		elseif ( PLDkpBidsOptions["AnnounceChannel"] == "PARTY" ) then
			UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, 3);
			UIDropDownMenu_SetText(PLDkpBidsOptionFrameChannelDropDown, "PARTY");
		elseif ( PLDkpBidsOptions["AnnounceChannel"] == "GUILD" ) then
			UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, 4);
			UIDropDownMenu_SetText(PLDkpBidsOptionFrameChannelDropDown, "GUILD");
		elseif ( PLDkpBidsOptions["AnnounceChannel"] == "SAY" ) then
			UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, 5);
			UIDropDownMenu_SetText(PLDkpBidsOptionFrameChannelDropDown, "SAY");
		end
	end
end

function PLDkpBidsOptionsFrame_AcceptTimeEditESC()
	PLDkpBidsOptionFrameAuctionAcceptTimeEdit:Hide();
	PLDkpBidsOptionFrameAuctionAcceptTimeEdit:SetText(PLDkpBidsOptions["DefBidTSpan"]);
	PLDkpBidsOptionFrameAuctionAcceptTimeEditBtn:Show();
end

function PLDkpBidsOptionsFrame_AcceptTimeEditENTER()
	PLDkpBidsOptionFrameAuctionAcceptTimeEdit:Hide();
	tmp = PLDkpBidsOptionFrameAuctionAcceptTimeEdit:GetText();
	if( tonumber(tmp) ~= nil ) then
		PLDkpBidsOptions["DefBidTSpan"] = tonumber(tmp);
	end
	PLDkpBidsOptionFrameAuctionAcceptTimeEditBtn:SetText(PLDkpBidsOptions["DefBidTSpan"]);
	PLDkpBidsOptionFrameAuctionAcceptTimeEditBtn:Show();
end

function PLDkpBidsOptionsFrame_MinDKPEditESC()
	PLDkpBidsOptionFrameAuctionMinDKPEdit:Hide();
	PLDkpBidsOptionFrameAuctionMinDKPEdit:SetText(PLDkpBidsOptions["DefaultMinDKP"]);
	PLDkpBidsOptionFrameAuctionMinDKPEditBtn:Show();
end

function PLDkpBidsOptionsFrame_MinDKPEditENTER()
	PLDkpBidsOptionFrameAuctionMinDKPEdit:Hide();
	tmp = PLDkpBidsOptionFrameAuctionMinDKPEdit:GetText();
	if( tonumber(tmp) ~= nil ) then
		PLDkpBidsOptions["DefaultMinDKP"] = tonumber(tmp);
	end
	PLDkpBidsOptionFrameAuctionMinDKPEditBtn:SetText(PLDkpBidsOptions["DefaultMinDKP"]);
	PLDkpBidsOptionFrameAuctionMinDKPEditBtn:Show();
end

function PLDkpBidsOptionsFrame_ShowMinDKPEdit()
	PLDkpBidsOptionFrameAuctionMinDKPEdit:SetText(PLDkpBidsOptions["DefaultMinDKP"]);
	PLDkpBidsOptionFrameAuctionMinDKPEdit:Show();
	PLDkpBidsOptionFrameAuctionMinDKPEditBtn:Hide();
end

function PLDkpBidsOptionsFrame_ShowAcceptTimeEdit()
	PLDkpBidsOptionFrameAuctionAcceptTimeEdit:SetText(PLDkpBidsOptions["DefBidTSpan"]);
	PLDkpBidsOptionFrameAuctionAcceptTimeEdit:Show();
	PLDkpBidsOptionFrameAuctionAcceptTimeEditBtn:Hide();
end

function PLDkpBidsOptionsFrame_ValueAddEditESC()
	PLDkpBidsOptionFrameValueAddEdit:Hide();
	PLDkpBidsOptionFrameValueAddEdit:SetText(PLDkpBidsOptions["PriceAddVal"]);
	PLDkpBidsOptionFrameValueAddEditBtn:Show();
end
function PLDkpBidsOptionsFrame_ValueAddEditENTER()
	PLDkpBidsOptionFrameValueAddEdit:Hide();
	tmp = PLDkpBidsOptionFrameValueAddEdit:GetText();
	if( tonumber(tmp) ~= nil ) then
		PLDkpBidsOptions["PriceAddVal"] = tonumber(tmp);
	end
	PLDkpBidsOptionFrameValueAddEditBtn:SetText(PLDkpBidsOptions["PriceAddVal"]);
	PLDkpBidsOptionFrameValueAddEditBtn:Show();
end
function PLDkpBidsOptionsFrame_ShowValueAddEdit()
	PLDkpBidsOptionFrameValueAddEdit:SetText(PLDkpBidsOptions["PriceAddVal"]);
	PLDkpBidsOptionFrameValueAddEdit:Show();
	PLDkpBidsOptionFrameValueAddEditBtn:Hide();
end

function PLDkpBidsOptionsFrame_ValueStepEditESC()
	PLDkpBidsOptionFrameValueStepEdit:Hide();
	PLDkpBidsOptionFrameValueStepEdit:SetText(PLDkpBidsOptions["ValueStep"]);
	PLDkpBidsOptionFrameValueStepEditBtn:Show();
end
function PLDkpBidsOptionsFrame_ValueStepEditENTER()
	PLDkpBidsOptionFrameValueStepEdit:Hide();
	tmp = PLDkpBidsOptionFrameValueStepEdit:GetText();
	if( tonumber(tmp) ~= nil ) then
		PLDkpBidsOptions["ValueStep"] = tonumber(tmp);
	end
	PLDkpBidsOptionFrameValueStepEditBtn:SetText(PLDkpBidsOptions["ValueStep"]);
	PLDkpBidsOptionFrameValueStepEditBtn:Show();
end
function PLDkpBidsOptionsFrame_ShowValueStepEdit()
	PLDkpBidsOptionFrameValueStepEdit:SetText(PLDkpBidsOptions["ValueStep"]);
	PLDkpBidsOptionFrameValueStepEdit:Show();
	PLDkpBidsOptionFrameValueStepEditBtn:Hide();
end

function PLDkpBidsOptionChannelDropDown_OnLoad()
	UIDropDownMenu_Initialize(PLDkpBidsOptionFrameChannelDropDown, PLDkpBidsOptionChannelDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, 1);
	UIDropDownMenu_SetWidth(PLDkpBidsOptionFrameChannelDropDown, 90);
end

function PLDkpBidsOptionChannelDropDown_Initialize()
	local info;

	info = {
		text = "AUTO";
		func = PLDkpBidsOptionChannelDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
	
	info = {
		text = "RAID";
		func = PLDkpBidsOptionChannelDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
	
	info = {
		text = "PARTY";
		func = PLDkpBidsOptionChannelDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
	
	info = {
		text = "GUILD";
		func = PLDkpBidsOptionChannelDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
	
	info = {
		text = "SAY";
		func = PLDkpBidsOptionChannelDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
end

function PLDkpBidsOptionChannelDropDown_OnClick(self)

	local oldID = UIDropDownMenu_GetSelectedID(PLDkpBidsOptionFrameChannelDropDown);
	UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameChannelDropDown, self:GetID());
	
	if(oldID ~= self:GetID()) then
		
		if ( self:GetID() == 1 ) then
			PLDkpBidsOptions["AnnounceChannel"] = "AUTO";
		elseif ( self:GetID() == 2 ) then
			PLDkpBidsOptions["AnnounceChannel"] = "RAID";
		elseif ( self:GetID() == 3 ) then
			PLDkpBidsOptions["AnnounceChannel"] = "PARTY";
		elseif ( self:GetID() == 4 ) then
			PLDkpBidsOptions["AnnounceChannel"] = "GUILD";
		elseif ( self:GetID() == 5 ) then
			PLDkpBidsOptions["AnnounceChannel"] = "SAY";
		end
	end
end

function PLDkpBidsOptionsFrame_AllowMinBidClick()
	PLDkpBidsOptions["AllwaysAllowMinBid"] = not PLDkpBidsOptions["AllwaysAllowMinBid"];
end

function PLDkpBidsOptionsFrame_AllowHighOverwriteClick()
	PLDkpBidsOptions["AllowHigherBidOverwrite"] = not PLDkpBidsOptions["AllowHigherBidOverwrite"];
end

function PLDkpBidsOptionsFrame_RaidWarningClick()
	PLDkpBidsOptions["ShowCountDownInRaidWarning"] = not PLDkpBidsOptions["ShowCountDownInRaidWarning"];
end

function PLDkpBidsOptionsFrame_AllowDeleteClick()
	PLDkpBidsOptions["AllowBidDelete"] = not PLDkpBidsOptions["AllowBidDelete"];
end

function PLDkpBidsOptionsFrame_DKPonEqualBidsClick()
	PLDkpBidsOptions["UseDKPOnEqualBids"] = not PLDkpBidsOptions["UseDKPOnEqualBids"];
end

function PLDkpBidsOptionsFrame_HighBidsClick()
	PLDkpBidsOptions["AllowBidsGreaterThanDKP"] = not PLDkpBidsOptions["AllowBidsGreaterThanDKP"];
end

function PLDkpBidsOptionsFrame_MaxMinusDKPEditESC()
	PLDkpBidsOptionFrameMaxMinusDKPEdit:Hide();
	PLDkpBidsOptionFrameMaxMinusDKPEdit:SetText(PLDkpBidsOptions["MaxMinusDKP"]);
	PLDkpBidsOptionFrameMaxMinusDKPEditBtn:Show();
end
function PLDkpBidsOptionsFrame_MaxMinusDKPEditENTER()
	PLDkpBidsOptionFrameMaxMinusDKPEdit:Hide();
	tmp = PLDkpBidsOptionFrameMaxMinusDKPEdit:GetText();
	if( tonumber(tmp) ~= nil ) then
		PLDkpBidsOptions["MaxMinusDKP"] = tonumber(tmp);
	end
	PLDkpBidsOptionFrameMaxMinusDKPEditBtn:SetText(PLDkpBidsOptions["MaxMinusDKP"]);
	PLDkpBidsOptionFrameMaxMinusDKPEditBtn:Show();
end
function PLDkpBidsOptionsFrame_ShowMaxMinusDKPEdit()
	PLDkpBidsOptionFrameMaxMinusDKPEdit:SetText(PLDkpBidsOptions["MaxMinusDKP"]);
	PLDkpBidsOptionFrameMaxMinusDKPEdit:Show();
	PLDkpBidsOptionFrameMaxMinusDKPEditBtn:Hide();
end