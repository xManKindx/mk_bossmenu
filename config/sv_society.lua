exports('getSocietyBalance', getBalance)
---@param name string Job or Gang name
---@param checkType string 'job' or 'gang'
---@return number balance or 0
function getBalance(name, checkType)
    local balance = 0
    local query, params

    if Framework == 'QBCORE' then 
        query = "SELECT amount FROM management_funds WHERE `job_name` = ? AND `type` = ?"
        params = {name, (checkType == 'job' and 'boss' or 'gang')}
    elseif Framework == 'ESX' then 
        query = "SELECT money FROM addon_account_data WHERE account_name = ?"
        params = {'society_'..name}
    end

    local result = MySQL.query.await(query, params)
    if result and result[1] then 
        if result[1].amount then
            return tonumber(result[1].amount)
        elseif result[1].money then 
            return tonumber(result[1].money)
        else
            return 0
        end
    else
        return 0
    end
end

exports('updateSocietyBalance', updateBalance)
---@param deposit boolean <deposit = true> <withdraw = false>
---@param name string Job or Gang name
---@param checkType string 'job' or 'gang'
---@param amount number Amount to deposit/withdraw
---@return number or false
function updateBalance(deposit, name, checkType, amount)
    local balance, newBalance = getBalance(name, checkType), 0
    amount = tonumber(amount)

    if deposit then 
        newBalance = math.ceil(balance + amount)
        if newBalance <= balance then return false end
    else
        newBalance = math.ceil(balance - amount)
        if newBalance >= balance then return false end
        if newBalance < 0 then return false end
    end

    local query, params

    if Framework == 'QBCORE' then 
        query = "UPDATE management_funds SET amount = ? WHERE `job_name` = ? AND `type` = ?"
        params = {newBalance, name, (checkType == 'job' and 'boss' or 'gang')}
    elseif Framework == 'ESX' then 
        query = "UPDATE addon_account_data SET money = ? WHERE account_name = ?"
        params = {newBalance, 'society_'..name}
    end

    local result = MySQL.update.await(query, params)
    if result then
        return newBalance
    else
        return false
    end
end

---@param playerSource number player server id
---@param amount number amount of cash to remove from player
---@return boolean
function removeMoney(playerSource, amount)
    local src = playerSource
    amount = tonumber(amount)
    local player

    if Framework == 'QBCORE' then 
        player = QBCore.Functions.GetPlayer(src)
        if player then 
            if player.Functions.RemoveMoney('cash', amount, 'Society Deposit') then 
                return true
            else
                MK_CORE.Notify(src, {Message = locale('not_enough_money'), Type = 'error', Duration = 5000})
                return false
            end
        else
            MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000})
            return false
        end
    elseif Framework == 'ESX' then 
        player = ESX.GetPlayerFromId(src)
        if player then 
            if tonumber(player.getAccount('money').money) >= amount then 
                player.removeAccountMoney('money', amount)
                return true
            else
                MK_CORE.Notify(src, {Message = locale('not_enough_money'), Type = 'error', Duration = 5000})
                return false
            end
        else
            MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000})
            return false
        end
    end
end

---@param playerSource number player server id
---@param amount number amount of cash to add to player
---@return boolean
function addMoney(playerSource, amount)
    local src = playerSource
    local player
    amount = tonumber(amount)

    if Framework == 'QBCORE' then 
        player = QBCore.Functions.GetPlayer(src)
        if player then 
            player.Functions.AddMoney('cash', amount, 'Society Withdrawl')
            return true
        else
            MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000})
            return false
        end
    elseif Framework == 'ESX' then 
        player = ESX.GetPlayerFromId(src)
        if player then 
            player.addAccountMoney('money', amount)
            return true
        else
            MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000})
            return false
        end
    end
end

---@param name string Job or Gang name
---@param checkType string 'job' or 'gang'
---@return number
lib.callback.register('MK_BossMenu:Server:GetSocietyBalance', function(source, name, checkType)
    local src = source

    return getBalance(name, checkType)
end)

---@param updateType string 'deposit' or 'withdraw'
---@param name string Job or Gang name
---@param checkType string 'job' or 'gang'
---@param amount number amount to add/remove from player and society
---@return number or false
lib.callback.register('MK_BossMenu:Server:UpdateSociety', function(source, updateType, name, checkType, amount)
    local src = source

    local balance, newBalance = getBalance(name, checkType), 0
    amount = tonumber(amount)

    if updateType == 'deposit' then 
        newBalance = math.ceil(balance + amount)
        if newBalance <= balance then MK_CORE.Notify(src, {Message = locale('enter_amount'), Type = 'error', Duration = 5000}) return false end --deposit invalid amount
        if not removeMoney(src, amount) then return false end --not enough money
    elseif updateType == 'withdraw' then 
        newBalance = math.ceil(balance - amount)
        if newBalance >= balance then MK_CORE.Notify(src, {Message = locale('enter_amount'), Type = 'error', Duration = 5000}) return false end --withdraw invalid amount
        if newBalance < 0 then MK_CORE.Notify(src, {Message = locale('enter_amount'), Type = 'error', Duration = 5000}) return false end --attempt to withdraw more than the balance
        if not addMoney(src, amount) then return false end --add money fail
    else
        return false
    end

    local query, params

    if Framework == 'QBCORE' then 
        query = "UPDATE management_funds SET amount = ? WHERE `job_name` = ? AND `type` = ?"
        params = {newBalance, name, (checkType == 'job' and 'boss' or 'gang')}
    elseif Framework == 'ESX' then 
        query = "UPDATE addon_account_data SET money = ? WHERE account_name = ?"
        params = {newBalance, 'society_'..name}
    end

    local result = MySQL.update.await(query, params)
    if result then
        MK_CORE.Notify(src, {Message = (updateType == 'deposit' and locale('deposit_success', Utils:FormatThousand(amount)) or locale('withdraw_success', Utils:FormatThousand(amount))), Type = 'primary', Duration = 8000 })
        return newBalance
    else
        return false
    end
end)
