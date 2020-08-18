-------------------------------------------------------------------------------
-- PL DKP Bids Options Frame
--
-- Author: Fuddler/Gimmeurgold - Primal Legion @ Destromath-EU
-- Version: 3.0
-- 
-------------------------------------------------------------------------------

local _, PLDKPBids = ...

local selectedMinDKPZoneName = "Default"
PLBDKP_SPECIALITEM_LIST_NR = 4
PLBDKP_SPECIAL_HEIGHT = 20

StaticPopupDialogs["PLBDKP_POPUP_OPTION_DELETE_CONFIRM"] = {
    text = PLDKP_OPTIONS_PRICEDELETE_CONFIRM,
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        PLDkpBidsOptions["MinDKPSpecial"][self.data] = nil
		PLDKPBidsOptionsFrame_FillSpecialPrices()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
  }

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
		
		
	end
end

function PLDkpBidsOptionFrame_OnShow()
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
		

		PLDkpBidsOptionFrameMinDKPEquipLabel:SetText(PLDKP_OPTIONS_MINDKP_EQUIP);
		PLDkpBidsOptionFrameMinDKPEquipUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameMinDKPEquipEdit:Hide();

		PLDkpBidsOptionFrameMinDKPSetEquipLabel:SetText(PLDKP_OPTIONS_MINDKP_SET);
		PLDkpBidsOptionFrameMinDKPSetEquipUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameMinDKPSetEquipEdit:Hide();

		PLDkpBidsOptionFrameMinDKPOneHandLabel:SetText(PLDKP_OPTIONS_MINDKP_OH);
		PLDkpBidsOptionFrameMinDKPOneHandUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameMinDKPOneHandEdit:Hide();

		PLDkpBidsOptionFrameMinDKPTwoHandLabel:SetText(PLDKP_OPTIONS_MINDKP_TH);
		PLDkpBidsOptionFrameMinDKPTwoHandUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameMinDKPTwoHandEdit:Hide();

		PLDkpBidsOptionFrameMinDKPSetTokenLabel:SetText(PLDKP_OPTIONS_MINDKP_SETTOKEN);
		PLDkpBidsOptionFrameMinDKPSetTokenUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameMinDKPSetTokenEdit:Hide();

		PLDkpBidsOptionFrameMinDKPSetTokenWeaponLabel:SetText(PLDKP_OPTIONS_MINDKP_SETTOKENWEAPON);
		PLDkpBidsOptionFrameMinDKPSetTokenWeaponUnitLabel:SetText(PLDKP_LABEL_DKP);
		PLDkpBidsOptionFrameMinDKPSetTokenWeaponEdit:Hide();

	
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

		PLDkpBidsOptionFrameEnableDebugLabel:SetText(PLDKP_OPTIONS_DEBUG_MODE);
		PLDkpBidsOptionFrameEnableDebugCheck:SetChecked(PLDkpBidsOptions["DebugMode"]);
		
		PLDkpBidsOptionFrameDKPAddOnNotInstalledLabel:SetText(PLDKP_OPTIONS_NODKPPOINTS);

		PLDkpBidsOptionFrameSyncDKPSettings:SetText(PLDKP_OPTIONS_SEND_DKP_SETTINGS);
		PLDkpBidsOptionFrameResetToDefaultsBtn:SetText(PLDKP_OPTIONS_RESET_ZONEDKP_DEFAULTS);
		PLDkpBidsOptionFrameResetToDefaultsBtn:Hide();
		
		if (PLDKPBids.IsOfficer) then
			PLDkpBidsOptionFrameSyncDKPSettings:Show();
		else
			PLDkpBidsOptionFrameSyncDKPSettings:Hide();
		end

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

		PLDkpBidsOptionFrameMinDKPZoneLabel:SetText(PLDKP_OPTIONS_MINDKPZONE);
		UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameMinDKPZoneDropDown, 1);
		UIDropDownMenu_SetText(PLDkpBidsOptionFrameMinDKPZoneDropDown, selectedMinDKPZoneName);

		PLDkpBidsOptionsFrame_FillMinDkpOfZone(selectedMinDKPZoneName)

		PLDKPBidsOptionsFrame_FillSpecialPrices()
end

