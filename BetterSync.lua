---
--- Title: BetterSync™
--- Author: superyu'#7167, special thanks to april#0001, gowork88#1556 and Shady#0001
--- Description: BetterSync is a lua Extention for Aimware, it's purpose is to add more configuration to the Anti-Aimbot, it heavily focuses on the desync part.
---

--- Todo list (Ignore this, it's only for me (Superyu))
--- > Make sway using globals.CurTime() to not make it rely on fps
--- > Improve code performance
--- > Improve code generally.

--- Auto updater Variables
local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/superyor/BetterSync/master/BetterSync.lua";
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/superyor/BetterSync/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it.")
local VERSION_NUMBER = "2.0.0"; --- This too
local version_check_done = false;
local update_downloaded = false;
local update_available = false;

--- Window Stuff for Bettersync
local betterSync_wnd = gui.Window("rbot_bettersync_wnd", "BetterSync™ | v" .. VERSION_NUMBER, 0 , 0, 525, 705);
local betterSyncShow = gui.Checkbox(gui.Reference("RAGE", "MAIN", "Anti-Aim Main"), "rbot_bettersync_show", "Show BetterSync™", 0);

--- Window Groups for Bettersync
local rbot_bettersync_desync_grp = gui.Groupbox(betterSync_wnd, "Desync", 15, 15, 240, 325);
local rbot_bettersync_fakelag_grp = gui.Groupbox(betterSync_wnd, "Fakelag", 15, 15+15+325, 240, 175)
local rbot_bettersync_misc_grp = gui.Groupbox(betterSync_wnd, "Misc", 15, 300+200+30+15, 240, 96)
local rbot_bettersync_sway_grp = gui.Groupbox(betterSync_wnd, "Sway", 255+15, 15, 240, 220 );
local rbot_bettersync_manualaa_grp = gui.Groupbox(betterSync_wnd, "Manual AA", 255+15, 220+15+15, 240, 240 );
local rbot_bettersync_info_grp = gui.Groupbox(betterSync_wnd, "Information", 255+15, 220+30+240+15, 240, 135 )

--- Desync GUI Stuff
local desyncMode = gui.Combobox(rbot_bettersync_desync_grp,"rbot_bettersync_desyncmode", "Desync Mode", "Off", "Eye Angles", "Sway", "Custom") --- Credits to april for the idea :D
local eyeAnglesInsecure = gui.Checkbox(rbot_bettersync_desync_grp, "rbot_bettersync_eyeangles_insecure", "Eye Angle Insecure Mode", 0);
local desyncRange = gui.Slider( rbot_bettersync_desync_grp, "rbot_bettersync_desync_range", "Custom Width", 0, -60, 60);
local InverterKey = gui.Keybox(rbot_bettersync_desync_grp, "rbot_bettersync_desync_range_inverter", "Inverter Key", 0);

local antiaimOptions = gui.Multibox(rbot_bettersync_desync_grp, "Options")
local twist = gui.Checkbox(antiaimOptions, "rbot_bettersync_twist", "Twist", 0)
local antilby  = gui.Checkbox(antiaimOptions, "rbot_bettersync_antilby", "Anti-LBY", 0);
local headCentering = gui.Checkbox( antiaimOptions, "rbot_bettersync_headcentering", "Head Centering", 0);
local fakeMovingSide = gui.Combobox( rbot_bettersync_desync_grp, "rbot_bettersync_balanceifmoving", "Moving Fake Side", "Off", "Left", "Right");
local customOffset = gui.Slider(rbot_bettersync_desync_grp, "rbot_bettersync_offset", "Custom Offset", 0, -180, 180);

--- Fakelag GUI Stuff
local chokeLimit = gui.Slider(rbot_bettersync_fakelag_grp, "rbot_bettersync_chokelimit", "Choke limit", 0, 0, 62);
local chokeOnShot = gui.Combobox(rbot_bettersync_fakelag_grp, "msc_fakelag_onshot", "Choke On Shot", "Off", "Inbuilt", "Sendpacket")
local chokeOnShotValue = gui.Slider(rbot_bettersync_fakelag_grp, "msc_fakelag_onshot_value", "On Shot Length", 16, 1, 62)

--- Fixes GUI Stuff
local jumpscoutFix = gui.Checkbox(rbot_bettersync_misc_grp, "rbot_bettersync_fixes_jumpscout", "Fix Jumpscout", 0)
local fakeduckFix = gui.Checkbox(rbot_bettersync_misc_grp, "rbot_bettersync_fixes_fakeduckfakelag", "Fix Fakeduck", 0)
local pulseFakeEnable = gui.Checkbox( rbot_bettersync_misc_grp, "rbot_bettersync_msc_pulsefake", "Pulsating Fake Chams", 0);
local pulseFakeSpeed = 1
local pulseFakeRange1 = 15
local pulseFakeRange2 = 50

---Sway GUI Stuff
local swaySwap = gui.Checkbox( rbot_bettersync_sway_grp, "rbot_bettersync_sway_swap", "Auto Swap Side", 1)
local swaySpeed = gui.Slider( rbot_bettersync_sway_grp, "rbot_bettersync_sway_speed", "Speed", 1, 0.1, 7.5);
local swayRange1 = gui.Slider( rbot_bettersync_sway_grp, "rbot_bettersync_sway_rangestart", "Range Start", -60, -60, 60);
local swayRange2 = gui.Slider( rbot_bettersync_sway_grp, "rbot_bettersync_sway_rangeend", "Range End", 60, -60, 60);
local swayDeadzone = gui.Slider( rbot_bettersync_sway_grp, "rbot_bettersync_sway_deadzone", "Deadzone", 1, 1, 60);

--- Manual AA GUI Stuff
local creditsManualAA = gui.Text(rbot_bettersync_manualaa_grp, "Thanks to gowork88#1556." )
local ManualAAEnable = gui.Checkbox(rbot_bettersync_manualaa_grp, "Enable", "Manual AA", 0)
local AntiAimleft = gui.Keybox(rbot_bettersync_manualaa_grp, "Anti-Aim_left", "Left Keybind", 0);
local AntiAimRight = gui.Keybox(rbot_bettersync_manualaa_grp, "Anti-Aim_Right", "Right Keybind", 0);
local AntiAimBack = gui.Keybox(rbot_bettersync_manualaa_grp, "Anti-Aim_Back", "Back Keybind", 0);
local AntiAimRangeLeft = gui.Slider(rbot_bettersync_manualaa_grp, "AntiAimRangeLeft", "AntiAim Range Left", 0, -180, 180);
local AntiAimRangeRight = gui.Slider(rbot_bettersync_manualaa_grp, "AntiAimRangeRight", "AntiAim Range Right", 0, -180, 180);

--- Information GUI Stuff
local realInfo = gui.Text(rbot_bettersync_info_grp, "")
local fakeInfo = gui.Text(rbot_bettersync_info_grp, "")
local lbyInfo = gui.Text(rbot_bettersync_info_grp, "")
local insecureInfo = gui.Text(rbot_bettersync_info_grp, "")

--- Manual AA Fonts
local rifk7_font = draw.CreateFont("Verdana", 20, 700);
local arrow_font = draw.CreateFont("Marlett", 37, 500);
local normal = draw.CreateFont("Arial")

--- BetterSync Variables
local pLocal;
local max2, min2 = 0, 0;
local cs2, cd2 = 0, 0;
local max, min = 0, 0;
local cs, cd = 0, 0;
local swayVal;
local offset = 0;
local menuPressed = 1;
local manualAdd = 0;
local fakeduckKey;
local shotTime = globals.CurTime();
local shooting = false;
local fakelagRecover = true;
local pngData = http.Get("\32\32\32\32\104\116\116\112\115\58\47\47\105\46\105\109\103\117\114\46\99\111\109\47\114\98\65\118\51\51\74\46\112\110\103\10");
local imgRGBA, imgWidth, imgHeight = common.DecodePNG(pngData);
local texture = draw.CreateTexture(imgRGBA, imgWidth, imgHeight)
local legitSafety = false;
local del = globals.CurTime() + 0.100
local inFreezeTime = false;

--- Manual AA Variables
local LeftKey = 0;
local BackKey = 0;
local RightKey = 0;

--- Listeners
client.AllowListener("round_freeze_end")
client.AllowListener("round_start")
client.AllowListener("weapon_fire")

--- Code

local function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function TIME_TO_TICKS(time)
    local TICK_INTERVAL	= globals.TickInterval()
    return round((0.5 + (time) / TICK_INTERVAL), 0);
end

local function TICKS_TO_TIME(ticks)
    local TICK_INTERVAL	= globals.TickInterval()
    return TICK_INTERVAL * ticks
end

local function updateInformation()

    if engine.GetMapName() ~= "" then

        if pLocal and pLocal:IsAlive() then
            local rx, ry = entities.GetLocalPlayer():GetProp('m_angEyeAngles')
            local local_lby = entities.GetLocalPlayer():GetProp('m_flLowerBodyYawTarget')

            local rLby = round(local_lby, 1)
            local rReal = round(ry, 1)

            realInfo:SetText("Real: " .. rReal .. "°")
            lbyInfo:SetText("Fake LBY: " .. rLby .. "°")
            insecureInfo:SetText(rReal == rLby and "Insecure: False" or "Insecure: True")
        else
            realInfo:SetText("Please be alive to see your angle info.")
            fakeInfo:SetText("")
            insecureInfo:SetText("")
            lbyInfo:SetText("Made with love by Superyu'#7167")
        end

    else
        realInfo:SetText("Get into a game to see your angle info.")
        fakeInfo:SetText("")
        insecureInfo:SetText("")
        lbyInfo:SetText("Made with love by Superyu'#7167")
    end

end

local function safetyCheck()
    if (gui.GetValue("lbot_active")) and not gui.GetValue("rbot_active") then
        legitSafety = true;
    else
        legitSafety = false;
    end
end

local function pulseFakeChams()

    if (pulseFakeEnable:GetValue()) then

        local speed2 = pulseFakeSpeed

        if pulseFakeRange1 < pulseFakeRange2 then
            min2 = pulseFakeRange1
            max2 = pulseFakeRange2
        else
            min2 = pulseFakeRange2
            max2 = pulseFakeRange1
        end
    
        if (cs2 >= max2) then
            cd2 = 1;
        elseif (cs2 <= min2 + speed2) then
            cd2 = 0;
        end
        
        if (cd2 == 0) then
            cs2 = cs2 + speed2;
        elseif (cd2 == 1) then
            cs2 = cs2 - speed2;
        end

        local alpha = round(cs2, 0)
        local r, g, b, a = gui.GetValue("clr_chams_ghost_client");
        gui.SetValue("clr_chams_ghost_client", r, g, b, alpha);
    end
end

local function fakelag()

    local fl = false;
    local flMode = 0;
    local flv = chokeLimit:GetValue()

    local sv_maxusrcmdprocessticks = client.GetConVar("sv_maxusrcmdprocessticks")
    local flLimit = sv_maxusrcmdprocessticks;
 
    if twist:GetValue() then
        flv = 4
        flMode = 0
        fl = true
        fakelagRecover = false
    end

    if fakelagRecover then 
        flMode = gui.GetValue("msc_fakelag_mode")
    end

    if entities.GetLocalPlayer() ~= nil then
        fakeduckKey = gui.GetValue("rbot_antiaim_fakeduck")
        if fakeduckFix:GetValue() and fakeduckKey ~= nil then
            if input.IsButtonDown(fakeduckKey) then
                fl = true
                flv = 4
                gui.SetValue("msc_fakelag_mode", 0)
                fakelagRecover = true;
            else
                fakelagRecover = false;
            end
        end
    end 

    if shooting and chokeOnShot:GetValue() == 1 then

        fl = true;
        flMode = 0
        flv = chokeOnShotValue:GetValue();
        flLimit = 61
        fakelagRecover = true;

        if shotTime + TICKS_TO_TIME(chokeOnShotValue:GetValue()) < globals.CurTime() then
            shooting = false;
            fakelagRecover =  false;
       end
    end

    if legitSafety then
        fl = false
    else
        if (flv > 0) then
            fl = true
        else
            fl = false
        end
    end

    gui.SetValue("msc_fakelag_enable", fl)
    gui.SetValue("msc_fakelag_value", flv)
    gui.SetValue("msc_fakelag_mode", flMode)
    gui.SetValue("msc_fakelag_limit", flLimit)

end

local function menu()

    if input.IsButtonPressed(gui.GetValue("msc_menutoggle")) then
        menuPressed = menuPressed == 0 and 1 or 0;
    end

    if (betterSyncShow:GetValue()) then
        betterSync_wnd:SetActive(menuPressed);
    else
        betterSync_wnd:SetActive(0);
    end

    if (betterSync_wnd:IsActive()) then
        local w, h = draw.GetScreenSize()
        local x = w-138
        local y = h-90
        
        draw.SetTexture(texture)
        draw.Color(255, 255, 255, 255)
        draw.FilledRect(x, y, x+imgWidth, y+imgHeight)
    end
end

local function sway()

    if desyncMode:GetValue() == 2 then

        local speed = swaySpeed:GetValue()

        if swayRange1:GetValue() < swayRange2:GetValue() then
            min = swayRange1:GetValue()
            max = swayRange2:GetValue()
        else
            min = swayRange2:GetValue()
            max = swayRange1:GetValue()
        end

        if (cs >= max) then
            cd = 1;
        elseif (cs <= min + speed) then
            cd = 0;
        end
        
        if (cd == 0) then
            cs = cs + speed;
        elseif (cd == 1) then
            cs = cs - speed;
        end

        local deadzoneP = swayDeadzone:GetValue()
        local deadzoneN = deadzoneP * -1

        if cs > 0 then
            if cs < deadzoneP then
                cs = deadzoneN
            end
        end

        if cs < 0 then
            if cs > deadzoneN then
                cs = deadzoneP
            end
        end

        swayVal = cs;
    end
end

local function desync()

    local dv = 0;
    local invert;

    if (InverterKey:GetValue() ~= 0) then
        if (input.IsButtonPressed(InverterKey:GetValue())) then
            invert = true
        end
    end

    if invert then
        desyncRange:SetValue(desyncRange:GetValue()*-1)
    end

    local width = desyncRange:GetValue();

    if width < 0 then
        dv = 3
    elseif width == 0 then
        dv = 1
    else
        dv = 2
    end

    if desyncMode:GetValue() == 2 and swaySwap:GetValue() then
        if swayVal < 0 then
            dv = 3
        elseif swayVal == 0 then
            dv = 1
        else
            dv = 2
        end
    end

    if (fakeMovingSide:GetValue() > 0) then
        if (entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]") ~= nil and entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" ) ~= nil) then
            if (math.sqrt(entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + entities.GetLocalPlayer():GetPropFloat( "localdata", "m_vecVelocity[1]" )^2) > 3) then
                if fakeMovingSide:GetValue() == 1 then dv = 3 end
                if fakeMovingSide:GetValue() == 2 then dv = 2 end
            end
        end
    end

    if not pLocal or not pLocal:IsAlive() then
        return
    end

    if desyncMode:GetValue() == 1 then
        if not eyeAnglesInsecure:GetValue() then
            dv = 1
        end
    end

    fakeduckKey = gui.GetValue("rbot_antiaim_fakeduck")
    if fakeduckFix:GetValue() and fakeduckKey ~= nil then
        if input.IsButtonDown(fakeduckKey) then
            dv = 0
        end
    end

    gui.SetValue("rbot_antiaim_stand_desync", dv)
    gui.SetValue("rbot_antiaim_move_desync", dv)
    gui.SetValue("rbot_antiaim_edge_desync", dv)
    gui.SetValue("lbot_antiaim", dv)

    if desyncMode:GetValue() == 2 then
        width = swayVal;
    end

    local FixedlowerbodyTarget;
    if desyncMode:GetValue() ~= 0 and desyncMode:GetValue() ~= 1 then
        FixedlowerbodyTarget = pLocal:GetProp("m_angEyeAngles[1]") + width
    else
        FixedlowerbodyTarget = pLocal:GetProp("m_angEyeAngles[1]")
    end

    if not inFreezeTime then
        pLocal:SetProp("m_flLowerBodyYawTarget", FixedlowerbodyTarget)
    end
