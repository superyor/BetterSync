---@diagnostic disable: undefined-global

local GlobalsCurTime = globals.CurTime;
local GuiSetValue = gui.SetValue;
local GuiGetValue = gui.GetValue;

local CurrentDirectory = function()
    local str = GetScriptName();
    str = str:match("^.*/(.*)") or str;
    return GetScriptName():sub(0, string.len(GetScriptName())  - string.len(str));
end

local Metadata = {
    Name = 'RageSU';
    Version = 'beta1';
    CurrentDirectory = CurrentDirectory();
}

local Helpers = {
    LoadLibraries = function(self)
        file.Enumerate(function(filename)
            local oFilename = filename;
            filename = filename:gsub('%-', '_');

            if (filename:find(Metadata.CurrentDirectory:gsub('%-', '_') .. 'lib')) then
                local content = file.Read(oFilename);
                filename = filename:match("[^/]*.dat$");
                filename = filename:sub(0, #filename - 4);
                self[filename] = loadstring(content)();
            end
        end)
    end;

    Framework = {
        Ref = nil;
        VarPrefix = nil;
        Selector = nil;
        TabObjects = {};
        Tabs = {};

        Init = function(self, location, varprefix, menuname)
            self.Ref = gui.Tab(location, varprefix .. '.tab', menuname);
            self.VarPrefix = varprefix;
            self.Selector = gui.Combobox(self.Ref, self.VarPrefix .. '.selector', 'Tab Selector', 'Bruh');
        end;

        AddTab = function(self, name)
            self.TabObjects[name] = gui.Groupbox(self.Ref, name, 16, 64+8, 608, 600);
            self.Tabs[#self.Tabs+1] = name;
            self.Selector:SetOptions(unpack(self.Tabs));
            return self.TabObjects[name];
        end;

        OnDraw = function(self)
            if (not self.Tabs[1]) then
                return;
            end

            local CurrentTab = self.Selector:GetValue();
            CurrentTab = self.Tabs[CurrentTab+1];
            for k, v in pairs(self.TabObjects) do
                if (CurrentTab == k) then
                    v:SetInvisible(false);
                else
                    v:SetInvisible(true);
                end
            end
        end
    }
}

local UI = {

    Objects = {};

    Init = function(self)
        local lang = Helpers.json.decode(file.Read(Metadata.CurrentDirectory .. 'assets/tr/english.dat'));

        Helpers.Framework:Init(gui.Reference('Ragebot'), 'rbot.ragesu', Metadata.Name .. ' - ' .. Metadata.Version);

        local Rage = Helpers.Framework:AddTab(lang.rage.name, 'rage');

        local Misc = Helpers.Framework:AddTab(lang.misc.name, 'misc');
        self.Objects.ScoutFix = gui.Checkbox(Misc, 'rbot.ragesu.misc.scoutfix', lang.misc.scoutfix.name, false);
        self.Objects.HitchanceFix = gui.Checkbox(Misc, 'rbot.ragesu.misc.hitchancefix', lang.misc.hitchancefix.name, false);

        self.Objects.ChokeshotTicks = gui.Slider(Misc, 'rbot.ragesu.misc.chokeshot.ticks', lang.misc.chokeshotTicks.name, 0, 0, 16);
        self.Objects.ChokeshotAfter = gui.Checkbox(Misc, 'rbot.ragesu.misc.chokeshot.after', lang.misc.chokeshotAfter.name, false);

        local LicensePage = Helpers.Framework:AddTab(lang.licensepage.name, 'licensepage');
        local LicenseText = gui.Text(LicensePage, file.Read(Metadata.CurrentDirectory .. 'assets/LICENSE.txt'));

        for k, v in pairs(lang) do
            for k2, v2 in pairs (v) do
                for k3, v3 in pairs(self.Objects) do
                    if (type(v2) == 'table') then
                        if (v3:GetName() == v2.name) then
                            v3:SetDescription(v2.desc);
                        end
                    end
                end
            end
        end
    end;
}

local Features = {
    Vars = {
        scoutfix = {
            scout1 = true;
            scout2 = true;
            scouthc = GuiGetValue("rbot.accuracy.weapon.scout.hitchance");
        };

        chokeshot = {
            shotLastTick = false;
            shooting = false;
            chokedTicks = 0;
        };

    };

    GetVar = function(self, featurekey, varkey)
        return self.Vars[featurekey][varkey];
    end;

    SetVar = function(self, featurekey, varkey, value)
        self.Vars[featurekey][varkey] = value;
    end;

    JumpscoutFix = {
        CreateMove = function(self, pLocal)

            local scoutfix = UI.Objects.ScoutFix:GetValue();
            local hitchancefix = UI.Objects.HitchanceFix:GetValue();

            local velX = pLocal:GetPropFloat( "localdata", "m_vecVelocity[0]" );
            local velY = pLocal:GetPropFloat( "localdata", "m_vecVelocity[1]" );
            local vel = math.sqrt((velX*velX) + (velY*velY));

            if (vel < 10) then
                if (scoutfix) then
                    GuiSetValue("misc.strafe.enable", 0);
                    GuiSetValue("misc.strafe.air", 0);
                end
            else
                GuiSetValue("misc.strafe.enable", 1);
                GuiSetValue("misc.strafe.air", 1);
            end

            if (hitchancefix) then
                local onground = bit.band(pLocal:GetPropInt("m_fFlags"), 1);

                if (onground == 1) then
                    if (self:GetVar("scoutfix", "scout2")) then
                        GuiSetValue("rbot.accuracy.weapon.scout.hitchance", self:GetVar("scoutfix", "scouthc"));
                        self:SetVar("scoutfix", "scout1", true);
                        self:SetVar("scoutfix", "scout2", false);
                    end
                else
                    if (pLocal:GetWeaponInaccuracy() < 0.011) then
                        if (self:GetVar("scoutfix", "scout1")) then
                            self:SetVar("scoutfix", "scouthc", GuiGetValue("rbot.accuracy.weapon.scout.hitchance"));
                            GuiSetValue("rbot.accuracy.weapon.scout.hitchance", 1);
                            self:SetVar("scoutfix", "scout1", false);
                            self:SetVar("scoutfix", "scout2", true);
                        end
                    end
                end
            end
        end
    };

    Chokeshot = {
        CreateMove = function(self, pLocal, cmd)

            local aftershot = UI.Objects.ChokeshotAfter:GetValue();
            local ticks = UI.Objects.ChokeshotTicks:GetValue();

            if (ticks == 0) then
                return;
            end

            if (pLocal ~= nil) then
                local pWeap = pLocal:GetPropEntity("m_hActiveWeapon");

                if (pWeap ~= nil) then
                    local pWeapClass = pWeap:GetClass();
                    local pWeapID = pWeap:GetWeaponID();
                    local isAllowed = true;

                    if (pWeapID > 42 and pWeapID < 60) then
                        isAllowed = false;
                    end

                    if (pWeapID > 64 and pWeapID < 86) then
                        isAllowed = false;
                    end

                    if (pWeapID ~= 64 and pWeapClass ~= "CKnife" and isAllowed) then
                        if (self:GetVar("chokeshot", "shotLastTick")) then
                            self:SetVar("chokeshot", "shotLastTick", false);
                            self:SetVar("chokeshot", "shooting", true);
                        end

                        if (bit.band(cmd.buttons, bit.lshift(1, 0)) == 1) then
                            if (self:GetVar("chokeshot", "shooting")) then
                                cmd.sendpacket = true;
                                self:SetVar("chokeshot", "chokedTicks", 0);
                                self:SetVar("chokeshot", "shooting", false);

                                if (aftershot) then
                                    self:SetVar("chokeshot", "shotLastTick", true);
                                end
                            else
                                if (aftershot) then
                                    self:SetVar("chokeshot", "shotLastTick", true);
                                else
                                    self:SetVar("chokeshot", "shooting", true);
                                end
                            end
                        end

                        if (self:GetVar("chokeshot", "shooting")) then
                            if (self:GetVar("chokeshot", "chokedTicks") <= ticks) then
                                cmd.sendpacket = false;
                                self:SetVar("chokeshot", "chokedTicks", self:GetVar("chokeshot", "chokedTicks") + 1);
                            else
                                cmd.sendpacket = true;
                                self:SetVar("chokeshot", "chokedTicks", 0);
                                self:SetVar("chokeshot", "shooting", false);
                            end
                        end
                    end
                end
            end
        end
    };
};

Helpers:LoadLibraries();
UI:Init();

callbacks.Register('Draw', function()
    Helpers.Framework:OnDraw();
end)

callbacks.Register('CreateMove', function(cmd)
    local pLocal = entities.GetLocalPlayer();
    Features.JumpscoutFix.CreateMove(Features, pLocal);
    Features.Chokeshot.CreateMove(Features, pLocal, cmd);
end)