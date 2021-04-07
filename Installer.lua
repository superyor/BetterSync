local Paths = {
    'src/RageSU.lua',
    'src/assets/lib/json.dat',
    'src/assets/tr/english.dat',
    'src/assets/tr/shakespearean.dat',
}

local function Download(path)
    http.Get('https://raw.githubusercontent.com/superyu1337/RageSU/master/' .. path, function(data)
        file.Write('RageSU/' .. path:gsub('src/', ''), data);
    end)
end

for k, v in pairs(Paths) do
    Download(v);
end