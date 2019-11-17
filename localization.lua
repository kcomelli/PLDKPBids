local _, PLDKPBids = ...

-------------------------------------------------------------------------------
-- the constants for the mod (non localized)
-------------------------------------------------------------------------------

PLDKP_CHAT_RED = "|cFFFF0000";
PLDKP_CHAT_GREEN = "|cFF00FF00";
PLDKP_CHAT_BLUE = "|cFF0000FF";
PLDKP_CHAT_YELLOW = "|cFFFFFF00";
PLDKP_CHAT_WHITE = "|cFFFFFFFF";
PLDKP_CHAT_END = "|r";

PLDKP_MINIMUM_BID_TIME = 30;
PLDKP_DEFAULT_MIN_BID = 150;

PLBDKP_DKP_HEIGHT = 20;
PLBDKP_DKPLIST_NR = 6;
PLBDKP_BID_HEIGHT = 20;
PLBDKP_BIDLIST_NR = 6;
PLBDKP_WINNER_HEIGHT = 20;
PLBDKP_WINNERLIST_NR = 6;

-- slash commands
PLDKP_Command_Help = "help";
PLDKP_Command_Start = "start";
PLDKP_Command_Set = "set";
PLDKP_Command_Reset = "reset";
PLDKP_Command_ResetMod = "resetmod";
PLDKP_Command_Show = "show";
PLDKP_Command_Hide = "hide";
PLDKP_Command_ClearWinners = "clearwinners";
PLDKP_Command_GetMain = "getmain";

-------------------------------------------------------------------------------
-- English localization (Default)
-------------------------------------------------------------------------------

PLDKP_VERSION_STRING = "Primal Legion DKP-Bids 4.0";
PLDKP_BUILD_NUMBER = "4000001"

PLDKP_ClosedMessage = "PL DKP-Bids window closed.  Type \"/pldkp show\" to make it visible again."

PLDKP_WelcomeMessage = PLDKP_VERSION_STRING .. " - type /pldkp  for help";
PLDKP_LoadedMessage = PLDKP_VERSION_STRING .. " loaded !";

-- Messages
PLDKP_BID_OPENING1 = "*** Primal Legion Bidsystem ***";
PLDKP_BID_OPENING2 = "*** MAKE YOUR BIDS NOW (Time accepting bids: %d seconds)";
PLDKP_BID_OPENING3 = "*** Item to bid: %s";
PLDKP_BID_OPENING4 = "*** Use: /w %s <value> (min value: %d)";
PLDKP_BID_OPENING5 = "*** Bids of twinks are PERMITTED (main need before twink need)";
PLDKP_BID_OPENING6 = "*** Bids of twinks are NOT PERMITTED";

PLDKP_BID_CLOSING_INFO = "*** Bidding open for %s seconds.";
PLDKP_BID_CLOSING = "*** Bidding time is over. No more bids please.";

PLDKP_BID_NOBIDS = "*** NO bids recorded for the current item.";

PLDKP_BID_WINNER1 = "*** Item-Winner for %s";
PLDKP_BID_WINNER2 = "*** Player %s for %d DKP - grats !";
PLDKP_BID_WINNER3 = "*** The players %s won for %d DKP (roll or use dkp-standings to choose a final winner).";
PLDKP_BID_WINNER4 = "*** Player %s for %d DKP - grats ! (DKP standings used to find a final winner)";

PLDKP_BID_ABORTED = "*** Bidding aborted.";

PLDKP_BID_INVALID = "** PLDKP: Your bid \"%s\" is invalid. Whisper me a number higher than or equal the minimum price.";
PLDKP_BID_INVALID1 = "** PLDKP: Your bid %d is to low. It must be %d or higher.";
PLDKP_BID_INVALID2 = "** PLDKP: Ignoring bid %d. The bid is higher than your DKP-Value (%d).";
PLDKP_BID_INVALID3 = "** PLDKP: Ignoring bid %d. AddOn in Test-Mode accepts maximum %d DKP.";
PLDKP_BID_INVALID4 = "** PLDKP: Ignoring bid %d. DKP-value must be in steps of %d.";
PLDKP_BID_INVALID5 = "** PLDKP: Ignoring bid %s. Wrong format or number is too big!";
PLDKP_BID_INVALID6 = "** PLDKP: Ignoring bid %d. The bid is to high and you would have to many -DKP (%d).";
PLDKP_BID_INVALID7 = "** PLDKP: Ignoring bid %d. Bids of twinks are not allowed by the auctioneer.";
PLDKP_BID_INVALID8 = "** PLDKP: Ignoring bid %d. You are not in the group of the auctionator. External bids are not allowed.";
PLDKP_BID_INVALID9 = "** PLDKP: Ignoring bid %s. Wrong format! Use: /w %s <value> (min value: %d)";