end

local function offSetting() --- THIS ONLY WORKS FOR AUTO OR WEAPONS WITH SIMILAR MAXDELTA BECAUSE AIMWARE DOESN'T ALLOW ME TO GET MAXDESYNCDELTA YET.

    if headCentering:GetValue() == true then
        
        if gui.GetValue("rbot_antiaim_stand_desync") == 2  then
            offset = 20
        elseif gui.GetValue("rbot_antiaim_stand_desync") == 3 then
            offset = -14
        else
            offset = 14
        end
    else 
        offset = 0
    end

    offset = offset + customOffset:GetValue();

    gui.SetValue("rbot_antiaim_stand_real_add", offset + manualAdd)
    gui.SetValue("rbot_antiaim_move_real_add", offset + manualAdd)
    gui.SetValue("rbot_antiaim_edge_real_add", offset + manualAdd)

end

-- Manual AA, credits to "El Credito"/gowork88#1556.

local function draw_indicator()

    local active = ManualAAEnable:GetValue()

    if active then
        local w, h = draw.GetScreenSize();
        draw.SetFont(rifk7_font)
        if (LeftKey == 1) then
            draw.Color(255, 0, 0, 255)
            draw.Text(6, h - 60, "Manual");
            draw.TextShadow(6, h - 60, "Manual");
            draw.SetFont(arrow_font)
            draw.Text( w/2 - 100, h/2 - 21, "3");
            draw.SetFont(rifk7_font)
        elseif (BackKey == 1) then
            draw.Color(255, 0, 0, 255)
            draw.Text(6, h - 60, "Manual");
            draw.TextShadow(6, h - 60, "Manual");
            draw.SetFont(arrow_font)
            draw.Text( w/2 - 21, h/2 + 60, "6");
            draw.SetFont(rifk7_font)
        elseif (RightKey == 1) then
            draw.Color(255, 0, 0, 255);
            draw.Text(6, h - 60, "Manual");
            draw.TextShadow(6, h - 60, "Manual");
            draw.SetFont(arrow_font)
            draw.Text( w/2 + 60, h/2 - 21, "4");
            draw.SetFont(rifk7_font)
        elseif ((LeftKey == 0) and (BackKey == 0) and (RightKey == 0)) then
            draw.Color(47, 255, 0, 255);
            draw.Text(6, h - 60, "Disabled");
            draw.TextShadow(6, h - 60, "Disabled");
        end
        draw.SetFont(normal)
    end
