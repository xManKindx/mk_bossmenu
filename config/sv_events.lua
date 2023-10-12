--Do not edit anything here unless you know what you're doing

RegisterNetEvent('MK_BossMenu:Server:SetJob', function(setType, jobName, playerIdentifier, playerFullName, jobGrade)
    ---@param setType string (Hire, Fire, Promote)
    ---@param jobName string Job name
    ---@param playerIdentifier <string/number> Player identifier or server id
    ---@param playerFullName <string/boolean> Player first and last name or false
    ---@param jobGrade <string/number> New grade to set player job to

    local src = source 
    local targetPlayer, targetSource, player
    local fullName = playerFullName
    local query, param
    local oldJob

    if Framework == 'QBCORE' then 
        player = QBCore.Functions.GetPlayer(src)
        if setType == 'Hire' then 
            targetPlayer = QBCore.Functions.GetPlayer(tonumber(playerIdentifier))
        else
            targetPlayer = QBCore.Functions.GetPlayerByCitizenId(playerIdentifier)
        end
        query = 'SELECT job FROM players WHERE citizenid = ?'
        param = {playerIdentifier}
    elseif Framework == 'ESX' then 
        player = ESX.GetPlayerFromId(src)
        if setType == 'Hire' then 
            targetPlayer = ESX.GetPlayerFromId(playerIdentifier)
        else
            targetPlayer = ESX.GetPlayerFromIdentifier(playerIdentifier)
        end
        query = 'SELECT job, job_grade FROM users WHERE identifier = ?'
        param = {playerIdentifier}
    end

    if setType == 'Hire' then 
        if not player or not targetPlayer then MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000}) return end

        if Framework == 'QBCORE' then 
            fullName = targetPlayer.PlayerData.charinfo.firstname..' '..targetPlayer.PlayerData.charinfo.lastname
            targetSource = targetPlayer.PlayerData.source
            param = {targetPlayer.PlayerData.citizenid} --set CID here because Hire playerIdentifier = server id
        elseif Framework == 'ESX' then 
            fullName = targetPlayer.name
            targetSource = targetPlayer.source
            param = {targetPlayer.identifier} --set ident here because Hire playerIdentifier = server id
        end

        if src == targetSource then return end --trying to hire self

        local myCoords = GetEntityCoords(GetPlayerPed(src), false)
        local targetCoords = GetEntityCoords(GetPlayerPed(targetSource), false)
        if myCoords and targetCoords then 
            if #(myCoords - targetCoords) > 10 then MK_CORE.Notify(src, {Message = locale('citizen_too_far'), Type = 'error', Duration = 5000}) return end
        else
            MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000})
            return
        end
    end

    local result = MySQL.query.await(query, param)
    if result and result[1] then 
        if Framework == 'QBCORE' then
            local currentJob = json.decode(result[1].job)
            
            if setType == 'Hire' and currentJob.name == jobName then
                MK_CORE.Notify(src, {Message = locale('already_works_here'), Type = 'error', Duration = 5000})
                return
            end

            oldJob = QBCore.Shared.Jobs[currentJob.name].label

            if setType == 'Promote' then 
                if tonumber(currentJob.grade.level) > jobGrade then 
                    setType = 'Demote'
                end
            end

            local newJob = {}
            newJob.name = jobName
            newJob.type = QBCore.Shared.Jobs[jobName].type or 'none'
            newJob.grade = {
                name = QBCore.Shared.Jobs[jobName].grades[tonumber(jobGrade)] and QBCore.Shared.Jobs[jobName].grades[tonumber(jobGrade)].name or QBCore.Shared.Jobs[jobName].grades[tostring(jobGrade)].name,
                level = tonumber(jobGrade)
            }
            newJob.isboss = QBCore.Shared.Jobs[jobName].grades[tonumber(jobGrade)] and (QBCore.Shared.Jobs[jobName].grades[tonumber(jobGrade)].isboss and true or false) or (QBCore.Shared.Jobs[jobName].grades[tostring(jobGrade)].isboss and true or false)
            newJob.label = QBCore.Shared.Jobs[jobName].label
            newJob.onduty = QBCore.Shared.Jobs[jobName].defaultDuty
            newJob.payment = QBCore.Shared.Jobs[jobName].grades[tonumber(jobGrade)] and QBCore.Shared.Jobs[jobName].grades[tonumber(jobGrade)].payment or QBCore.Shared.Jobs[jobName].grades[tostring(jobGrade)].payment

            local res = MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', {json.encode(newJob), (setType == 'Hire' and targetPlayer.PlayerData.citizenid or playerIdentifier)})

            if targetPlayer then targetPlayer.Functions.SetJob(jobName, jobGrade) end

            if setType == 'Fire' then 
                MK_CORE.Notify(src, {Message = locale('player_fired', fullName), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('player_fired_notify', oldJob), Type = 'error', Duration = 8000}) end
            elseif setType == 'Hire' then 
                MK_CORE.Notify(src, {Message = locale('player_hired', fullName), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('player_hired_notify', newJob.label), Type = 'primary', 8000}) end
            elseif setType == 'Promote' then 
                MK_CORE.Notify(src, {Message = locale('player_promoted', fullName, newJob.grade.name), Type = 'primary', Duration = 5000})
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('player_promoted_notify', newJob.grade.name), Type = 'primary', Duration = 8000}) end
            elseif setType == 'Demote' then
                MK_CORE.Notify(src, {Message = locale('player_demoted', fullName, newJob.grade.name), Type = 'primary', duration = 5000})
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('player_demoted_notify', newJob.grade.name), Type = 'error', Duration = 5000}) end
            end
        elseif Framework == 'ESX' then 
            if setType == 'Hire' and result[1].job == jobName then
                MK_CORE.Notify(src, {Message = locale('already_works_here'), Type = 'error', Duration = 5000})
                return
            end

            oldJob = ESX.Jobs[result[1].job].label

            if setType == 'Promote' then 
                if tonumber(result[1].job_grade) > jobGrade then 
                    setType = 'Demote'
                end
            end

            local res = MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {jobName, tonumber(jobGrade), (setType == 'Hire' and targetPlayer.identifier or playerIdentifier)})

            if targetPlayer then targetPlayer.setJob(jobName, jobGrade) end

            local newJobLabel = (ESX.Jobs[jobName].grades[jobGrade] and ESX.Jobs[jobName].grades[jobGrade].label or ESX.Jobs[jobName].grades[tostring(jobGrade)].label)

            if setType == 'Fire' then 
                MK_CORE.Notify(src, {Message = locale('player_fired', fullName), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('player_fired_notify', oldJob), Type = 'error', Duration = 8000}) end
            elseif setType == 'Hire' then 
                MK_CORE.Notify(src, {Message = locale('player_hired', fullName), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('player_hired_notify', ESX.Jobs[jobName].label), Type = 'primary', 8000}) end
            elseif setType == 'Promote' then 
                MK_CORE.Notify(src, {Message = locale('player_promoted', fullName, newJobLabel), Type = 'primary', Duration = 5000})
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('player_promoted_notify', newJobLabel), Type = 'primary', Duration = 8000}) end
            elseif setType == 'Demote' then
                MK_CORE.Notify(src, {Message = locale('player_demoted', fullName, newJobLabel), Type = 'primary', duration = 5000})
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('player_demoted_notify', newJobLabel), Type = 'error', Duration = 5000}) end
            end
        end
    end
