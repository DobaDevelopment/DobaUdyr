--[[    DOBA DEVELOPMENT, ITS MY HOBBY ENJOY    ]]
require("common.log")
module("Doba Udyr", package.seeall, log.setup)
local clock = os.clock
local insert, sort = table.insert, table.sort
local huge, min, max, abs = math.huge, math.min, math.max, math.abs

if Player.CharName ~= "Udyr" then return end

local _SDK = _G.CoreEx
local Game = _SDK.Game
local Input = _SDK.Input
local HealthPred, Prediction = _G.Libs.HealthPred, _G.Libs.Prediction
local Orbwalker, Collision = _G.Libs.Orbwalker, _G.Libs.CollisionLib
local DmgLib, ImmobileLib = _G.Libs.DamageLib, _G.Libs.ImmobileLib
local Spell, Menu = _G.Libs.Spell, _G.Libs.NewMenu
local TS = _G.Libs.TargetSelector()
local ObjManager, EventManager = _SDK.ObjectManager, _SDK.EventManager
local Enums, Geometry, Renderer =_SDK.Enums, _SDK.Geometry, _SDK.Renderer
local Udyr = {}
local UdyrPrioHi = {}
local UdyrPrioNo = {}

--[[    MENU SECTION    ]]
function Udyr.LoadMenu()
    Menu.RegisterMenu("Doba Udyr", "Doba Udyr", function()
	Menu.NewTree("Combo", "Combo", function ()
        Menu.Checkbox("Combo.CastQ","Cast Q",true)
        Menu.Checkbox("Combo.CastW","Cast W",true)
        Menu.Checkbox("Combo.CastE","Cast E",true)
        Menu.Checkbox("Combo.CastR","Cast R",true)end)
    Menu.NewTree("Harass", "Harass Settings", function()
        Menu.ColoredText("Mana Percentage", 0xFFD700FF, true)
        Menu.Slider("ManaSlider","",50,0,100)
        Menu.Checkbox("Harass.CastQ","Cast Q",true)
        Menu.Checkbox("Harass.CastR","Cast R",true) end)
	Menu.NewTree("Waveclear", "Clear", function ()
        Menu.ColoredText("Mana Percentage", 0xFFD700FF, true)
        Menu.Slider("ManaSliderLane","",50,0,100)
		Menu.ColoredText("Lane", 0xFFD700FF, true)
        Menu.Checkbox("Lane.Q","Cast Q",true)
		Menu.Checkbox("Lane.W","Cast W",true)
        Menu.Checkbox("Lane.R","Cast R",true)
        Menu.Separator()
        Menu.ColoredText("Mana Percentage", 0xFFD700FF, true)
        Menu.Slider("ManaSliderJungle","",50,0,100)
		Menu.ColoredText("Jungle", 0xFFD700FF, true)
        Menu.Checkbox("Jungle.Q",   "Use Q", true)
        Menu.Checkbox("Jungle.W",   "Use W", true)
        Menu.Checkbox("Jungle.R",   "Use R", true)
        Menu.ColoredText("PushObjectives", 0xFFD700FF, true)
        Menu.Checkbox("PushObjectives.Q",   "Use Q", true)
        Menu.Checkbox("PushObjectives.R",   "Use R", true) end)
    Menu.NewTree("Draw", "Drawing Options", function()
        Menu.Checkbox("Drawing.E.Enabled",   "Draw E Range", true)
        Menu.ColorPicker("Drawing.E.Color", "Draw E Color", 0x3060f0ff) end) end)
end

--[[    SPELLS INFO SECTION / VIKI LOL CHAMP    ]]
local Q = Spell.Active({
    Slot = Enums.SpellSlots.Q,
    Range = 200,
    Key = "Q"
})
local W = Spell.Active({
    Slot = Enums.SpellSlots.W,
    Range = 200,
    Key = "W"
})
local E = Spell.Active({
    Slot = Enums.SpellSlots.E,
    Range = 1300,
    Key = "E"
})
local R = Spell.Active({
    Slot = Enums.SpellSlots.R,
    Range = 200,
    Key = "R"
})
--[[    USEFULL FUNCTION    ]]
local function GameIsAvailable()--Check if Game is On
	return not (Game.IsChatOpen() or Game.IsMinimized() or Player.IsDead or Player.IsRecalling)
end
local function CanCast(spell,mode)
    return spell:IsReady() and Menu.Get(mode .. ".Cast"..spell.Key)
