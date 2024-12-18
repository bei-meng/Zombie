local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"

local HUD_ICON = Class(Widget, function(self, owner)
    Widget._ctor(self, "zskb_hud_icon")
    self.owner = owner

    self.root = self:AddChild(Widget())

    self.nightvision = self.root:AddChild(ImageButton("images/zskb_ui.xml", "zskb_hud_nightvision_icon.tex"))
    self.rain = self.root:AddChild(ImageButton("images/zskb_ui.xml", "zskb_hud_rain_icon.tex"))

    self.nightvision:SetPosition(-35, 0)
    self.rain:SetPosition(35, 0)

    self.nightvision:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["zskb_zombie"]["ui_nightvision"])
    end)
    self.rain:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["zskb_zombie"]["ui_rain"])
    end)

    self.root:SetHAnchor(ANCHOR_RIGHT)
    self.root:SetVAnchor(ANCHOR_TOP)

    self:StartUpdating()

    self.pt_x = -340
    self.pt_y = -185
end)

function HUD_ICON:OnUpdate(dt)
    local sw, sh = TheSim:GetScreenSize()
    local scale = TheFrontEnd:GetHUDScale()
    self.root:SetPosition(self.pt_x / 1920 * sw * scale, self.pt_y / 1080 * sh * scale)
    self.root:SetScale(scale * 1.1 / 1920 * sw)
end

return HUD_ICON
