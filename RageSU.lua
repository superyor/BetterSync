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
local VERSION_NUMBER = "4.0.1"; --- This too
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
local RAGESU_DESYNC_GROUP = gui.Groupbox(RAGESU_TAB, "Desync", 300+25, 15, 300, 300);
local RAGESU_MANUALAA_GROUP = gui.Groupbox(RAGESU_TAB, "Manual Anti-Aim (Coming soon)", 300+25, 190+25, 300, 300)

--- Main
local RAGESU_DOUBLETAP = gui.Checkbox(RAGESU_MAIN_GROUP, "rbot.ragesu.misc.doubletap", "Autochoose doubletap", 0)
local RAGESU_CHOKESHOT = gui.Checkbox(RAGESU_MAIN_GROUP, "rbot.ragesu.misc.chokeshot", "Choke shot", 0)
local RAGESU_JUMPSCOUT = gui.Checkbox(RAGESU_MAIN_GROUP, "rbot.ragesu.misc.jumpscout", "Fix Jumpscout", 0)
local RAGESU_CREDITS = gui.Text(RAGESU_MAIN_GROUP, "Made with love by superyu'#7167.                           Thanks to everyone that supports me!")

--- Manual AA
local RAGESU_MANUALAA_LEFT_KEY = gui.Keybox(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.left.key", "Left Key", 0)
local RAGESU_MANUALAA_LEFT_DELTA = gui.Slider(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.left.delta", "Left Delta", -45, -90, 0)
local RAGESU_MANUALAA_RIGHT_KEY = gui.Keybox(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.right.key", "Right Key", 0)
local RAGESU_MANUALAA_RIGHT_DELTA = gui.Slider(RAGESU_MANUALAA_GROUP, "rbot.ragesu.manualaa.right.delta", "Right Delta", 45, 0, 90)

--- Desync
local RAGESU_LBY_MODE = gui.Combobox(RAGESU_DESYNC_GROUP, "rbot.ragesu.lby.mode", "LBY", "None", "Opposite", "Sway")
local RAGESU_DESYNC_INVERTER_KEY = gui.Keybox(RAGESU_DESYNC_GROUP, "rbot.ragesu.inverter.key", "Inverter Key", 0)

--- Descriptions
RAGESU_DOUBLETAP:SetDescription("Chooses Doubletap mode based on Velocity.")
RAGESU_CHOKESHOT:SetDescription("Chokes the shooting packet.")
RAGESU_JUMPSCOUT:SetDescription("Disables autostrafer while standing.")
RAGESU_LBY_MODE:SetDescription("The kind of LBY you want to have.")
RAGESU_DESYNC_INVERTER_KEY:SetDescription("Inverts desync rotation.")


--- RageSu Variables
local pLocal;
local lastTick = 0;
local desyncInvert = false;
local swayLasttime = 0;
local swaySwitch = false;

local ManualLeft = false;
local ManualRight = false;

local function handleDesync()

    local lby = nil;
    local rotationVal = gui.GetValue("rbot.antiaim.base.rotation")

    if desyncInvert then
        gui.SetValue("rbot.antiaim.base.rotation", 58)
        gui.SetValue("rbot.antiaim.left.rotation", -58)
        gui.SetValue("rbot.antiaim.right.rotation", 58)
    else
        gui.SetValue("rbot.antiaim.base.rotation", -58)
        gui.SetValue("rbot.antiaim.left.rotation", 58)
        gui.SetValue("rbot.antiaim.right.rotation", -58)
    end

    if RAGESU_LBY_MODE:GetValue() == 0 then
        lby = 0
    elseif RAGESU_LBY_MODE:GetValue() == 1 then
        if rotationVal > 0 then
            lby = -58
        else
            lby = 58
        end
    else
        if globals.RealTime() > swayLasttime + 1.125 then
            swaySwitch = not swaySwitch;
            swayLasttime = globals.RealTime()
        end

        if swaySwitch then
            lby = 58;
        else
            lby = -58;
        end
    end

    if lby ~= nil then
        gui.SetValue("rbot.antiaim.base.lby", lby*-1)
        gui.SetValue("rbot.antiaim.left.lby", lby)
        gui.SetValue("rbot.antiaim.right.lby", lby*-1)
    end
end

local function handleVelocity()

    if not pLocal then
        return
    end

    local vel = math.sqrt(pLocal:GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + pLocal:GetPropFloat( "localdata", "m_vecVelocity[1]" )^2)

    if RAGESU_JUMPSCOUT:GetValue() then
        if vel > 5 then
            gui.SetValue("misc.strafe.enable", 1)
        else
            gui.SetValue("misc.strafe.enable", 0)
        end
    end

    if RAGESU_DOUBLETAP:GetValue() then
        if vel > 100 then
            gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", 2)
        else
            gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", 1)
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

    if not pLocal then
        return
    end

    local vel = math.sqrt(pLocal:GetPropFloat( "localdata", "m_vecVelocity[0]" )^2 + pLocal:GetPropFloat( "localdata", "m_vecVelocity[1]" )^2)

    if vel ~= 0 then 
        swayLasttime = globals.RealTime() + 0.22
        swaySwitch = false;
    end

    if RAGESU_CHOKESHOT:GetValue() and bit.band(cmd.buttons, bit.lshift(1, 0)) == 1 then
        cmd.sendpacket = false;
    end
end

local function drawHook()

    handleKeypresses()

    pLocal = entities.GetLocalPlayer()
    handleVelocity()
    handleManualAA()


    if engine.GetMapName() == "" then
        lastTick = 0;
    end

    if globals.TickCount() > lastTick then
        handleDesync()
    end
end

--- Callbacks
callbacks.Register("CreateMove", createMoveHook)
callbacks.Register("Draw", drawHook);

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