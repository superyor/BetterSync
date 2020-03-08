---
--- Title: RageSu™
--- Author: superyu'#7167, special thanks to april#0001, gowork88#1556 and Shady#0001
--- Description: RageSu is a lua Extention for Aimware, it's purpose is to add more configuration to the Anti-Aimbot, it heavily focuses on the desync part.
---

---Todo: 
--- [] Add manual AA

--- Auto updater Variables
local SCRIPT_FILE_NAME = GetScriptName();
local SCRIPT_FILE_ADDR = "https://raw.githubusercontent.com/superyor/RageSU/master/RageSU.lua";
local BETA_SCIPT_FILE_ADDR = "https://raw.githubusercontent.com/superyor/RageSU/master/RageSU%20Beta.lua"
local VERSION_FILE_ADDR = "https://raw.githubusercontent.com/superyor/RageSU/master/version.txt"; --- in case of update i need to update this. (Note by superyu'#7167 "so i don't forget it."
local VERSION_NUMBER = "4.1"; --- This too
local version_check_done = false;
local update_downloaded = false;
local update_available = false;
local betaUpdateDownloaded = false;
local isBeta = false;

--- Auto Updater GUI Stuff
local RAGESU_UPDATER_TAB = gui.Tab(gui.Reference("Settings"), "ragesu.updater.tab", "RageSu™ Autoupdater")
local RAGESU_UPDATER_GROUP = gui.Groupbox(RAGESU_UPDATER_TAB, "Auto Updater for RageSu™ | v" .. VERSION_NUMBER, 15, 15, 600, 600)
local RAGESU_UPDATER_TEXT = gui.Text(RAGESU_UPDATER_GROUP, "")

local function betaUpdate()

    if not isBeta then
        if not betaUpdateDownloaded then
            local beta_version_content = http.Get(BETA_SCIPT_FILE_ADDR);
            local old_script = file.Open(SCRIPT_FILE_NAME, "w");
            old_script:Write(beta_version_content);
            old_script:Close();
            betaUpdateDownloaded = true;
            RAGESU_UPDATER_TEXT:SetText("Downloaded the Beta Client! Please reload the script.")
        end
    end
end

local RAGESU_UPDATER_BETABUTTON = gui.Button(RAGESU_UPDATER_GROUP, "Download Beta Client", betaUpdate)
local RAGESU_CHANGELOG_CONTENT = http.Get("https://raw.githubusercontent.com/superyor/RageSU/master/changelog.txt")
if RAGESU_CHANGELOG_CONTENT ~= nil or RAGESU_CHANGELOG_CONTENT ~= "" then
    local RAGESU_CHANGELOG_TEXT = gui.Text(RAGESU_UPDATER_GROUP, RAGESU_CHANGELOG_CONTENT)
end

--- News GUI Stuff
local RAGESU_NEWS_TAB = gui.Tab(gui.Reference("Settings"), "ragesu.news.tab", "RageSu™ News")
local RAGESU_NEWS_GROUP = gui.Groupbox(RAGESU_NEWS_TAB, "Latest News for RageSu™ | v" .. VERSION_NUMBER, 15, 15, 600, 600)
local RAGESU_NEWS_CONTENT = http.Get("https://raw.githubusercontent.com/superyor/RageSU/master/news.txt")
if RAGESU_NEWS_CONTENT ~= nil or RAGESU_NEWS_CONTENT ~= "" then
    local RAGESU_NEWS_TEXT = gui.Text(RAGESU_NEWS_GROUP, RAGESU_NEWS_CONTENT)
end

--- RageSu Tab
local RAGESU_TAB = gui.Tab(gui.Reference("Ragebot"), "ragesu.tab", "RageSu™")
local RAGESU_MAIN_GROUP = gui.Groupbox(RAGESU_TAB, "Main", 15, 15, 295, 300)
local RAGESU_MANUALAA_GROUP = gui.Groupbox(RAGESU_TAB, "Manual Anti-Aim (Coming soon)", 15, 275+15, 295, 300)
local RAGESU_DESYNC_GROUP = gui.Groupbox(RAGESU_TAB, "Desync", 300+25, 15, 300, 300);

--- Main
local RAGESU_DOUBLETAP = gui.Checkbox(RAGESU_MAIN_GROUP, "rbot.ragesu.misc.doubletap", "Autochoose doubletap", 0)
local RAGESU_CHOKESHOT = gui.Slider(RAGESU_MAIN_GROUP, "rbot.ragesu.misc.chokeshot", "Choke shot Ticks", 0, 0, 14)
local RAGESU_JUMPSCOUT = gui.Checkbox(RAGESU_MAIN_GROUP, "rbot.ragesu.misc.jumpscout", "Fix Jumpscout", 0)
local RAGESU_CREDITS = gui.Text(RAGESU_MAIN_GROUP, "Made with love by superyu'#7167.                           Thanks to everyone that supports me!")

--- Manual AA
local RAGESU_MANUALAA_LEFT_KEY = gui.Keybox(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.left.key", "Left Key", 0)
local RAGESU_MANUALAA_LEFT_DELTA = gui.Slider(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.left.delta", "Left Delta", -45, -90, 0)
local RAGESU_MANUALAA_RIGHT_KEY = gui.Keybox(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.right.key", "Right Key", 0)
local RAGESU_MANUALAA_RIGHT_DELTA = gui.Slider(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.right.delta", "Right Delta", 45, 0, 90)

--- Desync
local RAGESU_ROTATION_SWAY = gui.Checkbox(RAGESU_DESYNC_GROUP, "rbot.ragesu.rotation.sway", "Rotation Sway", false)
local RAGESU_ROTATION_SWAY_RANGEMAX = gui.Slider(RAGESU_DESYNC_GROUP, "rbot.ragesu.rotation.sway.rangemax", "Rotation Sway Maximum Range", 58, 0, 58, 0.5)
local RAGESU_ROTATION_SWAY_RANGEMIN = gui.Slider(RAGESU_DESYNC_GROUP, "rbot.ragesu.rotation.sway.rangemin", "Rotation Sway Minimum Range", 58, 0, 56.5, 0.5)
local RAGESU_ROTATION_SWAY_SPEED = gui.Slider(RAGESU_DESYNC_GROUP, "rbot.ragesu.rotation.sway.speed", "Rotation Sway Speed", 1, 0.5, 1.5, 0.05)
local RAGESU_LBY_MODE = gui.Combobox(RAGESU_DESYNC_GROUP, "rbot.ragesu.lby.mode", "LBY", "Off", "None", "Opposite", "Sway")
local RAGESU_DESYNC_INVERT_ON_MULTI = gui.Multibox(RAGESU_DESYNC_GROUP, "Invert on")
local RAGESU_DESYNC_INVERT_ON_SHOT = gui.Checkbox(RAGESU_DESYNC_INVERT_ON_MULTI, "rbot.ragesu.inverton.shot", "Enemy's shot", false)
local RAGESU_DESYNC_INVERTER_KEY = gui.Keybox(RAGESU_DESYNC_GROUP, "rbot.ragesu.inverter.key", "Inverter Key", 0)

--- Descriptions
RAGESU_DOUBLETAP:SetDescription("Chooses Doubletap mode based on Velocity.")
RAGESU_CHOKESHOT:SetDescription("Chokes the shooting packet.")
RAGESU_JUMPSCOUT:SetDescription("Disables autostrafer while standing.")
RAGESU_ROTATION_SWAY:SetDescription("Enables Rotation Sway.")
RAGESU_ROTATION_SWAY_RANGEMAX:SetDescription("Maximum Range of the rotation sway.")
RAGESU_ROTATION_SWAY_RANGEMIN:SetDescription("Minimum Range of the rotation sway.")
RAGESU_ROTATION_SWAY_SPEED:SetDescription("Speed of the rotation sway in angles per tick.")
RAGESU_DESYNC_INVERT_ON_MULTI:SetDescription("Inverts desync on selected events.")
RAGESU_LBY_MODE:SetDescription("The kind of LBY you want to have.")
RAGESU_DESYNC_INVERTER_KEY:SetDescription("Inverts desync rotation on key.")

--- RageSu Variables
local pLocal;
local desyncInvert = false;
local swayLasttime = 0;
local swaySwitch = false;
local velocity = nil;
local chokeShotTicks = 0;
local currentVal = 0;
local positiveDir = true;

local ManualLeft = false;
local ManualRight = false;

--- API Localization for better performance
SetVal = gui.SetValue
GetVal = gui.GetValue

local function handleDesync()

    local lby = nil;
    local rotationVal = nil;

    if RAGESU_ROTATION_SWAY:GetValue() then
        RAGESU_LBY_MODE:SetValue(2)
        local min = 0;
        local max = 0;
        local swapSafety = 0;
        if RAGESU_ROTATION_SWAY_RANGEMIN:GetValue() < RAGESU_ROTATION_SWAY_RANGEMAX:GetValue() then
            min = RAGESU_ROTATION_SWAY_RANGEMIN:GetValue()
            max = RAGESU_ROTATION_SWAY_RANGEMAX:GetValue()
        else
            min = RAGESU_ROTATION_SWAY_RANGEMAX:GetValue()
            max = RAGESU_ROTATION_SWAY_RANGEMIN:GetValue()
        end

        if min > -1.51 and min < 1.51 then
            swapSafety = 1.51;
        end

        if not desyncInvert then
            if currentVal <= max*-1 then positiveDir = true end
            if currentVal >= (min*-1)-swapSafety then positiveDir = false end
            if positiveDir then currentVal = currentVal + RAGESU_ROTATION_SWAY_SPEED:GetValue() else currentVal = currentVal - RAGESU_ROTATION_SWAY_SPEED:GetValue() end
        else
            if currentVal <= min+swapSafety then positiveDir = true end
            if currentVal >= max then positiveDir = false end
            if positiveDir then currentVal = currentVal + RAGESU_ROTATION_SWAY_SPEED:GetValue() else currentVal = currentVal - RAGESU_ROTATION_SWAY_SPEED:GetValue() end
        end
        rotationVal = currentVal

        SetVal("rbot.antiaim.base.rotation", rotationVal)
        SetVal("rbot.antiaim.left.rotation", -rotationVal)
        SetVal("rbot.antiaim.right.rotation", rotationVal)
    else
        if desyncInvert then
            SetVal("rbot.antiaim.base.rotation", 58)
            SetVal("rbot.antiaim.left.rotation", -58)
            SetVal("rbot.antiaim.right.rotation", 58)
        else
            SetVal("rbot.antiaim.base.rotation", -58)
            SetVal("rbot.antiaim.left.rotation", 58)
            SetVal("rbot.antiaim.right.rotation", -58)
        end
        rotationVal = gui.GetValue("rbot.antiaim.base.rotation")
    end

    if RAGESU_LBY_MODE:GetValue() == 1 then
        lby = 0
    elseif RAGESU_LBY_MODE:GetValue() == 2 then
        if rotationVal > 0 then
            lby = 58
        else
            lby = -58
        end
    elseif RAGESU_LBY_MODE:GetValue() == 3 then
        if globals.RealTime() > swayLasttime + 1.1 then
            swaySwitch = not swaySwitch;
            swayLasttime = globals.RealTime()
        end

        if swaySwitch then
            lby = 120;
        else
            lby = -120;
        end
    end

    if lby ~= nil then
        SetVal("rbot.antiaim.base.lby", lby*-1)
        SetVal("rbot.antiaim.left.lby", lby)
        SetVal("rbot.antiaim.right.lby", lby*-1)
    end
end

local function handleVelocity()

    if velocity ~= nil then
        if RAGESU_JUMPSCOUT:GetValue() then
            if velocity > 5 then
                SetVal("misc.strafe.enable", 1)
            else
                SetVal("misc.strafe.enable", 0)
            end
        end
    
        if RAGESU_DOUBLETAP:GetValue() then
            if velocity > 100 then
                SetVal("rbot.accuracy.weapon.asniper.doublefire", 2)
            else
                SetVal("rbot.accuracy.weapon.asniper.doublefire", 1)
            end
        end
    end
end

local function handleKeypresses()

    if RAGESU_DESYNC_INVERTER_KEY:GetValue() ~= 0 then
        if input.IsButtonPressed(RAGESU_DESYNC_INVERTER_KEY:GetValue()) then
            desyncInvert = not desyncInvert;
        end
    end

    if RAGESU_MANUALAA_LEFT_KEY:GetValue() ~= 0 then
        if input.IsButtonPressed(RAGESU_MANUALAA_LEFT_KEY:GetValue()) then
            ManualLeft = not ManualLeft;
        end
    end
    
    if RAGESU_MANUALAA_RIGHT_KEY:GetValue() ~= 0 then
        if input.IsButtonPressed(RAGESU_MANUALAA_RIGHT_KEY:GetValue()) then
            ManualRight = not ManualRight;
        end
    end
end

local function handleManualAA()

end

--- Hooks
local function createMoveHook(cmd)

    if pLocal and velocity ~= nil then

        if velocity ~= 0 then
            swayLasttime = 0
            if gui.GetValue("rbot.antiaim.base.rotation") > 0 then
                swaySwitch = false;
            else
                swaySwitch = true;
            end
        end
    
        if RAGESU_CHOKESHOT:GetValue() > 0 then
            if bit.band(cmd.buttons, bit.lshift(1, 0)) == 1 then
                cmd.sendpacket = false;
                chokeShotTicks = chokeShotTicks + 1
            elseif chokeShotTicks > 0 then
                if chokeShotTicks <= RAGESU_CHOKESHOT:GetValue() then
                    cmd.sendpacket = false;
                    chokeShotTicks = chokeShotTicks + 1;
                else
                    cmd.sendpacket = true;
                    chokeShotTicks = 0;
                end
            end
        end
        handleDesync()
    end
end

local function drawHook()
    pLocal = entities.GetLocalPlayer()

    if pLocal then
        velocity = math.sqrt(pLocal:GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + pLocal:GetPropFloat( "localdata", "m_vecVelocity[1]" )^2)
    end

    handleKeypresses()
    handleVelocity()
    handleManualAA()
end

local function eventHook(event)
    if event:GetName("weapon_fire") then
        if entities.GetByUserID(event:GetInt("userid")):GetTeamNumber() ~= entities.GetLocalPlayer():GetTeamNumber() then
            shouldInvert = not shouldInvert;

            if RAGESU_DESYNC_INVERT_ON_SHOT:GetValue() then
                desyncInvert = not desyncInvert;
            end
        end
    end
end

--- Callbacks
callbacks.Register("CreateMove", createMoveHook)
callbacks.Register("Draw", drawHook);
callbacks.Register("FireGameEvent", eventHook)

--- Auto updater by ShadyRetard/Shady#0001
local function handleUpdates()

    if (update_available and not update_downloaded) then
        RAGESU_UPDATER_TEXT:SetText("Update is getting downloaded.")
        local new_version_content = http.Get(SCRIPT_FILE_ADDR);
        local old_script = file.Open(SCRIPT_FILE_NAME, "w");
        old_script:Write(new_version_content);
        old_script:Close();
        update_available = false;
        update_downloaded = true;
    end

    if (update_downloaded) then
        RAGESU_UPDATER_TEXT:SetText("Update available, please reload the script.")
        return;
    end

    if (not version_check_done) then
        version_check_done = true;
        local version = http.Get(VERSION_FILE_ADDR);
        if (version ~= VERSION_NUMBER) then
            update_available = true;
        end
        if not betaUpdateDownloaded then
            if isBeta then
                RAGESU_UPDATER_TEXT:SetText("You are using the newest Beta client. Current Version: v" .. VERSION_NUMBER .. " Beta Build")
            else
                RAGESU_UPDATER_TEXT:SetText("Your client is up to date. Current Version: v" .. VERSION_NUMBER .. " Stable Build")
            end
        end
    end
end

callbacks.Register("Draw", handleUpdates)