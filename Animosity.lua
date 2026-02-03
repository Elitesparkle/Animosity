Animosity = LibStub("AceAddon-3.0"):NewAddon("Animosity", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Animosity")

local CRLF = "\n "

local options = {
    name = "Animosity",
    handler = Animosity,
    type = "group",
    args = {
        Description = {
            order = 1,
            name = L["OPTIONS_SUBTITLE"] .. CRLF,
            type = "description",
            fontSize = "medium",
        },
        ProcGlow = {
            order = 2,
            name = L["PROC_GLOW_NAME"],
            desc = L["PROC_GLOW_DESC"],
            type = "select",
            width = "full",
            style = "radio",
            values = {
                [0] = L["PROC_GLOW_OPTION_0"],
                [1] = L["PROC_GLOW_OPTION_1"],
                [2] = L["PROC_GLOW_OPTION_2"]
            },
            set = function(_, value) Animosity.db.profile.ProcGlow = value end,
            get = function(_) return Animosity.db.profile.ProcGlow end,
        },
        ChannelAnimation = {
            name = L["CHANNEL_ANIMATION_NAME"],
            desc = L["CHANNEL_ANIMATION_DESC"],
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.ChannelAnimation = value end,
            get = function(_) return Animosity.db.profile.ChannelAnimation end,
        },
        CooldownOverAnimation = {
            name = L["COOLDOWN_OVER_ANIMATION_NAME"],
            desc = L["COOLDOWN_OVER_ANIMATION_DESC"],
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.CooldownOverAnimation = value end,
            get = function(_) return Animosity.db.profile.CooldownOverAnimation end,
        },
        InterruptAnimation = {
            name = L["INTERRUPT_ANIMATION_NAME"],
            desc = L["INTERRUPT_ANIMATION_DESC"],
            type = "toggle",
            width = "full",
            set = function(_, value) Animosity.db.profile.InterruptAnimation = value end,
            get = function(_) return Animosity.db.profile.InterruptAnimation end,
        },
        TargetingReticleAnimation = {
            name = L["TARGETING_RETICLE_NAME"],
            desc = L["TARGETING_RETICLE_DESC"],
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
end

function Animosity:OnEnable()

    hooksecurefunc(ActionButtonSpellAlertManager, "ShowAlert", function (_, button)
        if self.db.profile.ProcGlow == 1 and button.HasAction and button.SpellActivationAlert then
            button.SpellActivationAlert.ProcStartAnim:Stop()
            button.SpellActivationAlert.ProcStartFlipbook:SetAlpha(0)
            button.SpellActivationAlert.ProcLoop:Play()
        end
    end)

    hooksecurefunc("ActionButton_ApplyCooldown", function(cooldown)
        local show_gcd = self.db.profile.CooldownOverAnimation
        cooldown:SetDrawBling(show_gcd)
    end)

    local function HideCastAnimations(button)

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
