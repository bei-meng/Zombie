AddModRPCHandler("zskb_zombie", "ui_rain", function(player)
    if not player or not player:HasTag("zskb_zombie") then
        return
    end

    local can_rain_control = player.replica.zskb_zombie and player.replica.zskb_zombie._can_rain_control
    if can_rain_control == nil or not can_rain_control:value() then -- avoid hack
        return
    end

    if TheWorld.state.precipitation ~= "none" then
        TheWorld:PushEvent("ms_forceprecipitation", false)
    else
        TheWorld:PushEvent("ms_forceprecipitation", true)
    end
    SpawnPrefab("fx_book_rain").Transform:SetPosition(player:GetPosition():Get())
end)

AddModRPCHandler("zskb_zombie", "ui_nightvision", function(player)
    if not player or not player:HasTag("zskb_zombie") then
        return
    end

    local isnight = TheWorld.state.isnight and not TheWorld.state.isfullmoon
    local current_nightvision = player._forced_nightvision and player._forced_nightvision:value() or false
    if isnight then
        player:SetForcedNightVision(not current_nightvision)
        player.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_" .. (current_nightvision and "off" or "on"))
    end
end)

AddClientModRPCHandler("zskb_zombie", "paper_open", function()
    if ThePlayer ~= nil and ThePlayer.HUD.ZskbPaperUIShow ~= nil then
        ThePlayer.HUD:ZskbPaperUIShow()
    end
end)
