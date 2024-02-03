Config.Gangs = { --Add/Remove gangs to fit your server.
    ['lostmc'] = { --Gang name
        HireGrades = { 2, 3 },    --Grades that are allowed to add/demote players
        FireGrades = { 3 },       --Grades that are allowed to remove players
        DepositGrades = { 2, 3 }, --Grades that are allowed to deposit into society
        WithdrawGrades = { 3 },   --Grades that are allowed to withdraw from society
        Locations = { --Locations to access the boss menu. Add as many as you need
            {
                Coords = vector3(976.17, -101.39, 74.85), --location to display the open boss menu text ui (shows within 5 meters of the coords)
                Distance = 5, --Distance away from the coords to be able to access the boss menu
                Label = 'Clubhouse - Mirror Park' --This label is only used for your own reference (not displayed in the script)
            }
        }
    },
    ['ballas'] = {
        HireGrades = { 2, 3 },
        FireGrades = { 3 },
        DepositGrades = { 2, 3 },
        WithdrawGrades = { 3 },
        Locations = {
            {
                Coords = vector3(102.87, -1959.07, 20.8),
                Distance = 5,
                Label = 'Grove Street'
            }
        }
    },
    ['vagos'] = {
        HireGrades = { 2, 3 },
        FireGrades = { 3 },
        DepositGrades = { 2, 3 },
        WithdrawGrades = { 3 },
        Locations = {
            {
                Coords = vector3(333.77, -2023.34, 21.71),
                Distance = 5,
                Label = 'Southside Apartments'
            }
        }
    },
    ['cartel'] = {
        HireGrades = { 2, 3 },
        FireGrades = { 3 },
        DepositGrades = { 2, 3 },
        WithdrawGrades = { 3 },
        Locations = {
            {
                Coords = vector3(1392.63, 1141.61, 114.44),
                Distance = 5,
                Label = 'Mansion Front Door'
            }
        }
    },
    ['families'] = {
        HireGrades = { 2, 3 },
        FireGrades = { 3 },
        DepositGrades = { 2, 3 },
        WithdrawGrades = { 3 },
        Locations = {
            {
                Coords = vector3(-803.29, 171.98, 72.84),
                Distance = 5,
                Label = 'Michaels House - Living Room'
            }
        }
    },
    ['triads'] = {
        HireGrades = { 2, 3 },
        FireGrades = { 3 },
        DepositGrades = { 2, 3 },
        WithdrawGrades = { 3 },
        Locations = {
            {
                Coords = vector3(-764.03, -919.0, 20.2),
                Distance = 5,
                Label = 'Little Seoul'
            }
        }
    }
}


--Do not edit the below function unless you know what you're doing
exports('checkGang', checkGang)
function checkGang(gangName) 
    ---@return canHire boolean Player has ability to hire
    ---@return canFire boolean Player has ability to fire
    ---@return myGrade number Player current gang grade
    ---@return gangGrades table: { [number, string]: { <name/label> string } }

    local canHire, canFire, canDeposit, canWithdraw, myGrade, gangGrades = false, false, false, false, nil, nil
    
    if Framework == 'QBCORE' then 
        if PlayerData then 
            if PlayerData.gang then 
                if PlayerData.gang.name == gangName then 
                    if QBCore.Shared.Gangs[PlayerData.gang.name] then 
                        if QBCore.Shared.Gangs[PlayerData.gang.name].grades then 
                            if PlayerData.gang.grade then 
                                if PlayerData.gang.grade.level then 
                                    gangGrades = QBCore.Shared.Gangs[PlayerData.gang.name].grades
                                    local grade = gangGrades[PlayerData.gang.grade.level]
                                    if not grade then grade = gangGrades[tostring(PlayerData.gang.grade.level)] end
                                    if grade then 
                                        if Config.Gangs[gangName] then 
                                            local next = next

                                            if Config.Gangs[gangName].HireGrades ~= nil and next(Config.Gangs[gangName].HireGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].HireGrades) do 
                                                    if value == PlayerData.gang.grade.level then 
                                                        canHire = true
                                                        myGrade = PlayerData.gang.grade.level
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Gangs[gangName].FireGrades ~= nil and next(Config.Gangs[gangName].FireGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].FireGrades) do 
                                                    if value == PlayerData.gang.grade.level then 
                                                        canFire = true
                                                        myGrade = PlayerData.gang.grade.level
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Gangs[gangName].DepositGrades ~= nil and next(Config.Gangs[gangName].DepositGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].DepositGrades) do 
                                                    if value == PlayerData.gang.grade.level then 
                                                        canDeposit = true
                                                        myGrade = PlayerData.gang.grade.level
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Gangs[gangName].WithdrawGrades ~= nil and next(Config.Gangs[gangName].WithdrawGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].WithdrawGrades) do 
                                                    if value == PlayerData.gang.grade.level then 
                                                        canWithdraw = true
                                                        myGrade = PlayerData.gang.grade.level
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                
                end
            end
        end

        return canHire, canFire, canDeposit, canWithdraw, myGrade, gangGrades
    elseif Framework == 'ESX' then 
        if ESX.PlayerData then 
            if not ESX.PlayerData.firstName or not ESX.PlayerData.lastName then
                lib.callback('MK_BossMenu:Server:GetEsxName', true, function(first, last)
                    if first then ESX.PlayerData.firstName = first end 
                    if last then ESX.PlayerData.lastName = last end
                end, ESX.PlayerData.identifier)
            else
                if ESX.PlayerData.gang then 
                    if ESX.PlayerData.gang.name == gangName then 
                        if ESX.Gangs[ESX.PlayerData.gang.name] then 
                            if ESX.Gangs[ESX.PlayerData.gang.name].grades then 
                                if ESX.PlayerData.gang.grade then --number
                                    gangGrades = ESX.Gangs[ESX.PlayerData.gang.name].grades
                                    local grade = gangGrades[ESX.PlayerData.gang.grade]
                                    if not grade then grade = gangGrades[tostring(ESX.PlayerData.gang.grade)] end
                                    if grade then 
                                        if Config.Gangs[gangName] then 
                                            local next = next

                                            if Config.Gangs[gangName].HireGrades ~= nil and next(Config.Gangs[gangName].HireGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].HireGrades) do 
                                                    if value == ESX.PlayerData.gang.grade then 
                                                        canHire = true
                                                        myGrade = ESX.PlayerData.gang.grade
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Gangs[gangName].FireGrades ~= nil and next(Config.Gangs[gangName].FireGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].FireGrades) do 
                                                    if value == ESX.PlayerData.gang.grade then 
                                                        canFire = true
                                                        myGrade = ESX.PlayerData.gang.grade
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Gangs[gangName].DepositGrades ~= nil and next(Config.Gangs[gangName].DepositGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].DepositGrades) do 
                                                    if value == ESX.PlayerData.gang.grade then 
                                                        canDeposit = true
                                                        myGrade = ESX.PlayerData.gang.grade
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Gangs[gangName].WithdrawGrades ~= nil and next(Config.Gangs[gangName].WithdrawGrades) ~= nil then 
                                                for key, value in pairs(Config.Gangs[gangName].WithdrawGrades) do 
                                                    if value == ESX.PlayerData.gang.grade then 
                                                        canWithdraw = true
                                                        myGrade = ESX.PlayerData.gang.grade
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        return canHire, canFire, canDeposit, canWithdraw, myGrade, gangGrades
    end
end