end

local function changeAA()

    gui.SetValue("rbot_antiaim_at_targets", false);
    
    if (LeftKey == 1) then
        manualAdd = AntiAimRangeLeft:GetValue()
        manualAdd = AntiAimRangeLeft:GetValue()
        
    elseif (RightKey == 1) then
        manualAdd = AntiAimRangeRight:GetValue()
        manualAdd = AntiAimRangeRight:GetValue()
        
    elseif (BackKey == 1) then
        manualAdd = 0
        manualAdd = 0
        
    elseif ((LeftKey == 0) and (RightKey == 0) and (BackKey == 0)) then
        manualAdd = 0
        manualAdd = 0
    end
end

local function setterValue(left, right, back)
    if (left) then
        if (LeftKey == 1) then
            LeftKey = 0
        else
            LeftKey = 1;RightKey = 0;BackKey = 0
        end
    elseif (right) then
        if (RightKey == 1) then
            RightKey = 0
        else
            RightKey = 1;LeftKey = 0;BackKey = 0
        end
    elseif (back) then
        if (BackKey == 1) then
            BackKey = 0
        else
            BackKey = 1;LeftKey = 0;RightKey = 0
        end
    end
    changeAA()
end

local function mainManualAA()
    if (ManualAAEnable:GetValue()) then
        if AntiAimleft:GetValue() ~= 0 then
            if input.IsButtonPressed(AntiAimleft:GetValue()) then
                setterValue(true, false, false);
            end
        end
        if AntiAimBack:GetValue() ~= 0 then
            if input.IsButtonPressed(AntiAimBack:GetValue()) then
                setterValue(false, false, true);
            end
        end
        if AntiAimRight:GetValue() ~= 0 then
            if input.IsButtonPressed(AntiAimRight:GetValue()) then
            setterValue(false, true, false);
            end
        end
        draw_indicator()
    end 
