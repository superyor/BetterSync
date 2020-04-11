local ragesu = http.Get("https://raw.githubusercontent.com/superyor/RageSU/master/RageSU.lua");
local oScriptName = GetScriptName()
local f = file.Open(oScriptName, "w");
f:Write(ragesu);
f:Close();
LoadScript(oScriptName)