-------------------------------------------------------------------------------
-- PL DKP Bids special price Frame
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
-- function PLDkpBidsSpecialPriceFrame_OnLoad()
--
-- Called when the Mod-Frame is loaded
--
-- Initializes the AddOn and registers for common events
---------------------------------------------------------------------
function PLDkpBidsSpecialPriceFrame_OnLoad()
	PLDkpBidsSpecialPriceFrame:RegisterEvent("VARIABLES_LOADED");
end

---------------------------------------------------------------------
-- function PLDkpBidsSpecialPriceFrame_OnEvent(event)
--
-- Default eventhandler for the Frame
--
-- Handels events for all Mods
---------------------------------------------------------------------
function PLDkpBidsSpecialPriceFrame_OnEvent(event)
	local playerName = UnitName("player");
	
	if (event == "VARIABLES_LOADED") then
		
		PLDkpBidsSpecialPriceFrameHeaderString:SetText( PLDKP_SPECIALPRICE_UI_HEADER );
		PLDkpBidsSpecialPriceFrameSaveButton:SetText( PLDKP_OPTIONS_SAVE );
		PLDkpBidsSpecialPriceFrameCancelButton:SetText( PLDKP_OPTIONS_CANCEL );
	end
end

function PLDkpBidsSpecialPriceFrame_InitDialog()
	if(PLDKP_SPECIALPRICE_EDITID == nil) then
		-- add mode
		PLDkpBidsSpecialPriceFrameItemIdEdit:Enable();
		PLDkpBidsSpecialPriceFrameItemIdEdit:SetText("")
		PLDkpBidsSpecialPriceFrameItemInfoLabel:SetText("")
		PLDkpBidsSpecialPriceFrameMinPriceEdit:SetText("")
	else
		-- update mode
		PLDkpBidsSpecialPriceFrameItemIdEdit:Disable();
		PLDkpBidsSpecialPriceFrameItemIdEdit:SetText(PLDKP_SPECIALPRICE_EDITID)
		PLDkpBidsSpecialPriceFrameItemInfoLabel:SetText(PLDKP_SPECIALPRICE_EDITLINK)
		PLDkpBidsSpecialPriceFrameMinPriceEdit:SetText(PLDkpBidsOptions["MinDKPSpecial"][PLDKP_SPECIALPRICE_EDITID])
	end
end

function PLDkpBidsSpecialPriceFrame_ShowSpecialPricestItemToolTip(ctrl)
	tmp = PLDkpBidsSpecialPriceFrameItemInfoLabel:GetText()
	if(tmp) then
		PLDkpBids_Tooltip:SetOwner(PLDkpBidsSpecialPriceFrameItemInfoLabel, "ANCHOR_BOTTOMRIGHT");
		PLDkpBids_Tooltip:ClearLines();
 		PLDkpBids_Tooltip:SetHyperlink(tmp);
		PLDkpBids_Tooltip:Show();
	end
end

function PLDkpBidsSpecialPriceFrame_ItemIdEditFocusLost()
	PLDkpBidsSpecialPriceFrameItemInfoLabel:SetText("")
	tmp = PLDkpBidsSpecialPriceFrameItemIdEdit:GetText()
	PLDKP_debug("itemid: " ..( tmp or "n/1"))
	if(tmp and tmp ~= "") then
		PLDKPBids:LoadItemAndRun(tonumber(tmp), function(itemId, itemName, itemLink, itemIcon)
			--PLDKP_debug("itemLink: " ..( itemLink or "n/1"))
			if (itemLink) then
				PLDkpBidsSpecialPriceFrameItemInfoLabel:SetText(itemLink)
			end
		end)
	end
end

function PLDkpBidsSpecialPriceFrame_ItemIdEditESC()
end

function PLDkpBidsSpecialPriceFrame_ItemIdEditENTER()
end

function PLDkpBidsSpecialPriceFrame_MinPriceEditESC()
end

function PLDkpBidsSpecialPriceFrame_MinPriceEditENTER()
	
end

function PLDkpBidsSpecialPriceFrame_Save()
	itemId = PLDkpBidsSpecialPriceFrameItemIdEdit:GetText();
	minPrice = PLDkpBidsSpecialPriceFrameMinPriceEdit:GetText();

	if(itemId and minPrice and tonumber(itemId) > 0 and tonumber(minPrice) > 0) then
		local _, _, itemLink = PLDKPBidsOptionsFrame_ResolveItem(tonumber(itemId))
		PLDkpBidsOptions["MinDKPSpecial"][tonumber(itemId)] = tonumber(minPrice)
		HideUIPanel(PLDkpBidsSpecialPriceFrame);
	else
		PLDKP_println(PLDKP_SPECIALPRICE_NOTSAVED);
	end
end