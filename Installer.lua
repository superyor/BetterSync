local Paths = {
    'src/RageSU.lua',
    'src/lib/json.dat',
    'src/tr/english.dat',
    'src/tr/shakespearean.dat',
}

local function Download(path)
    http.Get('https://raw.githubusercontent.com/superyu1337/RageSU/master/' .. path, function(data)
        file.Write('RageSU/' .. path:gsub('src/', ''), data);
    end)
end

for k, v in pairs(Paths) do
    Download(v);
end