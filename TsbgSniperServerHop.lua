--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local currentTime = os.date("!*t")
local actualHalfHour = currentTime.hour * 2 + math.floor(currentTime.min / 30)
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHalfHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end

function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100&cursor=' .. foundAnything))
    end

    if Site.nextPageCursor and Site.nextPageCursor ~= "null" then
        foundAnything = Site.nextPageCursor
    end

    for i, v in pairs(Site.data) do
        -- Only proceed if the server is not full.
        if tonumber(v.playing) < tonumber(v.maxPlayers) then
            local serverID = tostring(v.id)
            local canJoin = true

            -- Check if the server has already been attempted.
            for _, Existing in pairs(AllIDs) do
                if serverID == tostring(Existing) then
                    canJoin = false
                    break
                end
            end

            if canJoin then
                table.insert(AllIDs, serverID)
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, serverID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while task.wait(0.5) do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

Teleport()