PLDKP_BID_INVALID_SCRREN = "** PLDKP: Invalid bid from player %s (wrong format or not a number).";
PLDKP_BID_INVALID1_SCRREN = "** PLDKP: Invalid bid from player %s (bid was lower than the min. price).";
PLDKP_BID_INVALID2_SCRREN = "** PLDKP: Invalid bid from player %s (bid was higher then the players DKP value).";
PLDKP_BID_INVALID3_SCRREN = "** PLDKP: Invalid bid from player %s (over max price).";
PLDKP_BID_INVALID4_SCRREN = "** PLDKP: Invalid bid from player %s (bid not in steps of %d).";
PLDKP_BID_INVALID5_SCRREN = "** PLDKP: Invalid bid from player %s (wrong format or number too big).";
PLDKP_BID_INVALID6_SCRREN = "** PLDKP: Invalid bid from player %s (bid too high, player would have too many -DKP).";
PLDKP_BID_INVALID7_SCRREN = "** PLDKP: Invalid bid from player %s (Twink bids not allowed).";

PLDKP_BID_ACCEPTED = "** PLDKP: Accepted your bid.";
PLDKP_BID_DELETED = "** PLDKP: Your old bid has been deleted.";
PLDKP_BID_ALREADY = "** PLDKP: You've already bidden \"%d\" DKP.";
PLDKP_BID_ALREADYOV = "** PLDKP: You've already bidden \"%d\" DKP. You can overwrite your bid with a higher number.";

PLDKP_BID_ACCEPTED_SCREEN = "** PLDKP: Accepted bid from player %s.";
PLDKP_BID_DELETED_SCREEN = "** PLDKP: Deleted bid from player %s.";
PLDKP_BID_ALREADY_SCREEN = "** PLDKP: Player %s already bidden on item.";
PLDKP_BID_ALREADYOV_SCREEN = "** PLDKP: Player %s already bidden on item and must bid higher than last bid.";

PLDKP_ITEM_TOKENINFO = "** PLDKP: %s recognized as set item token.";
PLDKP_NOTE_SAVED = "** PLDKP: Note '%s' saved.";
PLDKP_NOTE_NOTSAVED = "** PLDKP: Note '%s' NOT saved.";

PLDKP_DKPINFO_PLAYERUNKNOWN = "** PLDKP: You do not have earned any DKP yet or your player name has not been added to the DKP system!";
PLDKP_DKPINFO_SEND = "** PLDKP: You have %d DKP (%s)";
PLDKP_DKPINFO_TWINKDETECT = "** PLDKP: Detected your character is a twink of %s";
PLDKP_DKPINFO_SENDTWINK = "** PLDKP: %s has %d DKP (%s)";
PLDKP_DKPINFO_BEGINOFRAID = "begin of raid";
PLDKP_DKPINFO_LASTUPDATE = "updated: %s";

PLDKP_INFO_TWINKOF = "TWINK of";

PLDKP_TWINKINFO_MAINCHAR = "PLDKP Character '%s' is a main character.";
PLDKP_TWINKINFO_TWINKOF = "PLDKP Character '%s' is a twink of '%s'.";
PLDKP_TWINKINFO_NOTFOUND = "PLDKP Character '%s' not found in guild list.";
PLDKP_TWINKINFO_ERRORNAME = "PLDKP Twink resolve: No character name provided.";

-- System messages
PLDKP_ERROR_OPTIONPARAM = "Wrong format for setting options. See /pldkp for help.";
PLDKP_ERROR_NOTGROUPED = "You are not in a group and options are set to allow biddings only from group members !";
PLDKP_ERROR_NOITEMLINK = "Wrong parameter ! Parameter 1 of \"/pldkp start\" is NOT an itemlink !";
PLDKP_OPTION_SET = "Option \"%s\" sucessfully set to: %s";
PLDKP_WINNERS_CLEARED = "Last winner tabled is empty now!";
PLDKP_WINNERS_CLEARD_OLDVER = "** PLDKP: Last winners table cleared because it was saved in an old format!";

-- Tooltips and buttons
PLDKP_BUTTON_OPTIONS = "Options";
PLDKP_BUTTON_SAVE = "Save";
PLDKP_LABEL_TIME = "Time accepting bids: ";
PLDKP_LABEL_TIMESEC = "sec";
PLDKP_LABEL_MINDKP = "Minmum price: ";
PLDKP_LABEL_DKP = "DKP";
PLDKP_DELWINNER_TP = "Delete winner entry";
PLDKP_WINNERNOTE_TP = "Add a note to the winner entry";