function PLDkpBidsOptionsFrame_FillMinDkpOfZone(zoneName)

	if(PLDkpBidsOptions["MinDKPPerZone"] and PLDkpBidsOptions["MinDKPPerZone"][zoneName]) then
		PLDkpBidsOptionFrameMinDKPEquipEditBtn:SetText(PLDkpBidsOptions["MinDKPPerZone"][zoneName]["MinDKPEquip"] or PLDkpBidsOptions["MinDKPEquip"]);
		PLDkpBidsOptionFrameMinDKPSetEquipEditBtn:SetText(PLDkpBidsOptions["MinDKPPerZone"][zoneName]["MinDKPSetEquip"] or PLDkpBidsOptions["MinDKPSetEquip"]);
		PLDkpBidsOptionFrameMinDKPOneHandEditBtn:SetText(PLDkpBidsOptions["MinDKPPerZone"][zoneName]["MinDKPOneHand"] or PLDkpBidsOptions["MinDKPOneHand"]);
		PLDkpBidsOptionFrameMinDKPTwoHandEditBtn:SetText(PLDkpBidsOptions["MinDKPPerZone"][zoneName]["MinDKPTwoHand"] or PLDkpBidsOptions["MinDKPTwoHand"]);
		PLDkpBidsOptionFrameMinDKPSetTokenEditBtn:SetText(PLDkpBidsOptions["MinDKPPerZone"][zoneName]["MinDKPSetToken"] or PLDkpBidsOptions["MinDKPSetToken"]);
		PLDkpBidsOptionFrameMinDKPSetTokenWeaponEditBtn:SetText(PLDkpBidsOptions["MinDKPPerZone"][zoneName]["MinDKPSetTokenWeapon"] or PLDkpBidsOptions["MinDKPSetTokenWeapon"]);
		PLDkpBidsOptionFrameResetToDefaultsBtn:Show();
	else
    	PLDkpBidsOptionFrameMinDKPEquipEditBtn:SetText(PLDkpBidsOptions["MinDKPEquip"]);
		PLDkpBidsOptionFrameMinDKPSetEquipEditBtn:SetText(PLDkpBidsOptions["MinDKPSetEquip"]);
		PLDkpBidsOptionFrameMinDKPOneHandEditBtn:SetText(PLDkpBidsOptions["MinDKPOneHand"]);
		PLDkpBidsOptionFrameMinDKPTwoHandEditBtn:SetText(PLDkpBidsOptions["MinDKPTwoHand"]);
		PLDkpBidsOptionFrameMinDKPSetTokenEditBtn:SetText(PLDkpBidsOptions["MinDKPSetToken"]);
		PLDkpBidsOptionFrameMinDKPSetTokenWeaponEditBtn:SetText(PLDkpBidsOptions["MinDKPSetTokenWeapon"]);
		PLDkpBidsOptionFrameResetToDefaultsBtn:Hide();
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

function PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(editing)
	if (PLDKPBids:HasCustomizedZoneDKP(selectedMinDKPZoneName) and editing == false) then
		PLDkpBidsOptionFrameResetToDefaultsBtn:Show();
	else
		PLDkpBidsOptionFrameResetToDefaultsBtn:Hide();
	end
end

function PLDkpBidsOptionsFrame_MinDKPEquipESC()
	PLDkpBidsOptionFrameMinDKPEquipEdit:Hide();
	PLDkpBidsOptionFrameMinDKPEquipEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPEquip"));
	PLDkpBidsOptionFrameMinDKPEquipEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_MinDKPEquipENTER()
	PLDkpBidsOptionFrameMinDKPEquipEdit:Hide();
	tmp = PLDkpBidsOptionFrameMinDKPEquipEdit:GetText();
	PLDKPBids:SetMinDkpOption(selectedMinDKPZoneName, "MinDKPEquip", tonumber(tmp))
	PLDkpBidsOptionFrameMinDKPEquipEditBtn:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPEquip"));
	PLDkpBidsOptionFrameMinDKPEquipEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_ShowMinDKPEquipEdit()
	PLDkpBidsOptionFrameMinDKPEquipEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPEquip"));
	PLDkpBidsOptionFrameMinDKPEquipEdit:Show();
	PLDkpBidsOptionFrameMinDKPEquipEditBtn:Hide();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Disable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(true);
