Animosity = LibStub("AceAddon-3.0"):NewAddon("Animosity", "AceConsole-3.0")

local options = {
    name = "Animosity",
    handler = Animosity,
    type = 'group',
    args = {
        Description = {
            name = "Enable the elements you want to see. Reload to apply changes.",
            type = "description",
            order = 1,
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
        ProcGlow = {
            name = "Proc Glow",
            desc = "Toggle the proc glow on Action Buttons.",
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.ProcGlow = value end,
            get = function(_) return Animosity.db.profile.ProcGlow end,
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
        ChannelAnimation = false,
        CooldownOverAnimation = false,
        InterruptAnimation = false,
        ProcGlow = false,
        TargetingReticleAnimation = false,
    },
}

function Animosity:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AnimosityDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Animosity", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Animosity", "Animosity")

    if not self.db.profile.ProcGlow then
        hooksecurefunc("ActionButton_SetupOverlayGlow", function(button)
            if button.SpellActivationAlert then
                button.SpellActivationAlert:SetAlpha(0)
            end
        end)
    end

    if not self.db.profile.CooldownOverAnimation then
        hooksecurefunc("ActionButtonCooldown_OnCooldownDone", function(cooldown)
            local cooldownFlash = cooldown:GetParent().CooldownFlash
        
            if cooldownFlash and cooldownFlash.FlashAnim:IsPlaying() then
                cooldownFlash.FlashAnim:Stop()
                cooldownFlash:Hide()
            end
        end)
    end

    local function HideCastAnimations(button)
        button.cooldown:SetDrawBling(true)

        if not self.db.profile.ChannelAnimation then
            hooksecurefunc(button, "PlaySpellCastAnim", function()
                button.SpellCastAnimFrame:Hide()
            end)
        end

        if not self.db.profile.InterruptAnimation then
            hooksecurefunc(button, "PlaySpellInterruptedAnim", function()
                button.InterruptDisplay:Hide()
            end)
        end

        if not self.db.profile.TargetingReticleAnimation then
            hooksecurefunc(button, "PlayTargettingReticleAnim", function()
                button.TargetReticleAnimFrame:Hide()
            end)
        end
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