PLDKP_TABLABEL_AUCTION = "Auction";
PLDKP_TABLABEL_CURBIDS = "Cur bids";
PLDKP_TABLABEL_LASTWINNERS = "Last winners";
PLDKP_TABLABEL_DKPLIST = "DKP List";

PLDKP_TABBUTTON_NAME = "Name";
PLDKP_TABBUTTON_CLASS = "Class";
PLDKP_TABBUTTON_CURBID = "Cur. bid";
PLDKP_TABBUTTON_DKP = "DKP";
PLDKP_TABBUTTON_ITEM = "Item";
PLDKP_TABBUTTON_DATE = "Date";
PLDKP_TABBUTTON_PRICE = "Price";

PLDKP_BUTTON_STARTAUCTION = "Start bidding";
PLDKP_BUTTON_ABORTAUCTION = "Abort bidding";

PLDKP_LABEL_TIMEREMAINING = "Remaining time: ";

PLDKP_TOOLTIP_CLOSE = "Close this window.";
PLDKP_TOOLTIP_OPTIONS = "Click to set options.";
PLDKP_TOOLTIP_SAVE = "Reloads the UI and saves all current variables.";
PLDKP_TOOLTIP_INFO = "INFO: Shift+Right-Click on an Item in the Lootframe or linked Item in chat to create an auction or type in /pldkp start <item> [<twinkbids allowed>] <minprice> <sec>";
PLDKP_TOOLTIP_MINDKPBTN = "Click here to type in minimum DKP.";
PLDKP_TOOLTIP_TIMEBTN = "Click here to type in the timespan.";
PLDKP_TOOLTIP_TWINKCHK = "Allow twink bids";
PLDKP_TOOLTIP_TWINKCHK_TP = "Click here to accept twink bids.";

PLDKP_TOOLTIP_STARTSTOPAUCTION = "Click here to start/stop the auction";

-- Hilfe
PLDKP_Help_Text0 = PLDKP_VERSION_STRING .. " help:";
PLDKP_Help_Text1 = "/pldkp without parameters shows this message.";
PLDKP_Help_Text2 = "/pldkp <command> to make following actions (Case sensitive):";
PLDKP_Help_Text3 = PLDKP_CHAT_GREEN..PLDKP_Command_Help..PLDKP_CHAT_WHITE.." Shows this help.";
PLDKP_Help_Text4 = PLDKP_CHAT_GREEN..PLDKP_Command_Show..PLDKP_CHAT_WHITE.." Shows the UI-window.";
PLDKP_Help_Text5 = PLDKP_CHAT_GREEN..PLDKP_Command_Hide..PLDKP_CHAT_WHITE.." Hides the UI-window.";
PLDKP_Help_Text6 = PLDKP_CHAT_GREEN..PLDKP_Command_Start.. " <item> [<twinkbids allowed>] <mindkp> <seconds> "..PLDKP_CHAT_WHITE.." Starts the bidding. <twinkbids allowed> is optional and can be true or false";
PLDKP_Help_Text7 = PLDKP_CHAT_GREEN..PLDKP_Command_Set.." <option>=<value> " ..PLDKP_CHAT_WHITE.." Sets an option value.";
PLDKP_Help_Text8 = PLDKP_CHAT_GREEN..PLDKP_Command_Reset..PLDKP_CHAT_WHITE.." Reset Mod.";
PLDKP_Help_Text9 = PLDKP_CHAT_GREEN..PLDKP_Command_ClearWinners..PLDKP_CHAT_WHITE.." Clears the last winners table.";
PLDKP_Help_Text10 = PLDKP_CHAT_GREEN..PLDKP_Command_GetMain .. " <playername> " ..PLDKP_CHAT_WHITE.." Prints the name of the main character for the player.";
PLDKP_Help_TextEND = "*** END OF " .. PLDKP_VERSION_STRING .. " help";

PLDKP_Help_GetDKP = PLDKP_CHAT_WHITE.."GetDKP AddOn found. Using it to determine DKP-values for max. bids.";

-- Note frame
PLDKP_NOTE_UI_HEADER = "Enter note";
PLDKP_OPTIONS_SAVE = "Save";
PLDKP_OPTIONS_CANCEL = "Cancel";

-- Options Frame
PLDKP_OPTIONS_UI_HEADER = "PL-DKP Options";
PLDKP_OPTIONS_CLOSE = "Close";