end

local function GetTargets(spell)
    return {TS:GetTarget(spell.Range,true)}
end

local function Lane(spell)
    return Menu.Get("Lane."..spell.Key)
end
local function PushObjectives(spell)
    return Menu.Get("PushObjectives."..spell.Key)
end

local function Jungle(spell)
    return Menu.Get("Jungle."..spell.Key)
end
function Udyr.OnNormalPriority()
    if not GameIsAvailable() then return end
        local ModeToExecute = UdyrPrioHi[Orbwalker.GetMode()]
    if ModeToExecute then
        ModeToExecute()
    end
end
function Udyr.OnHighPriority()
    if not GameIsAvailable() then return end
        local ModeToExecute = UdyrPrioNo[Orbwalker.GetMode()]
    if ModeToExecute then
        ModeToExecute()
    end
end
--[[    COMBO SECTION    ]]
function UdyrPrioHi.Combo()
    for k, v in pairs(GetTargets(E)) do
        if CanCast(E,"Combo") then
            if E:Cast() then
                    return end end end
    for k, v in pairs(GetTargets(R)) do
        if CanCast(R,"Combo") then
            if R:Cast() then
                    return end end end
function UdyrPrioNo.Combo()
    for k, v in pairs(GetTargets(Q)) do
        if CanCast(Q,"Combo") then
           if Q:Cast() then
                   return end end end end
    for k, v in pairs(GetTargets(W)) do
        if CanCast(W,"Combo") then
            if W:Cast() then
                    return end end end end
--[[    CLEAR SECTION    ]]
function UdyrPrioNo.Waveclear()
    --[[    JUNGLE CLEAR SECTION    ]]
    if Menu.Get("ManaSliderJungle") < (Player.ManaPercent * 100) then
    if Jungle(Q) and Q:IsReady() then
        for k, v in pairs(ObjManager.Get("neutral", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and Q:IsInRange(minion) then
                    if Q:Cast() then
                      return end end end end end
    if Jungle(W) and W:IsReady() then
        for k, v in pairs(ObjManager.Get("neutral", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and W:IsInRange(minion) then
                    if W:Cast() then
                      return end end end end end
    if Jungle(R) and R:IsReady() then
        for k, v in pairs(ObjManager.Get("neutral", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and R:IsInRange(minion) then
                    if R:Cast() then
                        return end end end end end end
--[[    LANE CLEAR SECTION    ]]
    if Menu.Get("ManaSliderLane") < (Player.ManaPercent * 100) then
    if Lane(Q) and Q:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and Q:IsInRange(minion) then
                    if Q:Cast() then
                      return end end end end end
    if Lane(W) and W:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and W:IsInRange(minion) then
                    if W:Cast() then
                      return end end end end end
    if Lane(R) and R:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "minions")) do
          local minion = v.AsAI
            if minion then
                if minion.IsTargetable and minion.MaxHealth > 6 and R:IsInRange(minion) then
                    if R:Cast() then
                      return end end end end end
--[[    OBJECTIVES PUSH SECTION    ]]
    if PushObjectives(Q) and Q:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "turrets")) do
            if Q:IsInRange(v) then
                if Q:Cast() then
                    return end end end end end
    if PushObjectives(R) and R:IsReady() then
        for k, v in pairs(ObjManager.Get("enemy", "turrets")) do
            if R:IsInRange(v) then
                if R:Cast() then
                    return end end end end end

--[[    HARASS SECTION    ]]
function UdyrPrioNo.Harass()
    if Menu.Get("ManaSlider") > (Player.ManaPercent * 100) then return end
    for k, v in pairs(GetTargets(R)) do
        if CanCast(R,"Harass") then
            if R:Cast() then return end end
        if CanCast(Q,"Harass") then
            if Q:Cast() then return end end end return end

--[[    DRAWINGS SECTION    ]]
function Udyr.OnDraw()
    local Pos = Player.Position
    local spells = {Q,W,E}
    for k, v in pairs(spells) do
        if Menu.Get("Drawing."..v.Key..".Enabled", true) then
            Renderer.DrawCircle3D(Pos, v.Range, 30, 3, Menu.Get("Drawing."..v.Key..".Color")) end end end
function OnLoad()
    Udyr.LoadMenu()
    for eventName, eventId in pairs(Enums.Events) do
        if Udyr[eventName] then
            EventManager.RegisterCallback(eventId, Udyr[eventName]) end end return true end