end

--- Auto updater by ShadyRetard/Shady#0001

--- Actual code

local function updateEventHandler()
    if (update_available and not update_downloaded) then
        if (gui.GetValue("lua_allow_cfg") == false) then
            draw.Color(255, 0, 0, 255);
            draw.Text(0, 0, "[BetterSync] An update is available, please enable Lua Allow Config and Lua Editing in the settings tab");
        else
            local new_version_content = http.Get(SCRIPT_FILE_ADDR);
            local old_script = file.Open(SCRIPT_FILE_NAME, "w");
            old_script:Write(new_version_content);
            old_script:Close();
            update_available = false;
            update_downloaded = true;
        end
    end

    if (update_downloaded) then
        draw.Color(255, 0, 0, 255);
        draw.Text(0, 0, "[BetterSync] An update has automatically been downloaded, please reload the BetterSync script");
        return;
    end

    if (not version_check_done) then
        if (gui.GetValue("lua_allow_http") == false) then
            draw.Color(255, 0, 0, 255);
            draw.Text(0, 0, "[BetterSync] Please enable Lua HTTP Connections in your settings tab to use this script");
            return;
        end

        version_check_done = true;
        local version = http.Get(VERSION_FILE_ADDR);
        if (version ~= VERSION_NUMBER) then
            update_available = true;
        end
    end
