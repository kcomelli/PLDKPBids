

local _, PLDKPBids = ...

PLDKPBids.pldkp_bGetDKP_called = false

local function transformDkpData()
    --PLDKPBids.dkp_data = gdkp
    PLDKPBids.dkp_info = DKPInfo

    PLDKPBids.dkp_data = {}
    PLDKPBids.dkp_data.players = {}
    for player, data in pairs(gdkp.players) do
        PLDKPBids.dkp_data.players[player] = {}

        PLDKPBids.dkp_data.players[player].dkp_current = data.DKP
        PLDKPBids.dkp_data.players[player].class = data.class
        PLDKPBids.dkp_data.players[player].rcount = data.rcount

        PLDKPBids.dkp_data.players[player].dkp_earned = 0.0
        PLDKPBids.dkp_data.players[player].dkp_spend = 0.0
        PLDKPBids.dkp_data.players[player].dkp_adjust = 0.0

        for type, val in pairs(data) do
            if string.find(tostring(type), "earned") then
                PLDKPBids.dkp_data.players[player].dkp_earned = PLDKPBids.dkp_data.players[player].dkp_earned + val
            end
            if string.find(tostring(type), "spend") then
                PLDKPBids.dkp_data.players[player].dkp_spend = PLDKPBids.dkp_data.players[player].dkp_spend + val
            end
            if string.find(tostring(type), "adjust") then
                PLDKPBids.dkp_data.players[player].dkp_adjust = PLDKPBids.dkp_data.players[player].dkp_adjust + val
            end
        end
    end
end

function PLDKPBids:PLDKP_CheckGetDkp()
    if ( gdkp ~= nil ) then     
        table.insert(PLDKP_HelpTable, PLDKP_Help_GetDKP);
        transformDkpData()
    end
end