PLDKP_OPTIONS_DEF_MINDP = "Default min. DKP";
PLDKP_OPTIONS_DEF_MINDP_TP = "Click here to set the default min. DKP.";

PLDKP_OPTIONS_DEF_TS = "Default timespan";
PLDKP_OPTIONS_DEF_TS_TP = "Click here to set the default auction timespan.";
	
PLDKP_OPTIONS_VAL_ADD = "Value added to winner DKP";
PLDKP_OPTIONS_VAL_ADD_TP = "Click here to change the value added to winner DKP.";

PLDKP_OPTIONS_VAL_STEP = "Bids step of";
PLDKP_OPTIONS_VAL_STEP_TP = "Click here to change the step of bid values.";

PLDKP_OPTIONS_ANNCHANNEL = "Announce channel";

PLDKP_OPTIONS_ALLOW_MINBID = "Always allow min bid";
PLDKP_OPTIONS_ALLOW_MINBID_TP = "Check to allow all players to use the min bid always.";

PLDKP_OPTIONS_ALLOW_HIGHOV = "Allow bid overwrite with higher val";
PLDKP_OPTIONS_ALLOW_HIGHOV_TP = "Click here to allow/disallow bid overwriting with higher values.";

PLDKP_OPTIONS_RAIDWARNING = "Show countdown in raid warning";
PLDKP_OPTIONS_RAIDWARNING_TP = "Click here to show/hide count down in raid warning.";

PLDKP_OPTIONS_ALLOWDELETE = "Allow bid delete";
PLDKP_OPTIONS_ALLOWDELETE_TP = "Click here to allow/disallow bid delete.";

PLDKP_OPTIONS_USEDKPONEQUAL = "Use DKP on equal bids (winner)";
PLDKP_OPTIONS_USEDKPONEQUAL_TP = "Click here to use DKP-standings for identify a winner on equal bids.";

PLDKP_OPTIONS_ALLOWMAXDKPBIDS = "Allow bids higher than DKP";
PLDKP_OPTIONS_ALLOWMAXDKPBIDS_TP = "Click here to allow/disallow bids higher than players DKP-values.";

PLDKP_OPTIONS_MAXMINUSDKP = "Max minus DKP (0 to disable)";
PLDKP_OPTIONS_MAXMINUSDKP_TP = "Click here to change the maximum minus DKP a player may get with a bid.";

PLDKP_OPTIONS_NODKPPOINTS = "No DKP point data or known DKP AddOn found!";

PLDKP_OPTIONS_MINDKP_EQUIP = "Min DKP (EQUIP)";
PLDKP_OPTIONS_MINDKP_EQUIP_TP = "Click here to change the minimum DKP for equipments.";

PLDKP_OPTIONS_MINDKP_SET = "Min DKP (SET-Item)";
PLDKP_OPTIONS_MINDKP_SET_TP = "Click here to change the minimum DKP for Set items.";

PLDKP_OPTIONS_MINDKP_OH = "Min DKP (1H)";
PLDKP_OPTIONS_MINDKP_OH_TP = "Click here to change the minimum DKP for 1H Weapons, Offhand, Wands, Guns, Bows, Relics, Thrown.";

PLDKP_OPTIONS_MINDKP_TH = "Min DKP (2H)";
PLDKP_OPTIONS_MINDKP_TH_TP = "Click here to change the minimum DKP for 2H Weapons.";

PLDKP_OPTIONS_DEBUG_MODE = "Debug mode";
PLDKP_OPTIONS_DEBUG_MODE_TP = "Click here to turn debug mode on or off.";


PLDKP_BUILD_OUTOFDATE = "PLDKP: Your version of PLDkp Bids is out-of-date! Please update to latest version!"
PLDKP_RECEIVED_NEW_DKPDATA = "PLDKP: Received new DKP data from: %s from player %s"
PLDKP_RECEIVED_WINNER_INFO = "PLDKP: Received auction winner information: %s from player %s"

-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------
if ( GetLocale() == "deDE" ) then