end

function PLDkpBidsOptionsFrame_MinDKPSetEquipESC()
	PLDkpBidsOptionFrameMinDKPSetEquipEdit:Hide();
	PLDkpBidsOptionFrameMinDKPSetEquipEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetEquip"));
	PLDkpBidsOptionFrameMinDKPSetEquipEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_MinDKPSetEquipENTER()
	PLDkpBidsOptionFrameMinDKPSetEquipEdit:Hide();
	tmp = PLDkpBidsOptionFrameMinDKPSetEquipEdit:GetText();
	PLDKPBids:SetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetEquip", tonumber(tmp))
	PLDkpBidsOptionFrameMinDKPSetEquipEditBtn:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetEquip"));
	PLDkpBidsOptionFrameMinDKPSetEquipEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_ShowMinDKPSetEquipEdit()
	PLDkpBidsOptionFrameMinDKPSetEquipEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetEquip"));
	PLDkpBidsOptionFrameMinDKPSetEquipEdit:Show();
	PLDkpBidsOptionFrameMinDKPSetEquipEditBtn:Hide();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Disable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(true);
end


function PLDkpBidsOptionsFrame_MinDKPOneHandESC()
	PLDkpBidsOptionFrameMinDKPOneHandEdit:Hide();
	PLDkpBidsOptionFrameMinDKPOneHandEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPOneHand"));
	PLDkpBidsOptionFrameMinDKPOneHandEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_MinDKPOneHandENTER()
	PLDkpBidsOptionFrameMinDKPOneHandEdit:Hide();
	tmp = PLDkpBidsOptionFrameMinDKPOneHandEdit:GetText();
	PLDKPBids:SetMinDkpOption(selectedMinDKPZoneName, "MinDKPOneHand", tonumber(tmp))
	PLDkpBidsOptionFrameMinDKPOneHandEditBtn:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPOneHand"));
	PLDkpBidsOptionFrameMinDKPOneHandEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_ShowMinDKPOneHandEdit()
	PLDkpBidsOptionFrameMinDKPOneHandEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPOneHand"));
	PLDkpBidsOptionFrameMinDKPOneHandEdit:Show();
	PLDkpBidsOptionFrameMinDKPOneHandEditBtn:Hide();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Disable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(true);
end

function PLDkpBidsOptionsFrame_MinDKPTwoHandESC()
	PLDkpBidsOptionFrameMinDKPTwoHandEdit:Hide();
	PLDkpBidsOptionFrameMinDKPTwoHandEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPTwoHand"));
	PLDkpBidsOptionFrameMinDKPTwoHandEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_MinDKPTwoHandENTER()
	PLDkpBidsOptionFrameMinDKPTwoHandEdit:Hide();
	tmp = PLDkpBidsOptionFrameMinDKPTwoHandEdit:GetText();
	PLDKPBids:SetMinDkpOption(selectedMinDKPZoneName, "MinDKPTwoHand", tonumber(tmp))
	PLDkpBidsOptionFrameMinDKPTwoHandEditBtn:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPTwoHand"));
	PLDkpBidsOptionFrameMinDKPTwoHandEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_ShowMinDKPTwoHandEdit()
	PLDkpBidsOptionFrameMinDKPTwoHandEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPTwoHand"));
	PLDkpBidsOptionFrameMinDKPTwoHandEdit:Show();
	PLDkpBidsOptionFrameMinDKPTwoHandEditBtn:Hide();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Disable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(true);
end

function PLDkpBidsOptionsFrame_MinDKPSetTokenESC()
	PLDkpBidsOptionFrameMinDKPSetTokenEdit:Hide();
	PLDkpBidsOptionFrameMinDKPSetTokenEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetToken"));
	PLDkpBidsOptionFrameMinDKPSetTokenEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_MinDKPSetTokenENTER()
	PLDkpBidsOptionFrameMinDKPSetTokenEdit:Hide();
	tmp = PLDkpBidsOptionFrameMinDKPSetTokenEdit:GetText();
	PLDKPBids:SetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetToken", tonumber(tmp))
	PLDkpBidsOptionFrameMinDKPSetTokenEditBtn:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetToken"));
	PLDkpBidsOptionFrameMinDKPSetTokenEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_ShowMinDKPSetTokenEdit()
	PLDkpBidsOptionFrameMinDKPSetTokenEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetToken"));
	PLDkpBidsOptionFrameMinDKPSetTokenEdit:Show();
	PLDkpBidsOptionFrameMinDKPSetTokenEditBtn:Hide();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Disable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(true);
