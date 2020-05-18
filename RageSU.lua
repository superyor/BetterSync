local ragesu = http.Get("https://raw.githubusercontent.com/superyor/RageSU/master/RageSU%20Downloader.lua");
local f = file.Open("Data\\Superyu\\RageSU\\Temp\\scriptloader.lua", "w");
f:Write(ragesu);
f:Close();
LoadScript("Data\\Superyu\\RageSU\\Temp\\scriptloader.lua")