end)

RegisterNetEvent('MK_BossMenu:Server:SetGang', function(setType, gangName, playerIdentifier, playerFullName, gangGrade)
    ---@param setType string (Hire, Fire, Promote)
    ---@param gangName string Gang name
    ---@param playerIdentifier <string/number> Player identifier or server id
    ---@param playerFullName <string/boolean> Player first and last name or false
    ---@param gangGrade <string/number> New grade to set player gang to

    local src = source 
    local targetPlayer, targetSource, player
    local fullName = playerFullName
    local query, param
    local oldGang

    if Framework == 'QBCORE' then 
        player = QBCore.Functions.GetPlayer(src)
        if setType == 'Hire' then 
            targetPlayer = QBCore.Functions.GetPlayer(tonumber(playerIdentifier))
        else
            targetPlayer = QBCore.Functions.GetPlayerByCitizenId(playerIdentifier)
        end
        query = 'SELECT gang FROM players WHERE citizenid = ?'
        param = {playerIdentifier}
    elseif Framework == 'ESX' then 
        player = ESX.GetPlayerFromId(src)
        if setType == 'Hire' then 
            targetPlayer = ESX.GetPlayerFromId(playerIdentifier)
        else
            targetPlayer = ESX.GetPlayerFromIdentifier(playerIdentifier)
        end
        query = 'SELECT gang, gang_grade FROM users WHERE identifier = ?'
        param = {playerIdentifier}
    end

    if setType == 'Hire' then 
        if not player or not targetPlayer then MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000}) return end

        if Framework == 'QBCORE' then 
            fullName = targetPlayer.PlayerData.charinfo.firstname..' '..targetPlayer.PlayerData.charinfo.lastname
            targetSource = targetPlayer.PlayerData.source
            param = {targetPlayer.PlayerData.citizenid} --set CID here because Hire playerIdentifier = server id
        elseif Framework == 'ESX' then 
            fullName = targetPlayer.name
            targetSource = targetPlayer.source
            param = {targetPlayer.identifier} --set ident here because Hire playerIdentifier = server id
        end

        if src == targetSource then return end --trying to hire self

        local myCoords = GetEntityCoords(GetPlayerPed(src), false)
        local targetCoords = GetEntityCoords(GetPlayerPed(targetSource), false)
        if myCoords and targetCoords then 
            if #(myCoords - targetCoords) > 10 then MK_CORE.Notify(src, {Message = locale('citizen_too_far'), Type = 'error', Duration = 5000}) return end
        else
            MK_CORE.Notify(src, {Message = locale('citizen_not_found'), Type = 'error', Duration = 5000})
            return
        end
    end

    local result = MySQL.query.await(query, param)
    if result and result[1] then 
        if Framework == 'QBCORE' then
            local currentGang = json.decode(result[1].gang)
            
            if setType == 'Hire' and currentGang.name == gangName then
                MK_CORE.Notify(src, {Message = locale('already_in_gang'), Type = 'error', Duration = 5000})
                return
            end

            oldGang = QBCore.Shared.Gangs[currentGang.name].label

            if setType == 'Promote' then 
                if tonumber(currentGang.grade.level) > gangGrade then 
                    setType = 'Demote'
                end
            end

            local newGang = {}
            newGang.name = gangName
            newGang.grade = {
                name = QBCore.Shared.Gangs[gangName].grades[tonumber(gangName)] and QBCore.Shared.Gangs[gangName].grades[tonumber(gangGrade)].name or QBCore.Shared.Gangs[gangName].grades[tostring(gangGrade)].name,
                level = tonumber(gangGrade)
            }
            newGang.isboss = QBCore.Shared.Gangs[gangName].grades[tonumber(gangGrade)] and (QBCore.Shared.Gangs[gangName].grades[tonumber(gangGrade)].isboss and true or false) or (QBCore.Shared.Gangs[gangName].grades[tostring(gangGrade)].isboss and true or false)
            newGang.label = QBCore.Shared.Gangs[gangName].label

            local res = MySQL.update.await('UPDATE players SET gang = ? WHERE citizenid = ?', {json.encode(newGang), (setType == 'Hire' and targetPlayer.PlayerData.citizenid or playerIdentifier)})

            if targetPlayer then targetPlayer.Functions.SetGang(gangName, gangGrade) end

            if setType == 'Fire' then 
                MK_CORE.Notify(src, {Message = locale('player_removed', fullName), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('player_removed_notify', oldGang), Type = 'error', Duration = 8000}) end
            elseif setType == 'Hire' then 
                MK_CORE.Notify(src, {Message = locale('player_joined', fullName, newGang.label), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('player_joined_notify', newGang.label), Type = 'primary', 8000}) end
            elseif setType == 'Promote' then 
                MK_CORE.Notify(src, {Message = locale('gang_promoted', fullName, newGang.grade.name)})
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('gang_promoted_notify', newGang.grade.name), Type = 'primary', Duration = 8000}) end
            elseif setType == 'Demote' then
                MK_CORE.Notify(src, {Message = locale('gang_demoted', fullName, newGang.grade.name), Type = 'primary', duration = 5000})
                if targetPlayer then MK_CORE.Notify(targetPlayer.PlayerData.source, {Message = locale('gang_demoted_notify', newGang.grade.name), Type = 'error', Duration = 5000}) end
            end
        elseif Framework == 'ESX' then 
            if setType == 'Hire' and result[1].gang == gangName then
                MK_CORE.Notify(src, {Message = locale('already_in_gang'), Type = 'error', Duration = 5000})
                return
            end

            oldGang = ESX.Gangs[result[1].gang].label

            if setType == 'Promote' then 
                if tonumber(result[1].gang_grade) > gangGrade then 
                    setType = 'Demote'
                end
            end

            local res = MySQL.update.await('UPDATE users SET gang = ?, gang_grade = ? WHERE identifier = ?', {gangName, tonumber(gangGrade), (setType == 'Hire' and targetPlayer.identifier or playerIdentifier)})

            if targetPlayer then 
                if targetPlayer.setGang then 
                    targetPlayer.setGang(gangName, gangGrade) 
                end
            end

            local newGangLabel = (ESX.Gangs[gangName].grades[gangGrade] and ESX.Gangs[gangName].grades[gangGrade].label or ESX.Gangs[gangName].grades[tostring(gangGrade)].label)

            if setType == 'Fire' then 
                MK_CORE.Notify(src, {Message = locale('player_removed', fullName), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('player_removed_notify', oldGang), Type = 'error', Duration = 8000}) end
            elseif setType == 'Hire' then 
                MK_CORE.Notify(src, {Message = locale('player_joined', fullName, ESX.Gangs[gangName].label), Type = 'primary', Duration = 5000})
                TriggerClientEvent('MK_BossMenu:Client:CloseBossMenu', src)
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('player_joined_notify', ESX.Gangs[gangName].label), Type = 'primary', 8000}) end
            elseif setType == 'Promote' then 
                MK_CORE.Notify(src, {Message = locale('gang_promoted', fullName, newGangLabel)})
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('gang_promoted_notify', newGangLabel), Type = 'primary', Duration = 8000}) end
            elseif setType == 'Demote' then
                MK_CORE.Notify(src, {Message = locale('gang_demoted', fullName, newGangLabel), Type = 'primary', duration = 5000})
                if targetPlayer then MK_CORE.Notify(targetPlayer.source, {Message = locale('gang_demoted_notify', newGangLabel), Type = 'error', Duration = 5000}) end
            end
        end
    end
end)

lib.callback.register('MK_BossMenu:Server:GetEsxName', function(source, ident)
    local src = source
    local result = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {ident})
    if result and result[1] then 
        return result[1].firstname, result[1].lastname
    else
        return false, false
    end
end)