end

	PLDKP_VERSION_STRING = "Primal Legion DKP-Bietsystem 4.0";

	PLDKP_ClosedMessage = "PL-DKP Fenster geschlossen.  \"/pldkp show\" eingeben um es wieder sichtbar zu machen."

	PLDKP_WelcomeMessage = PLDKP_VERSION_STRING .. " - /pldkp um Hilfe zu erhalten";
	PLDKP_LoadedMessage = PLDKP_VERSION_STRING .. " geladen !";

	-- Messages
	PLDKP_BID_OPENING1 = "*** Primal Legion Bietsystem ***";
	PLDKP_BID_OPENING2 = "*** MACHT EURE GEBOTE (Zeit: %d Sekunden)";
	PLDKP_BID_OPENING3 = "*** Biete fuer Item: %s";
	PLDKP_BID_OPENING4 = "*** Format: whisper %s DKP-Wert (Mindestwert: %d)";
	PLDKP_BID_OPENING5 = "*** Twinkgebote sind ERLAUBT (main need vor twink need)";
	PLDKP_BID_OPENING6 = "*** Twinkgebote sind NICHT ERLAUBT";
	
	PLDKP_BID_CLOSING_INFO = "*** Akzeptiere Gebote fuer %s Sekunden.";
	PLDKP_BID_CLOSING = "*** Keine weiteren Gebote, die Zeit ist vorueber.";
	
	PLDKP_BID_WINNER1 = "*** Gewinner des Items %s";
	PLDKP_BID_WINNER2 = "*** Spieler %s hat gewonnen. Preis: %d DKP - grats !";
	PLDKP_BID_WINNER3 = "*** Die Spieler %s haben gewonnen. Preis: %d DKP (Rollen od. den akt. DKP-Wert fuer die Verteilung unter den Gewinnern verwenden).";
	PLDKP_BID_WINNER4 = "*** Spieler %s hat gewonnen. Preis: %d DKP - grats ! (DKP-Stand wurde verwendet um einen Gewinner zu ermitteln)";
	
	PLDKP_BID_ABORTED = "*** Bietsystem abgebrochen.";
	
	PLDKP_BID_NOBIDS = "*** Keine Gebote fuer das aktuelle Item.";
	
	PLDKP_BID_INVALID = "** PLDKP: Dein Gebot \"%s\" ist ungueltig. Fluester mir eine Zahl die hoeher oder gleich dem Mindestpreis ist.";
	PLDKP_BID_INVALID1 = "** PLDKP: Dein Gebot von %d ist zu klein. Du musst %d oder mehr bieten.";
	PLDKP_BID_INVALID2 = "** PLDKP: Ignoriere dein Gebot von %d. Dein Gebot ist hoeher als dein DKP-stand (%d).";
	PLDKP_BID_INVALID3 = "** PLDKP: Ignoriere dein Gebot von %d. AddOn ist im Test-Mode und akzeptiert max. %d DKP.";
	PLDKP_BID_INVALID4 = "** PLDKP: Ignoriere dein Gebot von %d. DKP-Werte muessen ein Vielfaches von %d sein.";
	PLDKP_BID_INVALID5 = "** PLDKP: Ignoriere dein Gebot von %s. Falsches Format oder eine zu grosse Zahl !";
	PLDKP_BID_INVALID6 = "** PLDKP: Ignoriere dein Gebot von %d. Dein Gebot ist zu hoch weshalb du zuviele -DKP haben wuerdest (%d).";
	PLDKP_BID_INVALID7 = "** PLDKP: Ignoriere dein Gebot von %d. Gebote von Twinks werden vom Auktionator nicht akzeptiert.";
	PLDKP_BID_INVALID8 = "** PLDKP: Ignoriere dein Gebot von %d. Du bist nicht in der selben Gruppe wie der Auktionator. Externe Gebote sind nicht erlaubt.";
	PLDKP_BID_INVALID9 = "** PLDKP: Ignoriere dein Gebot von %s. Falsches Format! Benutze: /w %s <DKP-Wert> (Mindestwert: %d)";

	PLDKP_BID_INVALID_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (falsches Format oder keine Zahl).";
	PLDKP_BID_INVALID1_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (Gebot war kleiner als der Mindestpreis).";
	PLDKP_BID_INVALID2_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (Gebot war hoeher als der DKP-Stand).";
	PLDKP_BID_INVALID3_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (Gebot ueber dem Maximalpreis).";
	PLDKP_BID_INVALID4_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (Gebot kein Vielfaches von %d).";
	PLDKP_BID_INVALID5_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (falsches Format oder Zahl zu gross).";
	PLDKP_BID_INVALID6_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (Gebot war zu hoch und wuerde zuviele -DKP ergeben).";
	PLDKP_BID_INVALID7_SCRREN = "** PLDKP: Ungueltiges Gebot von %s (Twinkgebote nicht akzeptiert).";
	
	PLDKP_BID_ACCEPTED = "** PLDKP: Dein Gebot wurde registriert.";
	PLDKP_BID_DELETED = "** PLDKP: Dein Gebot wurde geloescht.";
	PLDKP_BID_ALREADY = "** PLDKP: Du hast bereits \"%d\" DKP geboten.";
	PLDKP_BID_ALREADYOV = "** PLDKP: Du hast bereits  \"%d\" DKP geboten. Du musst eine hoehere Zahl bieten um diesen Wert zu ueberschreiben.";
	
	PLDKP_BID_ACCEPTED_SCREEN = "** PLDKP: Gebot von Spieler %s akzeptiert.";
	PLDKP_BID_DELETED_SCREEN = "** PLDKP: Gebot von Spieler %s geloescht.";
	PLDKP_BID_ALREADY_SCREEN = "** PLDKP: Spieler %s hat bereits geboten.";
	PLDKP_BID_ALREADYOV_SCREEN = "** PLDKP: Spieler %s hat bereits geboten und muss hoeher bieten um das letzte Gebot zu ueberschreiben.";
	
	PLDKP_ITEM_TOKENINFO = "** PLDKP: %s wurde als Set-Token erkannt.";
	PLDKP_NOTE_SAVED = "** PLDKP: Notiz '%s' gespeichert.";
	PLDKP_NOTE_NOTSAVED = "** PLDKP: Notiz '%s' NICHT gespeichert.";

	PLDKP_DKPINFO_PLAYERUNKNOWN = "** PLDKP: Du hast noch keine DKP gesammelt oder dein Character ist im DKP System nicht bekannt!";
	PLDKP_DKPINFO_SEND = "** PLDKP: Du hast %d DKP (%s)";
	PLDKP_DKPINFO_TWINKDETECT = "** PLDKP: Du bist ein Twink von %s";
	PLDKP_DKPINFO_SENDTWINK = "** PLDKP: %s hat %d DKP (%s)";
	PLDKP_DKPINFO_BEGINOFRAID = "Begin des Raids";
	PLDKP_DKPINFO_LASTUPDATE = "Stand: %s";
	
	PLDKP_INFO_TWINKOF = "TWINK von";
	PLDKP_TWINKINFO_MAINCHAR = "PLDKP Character '%s' ist ein Maincharacter.";
	PLDKP_TWINKINFO_TWINKOF = "PLDKP Character '%s' ist ein Twink von '%s'.";
	PLDKP_TWINKINFO_NOTFOUND = "PLDKP Character '%s' nicht in der Gildenliste gefunden.";
	PLDKP_TWINKINFO_ERRORNAME = "PLDKP Twinkerkennung: Kein Spielername angegeben.";

	-- System messages
	PLDKP_ERROR_OPTIONPARAM = "Fehler: Falsches Format zum setzen von Optionen. Siehe /pldkp fuer Hilfe.";
	PLDKP_ERROR_NOTGROUPED = "Fehler: Du bist in keiner Gruppe und kannst deswegen keine Auktion starten !";
	PLDKP_ERROR_NOITEMLINK = "Fehler: Parameter 1 von \"/pldkp start\" ist KEIN Itemlink !";
	PLDKP_OPTION_SET = "Option \"%s\" wurde erfolgreich auf %s gesetzt.";
	PLDKP_WINNERS_CLEARED = "Die Tabelle der letzten Gewinner ist nun leer!";
	PLDKP_WINNERS_CLEARD_OLDVER = "** PLDKP: Tabelle der letzten Gewinner wurde geleert da sie im Format einer alten Version gespeichert wurde!";

	-- Tooltips and buttons
	PLDKP_BUTTON_OPTIONS = "Optionen";
	PLDKP_BUTTON_SAVE = "Speichern";
	PLDKP_LABEL_TIME = "Zeit fuer Gebote: ";
	PLDKP_LABEL_TIMESEC = "Sek";
	PLDKP_LABEL_MINDKP = "Mindestpreis: ";
	PLDKP_LABEL_DKP = "DKP";
	PLDKP_DELWINNER_TP = "Eintrag loeschen";
	PLDKP_WINNERNOTE_TP = "Notiz zum Gewinner hinzufuegen";
	
	PLDKP_TABLABEL_AUCTION = "Auktion";
	PLDKP_TABLABEL_CURBIDS = "Akt. Gebote";
	PLDKP_TABLABEL_LASTWINNERS = "Gewinner";
	PLDKP_TABLABEL_DKPLIST = "DKP Liste";

	PLDKP_TABBUTTON_NAME = "Name";
	PLDKP_TABBUTTON_CLASS = "Klasse";
	PLDKP_TABBUTTON_CURBID = "Akt.Gebot";
	PLDKP_TABBUTTON_DKP = "DKP";
	PLDKP_TABBUTTON_ITEM = "Item";
	PLDKP_TABBUTTON_DATE = "Datum";
	PLDKP_TABBUTTON_PRICE = "Preis";

	PLDKP_BUTTON_STARTAUCTION = "Bieten starten";
	PLDKP_BUTTON_ABORTAUCTION = "Bieten abbrechen";
	
	PLDKP_LABEL_TIMEREMAINING = "Verbleibende Zeit: ";
	
	PLDKP_TOOLTIP_CLOSE = "Fenster schliessen.";
	PLDKP_TOOLTIP_OPTIONS = "Klicken um Optionen zu setzen.";
	PLDKP_TOOLTIP_SAVE = "Laedt das Benutzerinterface neu und speichert alle Variablen.";
	PLDKP_TOOLTIP_INFO = "INFO: Shift+Rechts-Click auf ein Item im Lootfenster oder verlinktem Item im Chat um eine Auktion zu erstellen oder gib /pldkp start <item> [<twinkgebote erlaubt>] <minpreis> <sek> ein";
	PLDKP_TOOLTIP_MINDKPBTN = "Hier klicken um die MindestDKP einzugeben.";
	PLDKP_TOOLTIP_TIMEBTN = "Hier klicken um die Zeitspanne einzugeben.";	
	PLDKP_TOOLTIP_TWINKCHK = "Twinkgebote erlauben.";
	PLDKP_TOOLTIP_TWINKCHK_TP = "Hier klicken um Twinkgebote zu erlauben.";

	PLDKP_TOOLTIP_STARTSTOPAUCTION = "Hier klicken um die Auktion zu starten/stoppen !";

	-- Hilfe
	PLDKP_Help_Text0 = PLDKP_VERSION_STRING .. " help:";
	PLDKP_Help_Text1 = "/pldkp ohne Parameter um die Hilfe zu zeigen.";
	PLDKP_Help_Text2 = "/pldkp <command> um eine der folgenden Aktionen durchzufuehren (Case sensitive):";
	PLDKP_Help_Text3 = PLDKP_CHAT_GREEN..PLDKP_Command_Help..PLDKP_CHAT_WHITE.." Zeigt die Hilfe.";
	PLDKP_Help_Text4 = PLDKP_CHAT_GREEN..PLDKP_Command_Show..PLDKP_CHAT_WHITE.." Zeigt das UI-Fenster.";
	PLDKP_Help_Text5 = PLDKP_CHAT_GREEN..PLDKP_Command_Hide..PLDKP_CHAT_WHITE.." Versteckt das UI-Fenster.";
	PLDKP_Help_Text6 = PLDKP_CHAT_GREEN..PLDKP_Command_Start.. " <item> [<twinkgebote erlaubt>] <minimumDKP> <sekunden> "..PLDKP_CHAT_WHITE.." Startet das Bietsystem fuer <sekunden>. <twinkgebote erlaubt> kann ja oder nein sein.";
	PLDKP_Help_Text7 = PLDKP_CHAT_GREEN..PLDKP_Command_Set.." <option>=<value> " ..PLDKP_CHAT_WHITE.." Setzt einen Optionswert.";
	PLDKP_Help_Text8 = PLDKP_CHAT_GREEN..PLDKP_Command_Reset..PLDKP_CHAT_WHITE.." Setzt das Bietsystem zurueck.";
	PLDKP_Help_Text9 = PLDKP_CHAT_GREEN..PLDKP_Command_ClearWinners..PLDKP_CHAT_WHITE.." Loescht die Liste der letzten Gewinner.";
	PLDKP_Help_Text10 = PLDKP_CHAT_GREEN..PLDKP_Command_GetMain .. " <spielername> " ..PLDKP_CHAT_WHITE.." Zeigt den Namen des Mainchars von <spielername>.";
	PLDKP_Help_TextEND = "*** END OF " .. PLDKP_VERSION_STRING .. " help";
	
	PLDKP_Help_GetDKP = PLDKP_CHAT_WHITE.."GetDKP AddOn gefunden. Maximalwerte fuer Gebote werden von GetDKP entnommen.";

	-- Note frame
	PLDKP_NOTE_UI_HEADER = "Notiz eingeben";
	PLDKP_OPTIONS_SAVE = "Speichern";
	PLDKP_OPTIONS_CANCEL = "Abbrechen";

	-- Options Frame
	PLDKP_OPTIONS_UI_HEADER = "PL-DKP Optionen";
	PLDKP_OPTIONS_CLOSE = "Schliessen";

	PLDKP_OPTIONS_DEF_MINDP = "Standard mind. DKP";
	PLDKP_OPTIONS_DEF_MINDP_TP = "Hier klicken um den Standardwert fuer die MindestDKP einzugeben.";
	
	PLDKP_OPTIONS_DEF_TS = "Standard Zeit";
	PLDKP_OPTIONS_DEF_TS_TP = "Hier klicken den Standardwert fuer die Auktionsdauer einzugeben.";

	PLDKP_OPTIONS_VAL_ADD = "Preis DKP Aufwertung";
	PLDKP_OPTIONS_VAL_ADD_TP = "Hier klicken um den Wert zu aendern der zu den Preis DKP addiert wird.";

	PLDKP_OPTIONS_VAL_STEP = "Gebote ein Vielfaches von";
	PLDKP_OPTIONS_VAL_STEP_TP = "Hier klicken um die Gebotsschritte zu aendern.";

	PLDKP_OPTIONS_ANNCHANNEL = "Channel fuer die Auktion";

	PLDKP_OPTIONS_ALLOW_MINBID = "Mindestgebot immer erlauben";
	PLDKP_OPTIONS_ALLOW_MINBID_TP = "Hier klicken um Spielern immer zu erlauben das Mindestgebot zu bieten.";

	PLDKP_OPTIONS_ALLOW_HIGHOV = "Hoehere Gebote uberschreiben";
	PLDKP_OPTIONS_ALLOW_HIGHOV_TP = "Hier klicken um Gebotsueberschreibungen mit hoeheren Werten zu erlauben od. nicht.";

	PLDKP_OPTIONS_RAIDWARNING = "Countdown in Raid-Warning zeigen";
	PLDKP_OPTIONS_RAIDWARNING_TP = "Hier klicken um den Zeitcountdown mit Raid-Warnung anzuzeigen.";

	PLDKP_OPTIONS_ALLOWDELETE = "Loeschen von Geboten erlauben";
	PLDKP_OPTIONS_ALLOWDELETE_TP = "Hier klicken um das Loeschen von Geboten zu erlauben.";

	PLDKP_OPTIONS_USEDKPONEQUAL = "Akt. DKP fuer Gewinnerermittlung";
	PLDKP_OPTIONS_USEDKPONEQUAL_TP = "Hier klicken wenn der aktuelle DKP-Stand bei gleichen Geboten verwendet werden soll um den Gewinner zu ermitteln.";

	PLDKP_OPTIONS_ALLOWMAXDKPBIDS = "Gebote hoeher DKP-Stand erlauben";
	PLDKP_OPTIONS_ALLOWMAXDKPBIDS_TP = "Hier klicken um Gebote die hoeher als der Spieler SKP-Stand sind zu erlauben.";

	PLDKP_OPTIONS_MAXMINUSDKP = "Max. Minus-DKP (0 fuer keine)";
	PLDKP_OPTIONS_MAXMINUSDKP_TP = "Hier klicken um die maximalen Minus DKP die durch ein Gebot erreicht werden koennen festzulegen.";

	PLDKP_OPTIONS_NODKPPOINTS = "Keine Daten zu DKP Punkten oder ein bekanntes Punkte-AddOn gefunden!";

	PLDKP_OPTIONS_MINDKP_EQUIP = "Min DKP (EQUIP)";
	PLDKP_OPTIONS_MINDKP_EQUIP_TP = "Hier klicken um die mindest DKP für Ausrüstung zu definieren.";

	PLDKP_OPTIONS_MINDKP_SET = "Min DKP (SET-Item)";
	PLDKP_OPTIONS_MINDKP_SET_TP = "Hier klicken um die mindest DKP für ASet-Itemsusrüstung zu definieren.";

	PLDKP_OPTIONS_MINDKP_OH = "Min DKP (1H)";
	PLDKP_OPTIONS_MINDKP_OH_TP = "Hier klicken um die mindest DKP für 1H Waffern, Schilde, Off-Hands, Bogen, Schusswaffen, Relikte zu definieren.";

	PLDKP_OPTIONS_MINDKP_TH = "Min DKP (2H)";
	PLDKP_OPTIONS_MINDKP_TH_TP = "Hier klicken um die mindest DKP für 2H Waffen zu definieren.";

	PLDKP_OPTIONS_DEBUG_MODE = "Debug mode";
	PLDKP_OPTIONS_DEBUG_MODE_TP = "Hier klicken um den Debug Modus ein/aus zu schalten.";

	PLDKP_BUILD_OUTOFDATE = "PLDKP: Deine Version von PLDkp Bids ist veraltet! Bitte update auf die neuerste Version!"
	PLDKP_RECEIVED_NEW_DKPDATA = "PLDKP: Neue DKP Daten erhalten. Stand: %s von %s"
	PLDKP_RECEIVED_WINNER_INFO = "PLDKP: Neue Gewinnerinformationen erhalten: %s von %s"