end

callbacks.Register("Draw", updateEventHandler);

callbacks.Register( "Draw", function()
    pLocal = entities.GetLocalPlayer()

    --- Important Stuff
    menu()
    safetyCheck()

    --- The rest
    updateInformation()
    fakelag()
    offSetting()
    mainManualAA()
    pulseFakeChams()

    if desyncMode:GetValue() == 2 then
        sway()
    end

    if desyncMode:GetValue() > 0 then
        desync()
    end
end
);

callbacks.Register( "CreateMove", function(pCmd)

    if legitSafety then
        return
    end

    if not pLocal then
        return
    end

    dx, dy = pCmd:GetViewAngles()

    if engine.GetMapName() ~= nil then
        fakeInfo:SetText("Fake (Inconsistent): " .. round(dy, 1) .. "°")
    end

    local switch
    local vel = math.sqrt(pLocal:GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + pLocal:GetPropFloat( "localdata", "m_vecVelocity[1]" )^2)

    if jumpscoutFix:GetValue() then
        if vel > 5 then
            gui.SetValue("msc_autostrafer_enable", 1)
        else
            gui.SetValue("msc_autostrafer_enable", 0)
        end
    end

    if shooting and chokeOnShot:GetValue() == 2 then
        gui.SetValue("msc_fakelag_limit", 61)
        pCmd:SetSendPacket(false)
        if shotTime + TICKS_TO_TIME(chokeOnShotValue:GetValue()) < globals.CurTime() then
            shooting = false;
            pCmd:SetSendPacket(true)
       end
    end

    if del < globals.CurTime() then
        switch = not switch
        del = globals.CurTime() + 0.050
    end

    if vel > 5 then
        del = globals.CurTime() + 0.050
        return
    end

    if antilby:GetValue() then
        if switch then
            pCmd:SetSideMove(3)
        else
            pCmd:SetSideMove(-3)
        end
    end

end)

callbacks.Register("FireGameEvent", function(event)

    if event:GetName() == "round_freeze_end" then
        inFreezeTime = false;
    end

    if event:GetName() == "round_start" then
        inFreezeTime = true;
    end

    if legitSafety then
        return
    end

    if not pLocal then
        return
    end

    if chokeOnShot:GetValue() ~= 0 then

        if event:GetName() == "weapon_fire" then
            EventUserId = event:GetInt("userid")
            local pLocalInfo = client.GetPlayerInfo(client.GetLocalPlayerIndex())

            if pLocalInfo["UserID"] == EventUserId then 
                shooting = true
                shotTime = globals.CurTime()
            end
        end
    end

end)