end

function PLDkpBidsOptionsFrame_MinDKPSetTokenWeaponESC()
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEdit:Hide();
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetTokenWeapon"));
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_MinDKPSetTokenWeaponENTER()
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEdit:Hide();
	tmp = PLDkpBidsOptionFrameMinDKPSetTokenWeaponEdit:GetText();
	PLDKPBids:SetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetTokenWeapon", tonumber(tmp))
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEditBtn:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetTokenWeapon"));
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEditBtn:Show();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Enable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(false);
end
function PLDkpBidsOptionsFrame_ShowMinDKPSetTokenWeaponEdit()
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEdit:SetText(PLDKPBids:GetMinDkpOption(selectedMinDKPZoneName, "MinDKPSetTokenWeapon"));
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEdit:Show();
	PLDkpBidsOptionFrameMinDKPSetTokenWeaponEditBtn:Hide();
	PLDkpBidsOptionFrameMinDKPZoneDropDown:Disable();
	PLDkpBidsOptionsFrame_AdjustResetDkpBtnForZone(true);
end

function PLDkpBidsOptionsFrame_ToggleDebugModeClick()
	PLDkpBidsOptions["DebugMode"] = not PLDkpBidsOptions["DebugMode"];
end

function PLDkpBidsOptionMinDkpZoneDropDown_OnLoad()
	UIDropDownMenu_Initialize(PLDkpBidsOptionFrameMinDKPZoneDropDown, PLDkpBidsOptionMinDKPZoneDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameMinDKPZoneDropDown, 1);
	UIDropDownMenu_SetWidth(PLDkpBidsOptionFrameMinDKPZoneDropDown, 120);
end

