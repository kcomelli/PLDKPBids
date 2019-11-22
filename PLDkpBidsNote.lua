-------------------------------------------------------------------------------
-- PL DKP Bids Note Frame
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
-- function PLDkpBidsNoteFrame_OnLoad()
--
-- Called when the Mod-Frame is loaded
--
-- Initializes the AddOn and registers for common events
---------------------------------------------------------------------
function PLDkpBidsNoteFrame_OnLoad()
	PLDkpBidsNoteFrame:RegisterEvent("VARIABLES_LOADED");
end

---------------------------------------------------------------------
-- function PLDkpBidsNoteFrame_OnEvent(event)
--
-- Default eventhandler for the Frame
--
-- Handels events for all Mods
---------------------------------------------------------------------
function PLDkpBidsNoteFrame_OnEvent(event)
	local playerName = UnitName("player");
	
	if (event == "VARIABLES_LOADED") then
		
		PLDkpBidsNoteFrameHeaderString:SetText( PLDKP_NOTE_UI_HEADER );
		PLDkpBidsNoteFrameSaveButton:SetText( PLDKP_OPTIONS_SAVE );
		PLDkpBidsNoteFrameCancelButton:SetText( PLDKP_OPTIONS_CANCEL );
		
		PLDkpBidsNoteFrameNoteEdit:SetText(PLDKP_WinnerNote);
		
	end
end

function PLDkpBidsNoteFrame_SetNote(note)
	PLDkpBidsNoteFrameNoteEdit:SetText(PLDKP_WinnerNote);
end

function PLDkpBidsNoteFrame_NoteEditESC()
	HideUIPanel(PLDkpBidsNoteFrame);
end

function PLDkpBidsNoteFrame_NoteEditENTER()
	tmp = PLDkpBidsNoteFrameNoteEdit:GetText();
	PLDKP_WinnerNote = tmp;
	HideUIPanel(PLDkpBidsNoteFrame);
	
	if ( (PLDKP_LastWinners[PLDKP_WinnerNoteKey] ~= nil) ) then
		PLDKP_LastWinners[PLDKP_WinnerNoteKey].Note = PLDKP_WinnerNote;

		PLDKP_println(string.format(PLDKP_NOTE_SAVED,PLDKP_WinnerNote));

		-- send winner data to other addons
		PLDKPBids.Sync:BroadCastEditLastWinnerData(PLDKP_WinnerNoteKey, PLDKP_LastWinners[PLDKP_WinnerNoteKey])
	else
		PLDKP_println(PLDKP_NOTE_NOTSAVED);
	end
end