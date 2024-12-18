local Screen = require "widgets/screen"
local Image = require("widgets/image")
local ImageButton = require "widgets/imagebutton"

local TEMPLATES = require "widgets/redux/templates"

local Paper = Class(Screen, function(self, owner)
    Screen._ctor(self, "zskb_paper")
    self.owner = owner

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0, 0, 0, .5)
    black:SetOnClick(function() self:Close() end)
    black:SetHelpTextMessage("")

    self.root = self:AddChild(TEMPLATES.ScreenRoot("root"))
    self.bg = self.root:AddChild(Image("images/zskb_paper_ui.xml", "zskb_paper_ui.tex"))

    SetAutopaused(true)
end)

function Paper:Close()
    SetAutopaused(false)

    self.root:Kill()
    self.owner.HUD:CloseZskbPaperUIScreen()

    Paper._base.OnDestroy(self)
end

function Paper:OnControl(control, down)
    if Paper._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL or control == CONTROL_OPEN_DEBUG_CONSOLE) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:Close()
        return true
    end

    return false
end

return Paper