function PLDkpBidsOptionMinDKPZoneDropDown_Initialize()
	local info;

	info = {
		text = "Default";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
	
	info = {
		text = "Onyxia's Lair";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
	
	info = {
		text = "Molten Core";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
	
	info = {
		text = "Blackwing Lair";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	

	info = {
		text = "Zul'Gurub";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	

	info = {
		text = "Ruins of Ahn'Qiraj";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	

	info = {
		text = "Temple of Ahn'Qiraj";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	

	info = {
		text = "Naxxramas";
		func = PLDkpBidsOptionMinDKPZoneDropDown_OnClick;
	};
	UIDropDownMenu_AddButton(info);	
end

function PLDkpBidsOptionMinDKPZoneDropDown_OnClick(self)

	local oldID = UIDropDownMenu_GetSelectedID(PLDkpBidsOptionFrameMinDKPZoneDropDown);
	UIDropDownMenu_SetSelectedID(PLDkpBidsOptionFrameMinDKPZoneDropDown, self:GetID());
	
	if(oldID ~= self:GetID()) then
		
		if ( self:GetID() == 1 ) then
			selectedMinDKPZoneName = "Default";
		elseif ( self:GetID() == 2 ) then
			selectedMinDKPZoneName = "Onyxia's Lair";
		elseif ( self:GetID() == 3 ) then
			selectedMinDKPZoneName = "Molten Core";
		elseif ( self:GetID() == 4 ) then
			selectedMinDKPZoneName = "Blackwing Lair";
		elseif ( self:GetID() == 5 ) then
			selectedMinDKPZoneName = "Zul'Gurub";
		elseif ( self:GetID() == 6 ) then
			selectedMinDKPZoneName = "Ruins of Ahn'Qiraj";
		elseif ( self:GetID() == 7 ) then
			selectedMinDKPZoneName = "Temple of Ahn'Qiraj";
		elseif ( self:GetID() == 8 ) then
			selectedMinDKPZoneName = "Naxxramas";
		end

		PLDkpBidsOptionsFrame_FillMinDkpOfZone(selectedMinDKPZoneName)
	end
end

function PLDkpBidsOptionFrame_SendDKPSettings()
	PLDKPBids.Sync:BroadcastDkpSettings()
end

function PLDkpBidsOptionsFrame_ResetZoneDKPToDefaults()
	if(selectedMinDKPZoneName and selectedMinDKPZoneName ~= "Default") then
		PLDKPBids:ClearCustomizedZoneDKP(selectedMinDKPZoneName)
		PLDkpBidsOptionsFrame_FillMinDkpOfZone(selectedMinDKPZoneName)
	end
end


function PLDkpBidsOptionFrame_OnUpdate(elapsed)
	if (PLDkpBidsOptions == nil) then
		return;
	end
	FauxScrollFrame_Update(PLDkpBidsOptionFrameSpecialPricesFrame, PLDKPBidsOptionsFrame_CountSpecialPrices(), PLBDKP_SPECIALITEM_LIST_NR, PLBDKP_SPECIAL_HEIGHT);
	PLDKPBidsOptionsFrame_FillSpecialPrices()
end

function PLDKPBidsOptionsFrame_ResolveItem(itemId)
	local itemName = nil
	local itemLink = nil
	local itemIcon = nil

	if (PLDKPItemCache ~= nil and PLDKPItemCache[itemId] ~= nil) then
		itemName = PLDKPItemCache[itemId]["Name"]
		itemLink = PLDKPItemCache[itemId]["ItemLink"]
		itemIcon = PLDKPItemCache[itemId]["Texture"]
	else
		itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo (itemId);

		if (itemName) then
			if (PLDKPItemCache == nil) then
				PLDKPItemCache = {}
			end
			if (PLDKPItemCache[itemId] == nil) then
				PLDKPItemCache[itemId] = {}
			end

			PLDKPItemCache[itemId]["Name"] = itemName
			PLDKPItemCache[itemId]["ItemLink"] = itemLink
			PLDKPItemCache[itemId]["Texture"] = itemIcon
		end
	end

	return itemId, itemName, itemLink, itemIcon
end

function PLDKPBidsOptionsFrame_FillSpecialPrices()
	local nameOffset = FauxScrollFrame_GetOffset(PLDkpBidsOptionFrameSpecialPricesFrame);
	local nameIndex;

	-- PLDkpBidsOptions["MinDKPSpecial"][itmId]=price

	for i=1, PLBDKP_SPECIALITEM_LIST_NR do
		local itemIndex = i + FauxScrollFrame_GetOffset(PLDkpBidsOptionFrameSpecialPricesFrame);
		
		--PLDKP_debug("UI i=" .. i .. ", itemIndex="..itemIndex..", tablecount="..table.getn(PLDkpBidsOptions["MinDKPSpecial"]));
		
		if (itemIndex <= PLDKPBidsOptionsFrame_CountSpecialPrices()) then
			local itemId = PLDKPBidsOptionsFrame_GetSpecialPricesByIndex(itemIndex);
			
			if ( itemId ~= nil ) then

				PLDKPBids:LoadItemAndRun(itemId, function(itemId, itemName, itemLink, itemIcon)
					
					getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."NameLabel"):SetText(itemLink);

					getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Price"):SetText(PLDkpBidsOptions["MinDKPSpecial"][itemId]);
					
					getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Item"):SetNormalTexture(itemIcon);
					getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Item"):SetPushedTexture(itemIcon);
					getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Item"):SetDisabledTexture(itemIcon);

					getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i):Show();
				end)

				--[[local _, itemName, itemLink, itemIcon = PLDKPBidsOptionsFrame_ResolveItem(itemId)
				--getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Date"):SetText(sDate);
				
				--PLDKP_debug("Item: " .. (itemName or "n/a") .. ", Id: " .. itemId .. ", price: " .. (PLDkpBidsOptions["MinDKPSpecial"][itemId] or "n/a"))

				getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."NameLabel"):SetText(itemLink);

				getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Price"):SetText(PLDkpBidsOptions["MinDKPSpecial"][itemId]);
				
				getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Item"):SetNormalTexture(itemIcon);
				getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Item"):SetPushedTexture(itemIcon);
				getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i.."Item"):SetDisabledTexture(itemIcon);

				getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i):Show();]]--
			else
				getglobal("PLDkpBidsOptionFrameSpecialPriceRowButton"..i):Hide();
			end
		end
	end
end

---------------------------------------------------------------------
-- function PLDKPBidsOptionsFrame_CountSpecialPrices()
--
-- gets the number of special prices
---------------------------------------------------------------------
function PLDKPBidsOptionsFrame_CountSpecialPrices()
	local nRet = 0;
	
	if ( PLDkpBidsOptions ~= nil and PLDkpBidsOptions["MinDKPSpecial"] ~= nil ) then
		for key in pairs(PLDkpBidsOptions["MinDKPSpecial"]) do
			nRet = nRet + 1
		end
	end
	
	return nRet;
end

---------------------------------------------------------------------
-- function PLDKPBidsOptionsFrame_GetSpecialPricesByIndex(index)
--
-- Returns the itemId by index
---------------------------------------------------------------------
function PLDKPBidsOptionsFrame_GetSpecialPricesByIndex(index)
	local nCount=0;
	local itemId=nil;
	
	if ( PLDkpBidsOptions ~= nil and PLDkpBidsOptions["MinDKPSpecial"] ~= nil ) then

		for curId in pairs(PLDkpBidsOptions["MinDKPSpecial"]) do
			nCount=nCount+1;

			if(nCount==index) then
				itemId = curId;
				return itemId;
			end
		end
	end
	
	return itemId;
end

---------------------------------------------------------------------
-- function PLDKP_ShowLastWinnerstItemToolTip(self, buttonID)
--
-- Shows an item-tooltip for the current last-winner item
---------------------------------------------------------------------
function PLDKP_ShowSpecialPricestItemToolTip(self, buttonID)
	
	local index = buttonID + FauxScrollFrame_GetOffset(PLDkpBidsOptionFrameSpecialPricesFrame);
	local itemId = PLDKPBidsOptionsFrame_GetSpecialPricesByIndex(index);
	if ( itemId ~= nil ) then
		local _, itemName, itemLink, itemIcon = PLDKPBidsOptionsFrame_ResolveItem(itemId)

		PLDkpBids_Tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		PLDkpBids_Tooltip:ClearLines();
		if (itemLink) then
			PLDkpBids_Tooltip:SetHyperlink(itemLink);
		else
			PLDkpBids_Tooltip:SetHyperlink("item:" .. itemId .. ":0:0:0:0:0:0:0");
		end
		PLDkpBids_Tooltip:Show();
	end
end

function PLDKPBidsOptionsFrame_OnAddSpecialPrice()
	PLDKP_SPECIALPRICE_EDITID = nil
	PLDKP_SPECIALPRICE_EDITLINK = nil
	ShowUIPanel(PLDkpBidsSpecialPriceFrame)
	PLDkpBidsSpecialPriceFrame_InitDialog()
end

function PLDKPBidsOptionsFrame_OnDeleteSpecialPrice(buttonID)
	local index = buttonID + FauxScrollFrame_GetOffset(PLDkpBidsOptionFrameSpecialPricesFrame);
	local itemId = PLDKPBidsOptionsFrame_GetSpecialPricesByIndex(index);
	if ( itemId ~= nil ) then
		local _, itemName, itemLink, itemIcon = PLDKPBidsOptionsFrame_ResolveItem(itemId)
		StaticPopup_Show("PLBDKP_POPUP_OPTION_DELETE_CONFIRM", (itemName or "n/a"), nil, itemId)
		--PLDkpBidsOptions["MinDKPSpecial"][itemId] = nil
		--PLDKPBidsOptionsFrame_FillSpecialPrices()
	end
end

function PLDKPBidsOptionsFrame_OnEditSpecialPrice(buttonID)
	local index = buttonID + FauxScrollFrame_GetOffset(PLDkpBidsOptionFrameSpecialPricesFrame);
	local itemId = PLDKPBidsOptionsFrame_GetSpecialPricesByIndex(index);
	if ( itemId ~= nil ) then
		local _, itemName, itemLink, itemIcon = PLDKPBidsOptionsFrame_ResolveItem(itemId)
		PLDKP_SPECIALPRICE_EDITID = itemId
		PLDKP_SPECIALPRICE_EDITLINK = itemLink
		ShowUIPanel(PLDkpBidsSpecialPriceFrame)
		PLDkpBidsSpecialPriceFrame_InitDialog()
	end	
end