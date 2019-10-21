

local _, PLDKPBids = ...

PLDKPBids.pldkp_bGetDKP_called = false

function PLDKPBids:PLDKP_CheckGetDkp()
    if ( gdkp ~= nil ) then     
        table.insert(PLDKP_HelpTable, PLDKP_Help_GetDKP);
        transformDkpData()
    end
end

local function transformDkpData()
    PLDKPBids.dkp_data = gdkp
    PLDKPBids.dkp_info = DKPInfo
end
