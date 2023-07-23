Animosity = LibStub("AceAddon-3.0"):NewAddon("Animosity", "AceConsole-3.0")

local options = {
    name = "Animosity",
    handler = Animosity,
    type = 'group',
    args = {
        Description = {
            order = 1,
            name = "Select the elements you want to see.",
            type = "description",
        },
        ProcGlow = {
            order = 2,
            name = "Proc Glow",
            desc = "Show the animation of the proc glow on Action Buttons.",
            type = "select",
            width = "full",
            style = "radio",
            values = {
                [0] = "None",
                [1] = "Active",
                [2] = "Start and Active"
            },
            set = function(_, value) Animosity.db.profile.ProcGlow = value end,
            get = function(_) return Animosity.db.profile.ProcGlow end,
        },
        ChannelAnimation = {
            name = "Channel Animation",
            desc = "Toggle the channel animation on Action Buttons.",
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.ChannelAnimation = value end,
            get = function(_) return Animosity.db.profile.ChannelAnimation end,
        },
        CooldownOverAnimation = {
            name = "Cooldown Over Animation",
            desc = "Toggle the cooldown over animation on Action Buttons.",
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.CooldownOverAnimation = value end,
            get = function(_) return Animosity.db.profile.CooldownOverAnimation end,
        },
        InterruptAnimation = {
            name = "Interrupt Animation",
            desc = "Toggle the interrupt animation on Action Buttons.",
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.InterruptAnimation = value end,
            get = function(_) return Animosity.db.profile.InterruptAnimation end,
        },
        TargetingReticleAnimation = {
            name = "Targeting Reticle Animation",
            desc = "Toggle the targeting reticle animation on Action Buttons.",
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.TargetingReticleAnimation = value end,
            get = function(_) return Animosity.db.profile.TargetingReticleAnimation end,
        },
    },
}

local defaults = {
    profile = {
        ProcGlow = 1,
        ChannelAnimation = false,
        CooldownOverAnimation = false,
        InterruptAnimation = false,
        TargetingReticleAnimation = false,
    },
}

function Animosity:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AnimosityDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Animosity", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Animosity", "Animosity")

    hooksecurefunc("ActionButton_SetupOverlayGlow", function(button)
        if self.db.profile.ProcGlow == 0 and button.SpellActivationAlert then
            button.SpellActivationAlert:SetAlpha(0)
        else
            button.SpellActivationAlert:SetAlpha(1)
        end
    end)

    hooksecurefunc("ActionButton_ShowOverlayGlow", function(button)
        if self.db.profile.ProcGlow == 1 and button.SpellActivationAlert then
            button.SpellActivationAlert.ProcStartAnim:Stop()
            button.SpellActivationAlert.ProcStartFlipbook:SetAlpha(0)
            button.SpellActivationAlert.ProcLoop:Play()
        end
    end)

    hooksecurefunc("ActionButtonCooldown_OnCooldownDone", function(cooldown)
        if not self.db.profile.CooldownOverAnimation then
            local cooldownFlash = cooldown:GetParent().CooldownFlash

            if cooldownFlash and cooldownFlash.FlashAnim:IsPlaying() then
                cooldownFlash.FlashAnim:Stop()
                cooldownFlash:Hide()
            end
        end
    end)

    local function HideCastAnimations(button)
        button.cooldown:SetDrawBling(true)

        hooksecurefunc(button, "PlaySpellCastAnim", function()
            if not self.db.profile.ChannelAnimation then
                button.SpellCastAnimFrame:Hide()
            end
        end)

        hooksecurefunc(button, "PlaySpellInterruptedAnim", function()
            if not self.db.profile.InterruptAnimation then
                button.InterruptDisplay:Hide()
            end
        end)

        hooksecurefunc(button, "PlayTargettingReticleAnim", function()
            if not self.db.profile.TargetingReticleAnimation then
                button.TargetReticleAnimFrame:Hide()
            end
        end)
    end

    -- Register known Action Buttons
    for _, button in pairs(ActionBarButtonEventsFrame.frames) do
        HideCastAnimations(button)
    end

    -- Watch for other Action Buttons
    hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
        HideCastAnimations(button)
    end)
end
