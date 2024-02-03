Config.Jobs = { --Add/Remove jobs to fit your server
    ['police'] = { --Job name
        HireGrades = { 3, 4 },    --Grades that are allowed to hire/demote players
        FireGrades = { 3, 4 },    --Grades that are allowed to fire players
        DepositGrades = { 3, 4 }, --Grades that are allowed to deposit into society
        WithdrawGrades = { 4 },   --Grades that are allowed to withdraw from society
        Locations = { --Locations to access the boss menu. Add as many as you need
            {
                Coords = vector3(448.17, -973.37, 30.69), --location to display the open boss menu text ui (shows within 5 meters of the coords)
                Distance = 5, --Distance away from the coords to be able to access the boss menu
                Label = 'MRPD - Captains Office', --This label is only used for your own reference (not displayed in the script)
            },
            {
                Coords = vector3(-448.75, 6012.07, 31.72),
                Distance = 5,
                Label = 'Paleto PD - Front Desk'
            }
        }
    },
    ['ambulance'] = {
        HireGrades = { 3, 4 },
        FireGrades = { 3, 4 },
        DepositGrades = { 3, 4 },
        WithdrawGrades = { 4 },
        Locations = {
            {
                Coords = vector3(303.33, -601.25, 43.29),
                Distance = 5,
                Label = 'Pillbox - Front Desk',
            }
        }
    },
    ['realestate'] = {
        HireGrades = { 3, 4 },
        FireGrades = { 3, 4 },
        DepositGrades = { 3, 4 },
        WithdrawGrades = { 4 },
        Locations = {
            {
                Coords = vector3(-264.75, -965.71, 31.22),
                Distance = 5,
                Label = 'City Hall',
            }
        }
    },
    ['taxi'] = {
        HireGrades = { 3, 4 },
        FireGrades = { 3, 4 },
        DepositGrades = { 3, 4 },
        WithdrawGrades = { 4 },
        Locations = {
            {
                Coords = vector3(895.08, -180.3, 74.7),
                Distance = 5,
                Label = 'Downtown Cab - Entrance Door',
            }
        }
    },
    ['cardealer'] = {
        HireGrades = { 3, 4 },
        FireGrades = { 3, 4 },
        DepositGrades = { 3, 4 },
        WithdrawGrades = { 4 },
        Locations = {
            {
                Coords = vector3(-31.33, -1114.51, 26.42),
                Distance = 5,
                Label = 'PDM - Right Office',
            },
            {
                Coords = vector3(-27.45, -1103.35, 26.42),
                Distance = 5,
                Label = 'PDM - Left Office'
            }
        }
    },
    ['mechanic'] = {
        HireGrades = { 3, 4 },
        FireGrades = { 3, 4 },
        DepositGrades = { 3, 4 },
        WithdrawGrades = { 4 },
        Locations = {
            {
                Coords = vector3(-345.44, -131.05, 39.01),
                Distance = 5,
                Label = 'Autocare Mechanic',
            }
        }
    },
}


--Do not edit the below function unless you know what you're doing
exports('checkJob', checkJob)
function checkJob(jobName) 
    ---@return canHire boolean Player has ability to hire
    ---@return canFire boolean Player has ability to fire
    ---@return myGrade number Player current job grade
    ---@return jobGrades table: { [number, string]: { <name/label> string, <payment/salary> number } }

    local canHire, canFire, canDeposit, canWithdraw, myGrade, jobGrades = false, false, false, false, nil, nil

    if Framework == 'QBCORE' then 
        if PlayerData then 
            if PlayerData.job then 
                if PlayerData.job.name == jobName then 
                    if QBCore.Shared.Jobs[PlayerData.job.name] then 
                        if QBCore.Shared.Jobs[PlayerData.job.name].grades then 
                            if PlayerData.job.grade then 
                                if PlayerData.job.grade.level then 
                                    jobGrades = QBCore.Shared.Jobs[PlayerData.job.name].grades
                                    local grade = jobGrades[PlayerData.job.grade.level]
                                    if not grade then grade = jobGrades[tostring(PlayerData.job.grade.level)] end
                                    if grade then 
                                        if Config.Jobs[jobName] then 
                                            local next = next

                                            if Config.Jobs[jobName].HireGrades ~= nil and next(Config.Jobs[jobName].HireGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].HireGrades) do 
                                                    if value == PlayerData.job.grade.level then 
                                                        canHire = true
                                                        myGrade = PlayerData.job.grade.level
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Jobs[jobName].FireGrades ~= nil and next(Config.Jobs[jobName].FireGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].FireGrades) do 
                                                    if value == PlayerData.job.grade.level then 
                                                        canFire = true
                                                        myGrade = PlayerData.job.grade.level
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Jobs[jobName].DepositGrades ~= nil and next(Config.Jobs[jobName].DepositGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].DepositGrades) do 
                                                    if value == PlayerData.job.grade.level then 
                                                        canDeposit = true
                                                        myGrade = PlayerData.job.grade.level
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Jobs[jobName].WithdrawGrades ~= nil and next(Config.Jobs[jobName].WithdrawGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].WithdrawGrades) do 
                                                    if value == PlayerData.job.grade.level then 
                                                        canWithdraw = true
                                                        myGrade = PlayerData.job.grade.level
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

        return canHire, canFire, canDeposit, canWithdraw, myGrade, jobGrades
    elseif Framework == 'ESX' then 
        if ESX.PlayerData then 
            if not ESX.PlayerData.firstName or not ESX.PlayerData.lastName then
                lib.callback('MK_BossMenu:Server:GetEsxName', true, function(first, last)
                    if first then ESX.PlayerData.firstName = first end 
                    if last then ESX.PlayerData.lastName = last end
                end, ESX.PlayerData.identifier)
            else
                if ESX.PlayerData.job then 
                    if ESX.PlayerData.job.name == jobName then 
                        if ESX.Jobs[ESX.PlayerData.job.name] then 
                            if ESX.Jobs[ESX.PlayerData.job.name].grades then 
                                if ESX.PlayerData.job.grade then --number
                                    jobGrades = ESX.Jobs[ESX.PlayerData.job.name].grades
                                    local grade = jobGrades[ESX.PlayerData.job.grade]
                                    if not grade then grade = jobGrades[tostring(ESX.PlayerData.job.grade)] end
                                    if grade then 
                                        if Config.Jobs[jobName] then 
                                            local next = next

                                            if Config.Jobs[jobName].HireGrades ~= nil and next(Config.Jobs[jobName].HireGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].HireGrades) do 
                                                    if value == ESX.PlayerData.job.grade then 
                                                        canHire = true
                                                        myGrade = ESX.PlayerData.job.grade
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Jobs[jobName].FireGrades ~= nil and next(Config.Jobs[jobName].FireGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].FireGrades) do 
                                                    if value == ESX.PlayerData.job.grade then 
                                                        canFire = true
                                                        myGrade = ESX.PlayerData.job.grade
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Jobs[jobName].DepositGrades ~= nil and next(Config.Jobs[jobName].DepositGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].DepositGrades) do 
                                                    if value == ESX.PlayerData.job.grade then 
                                                        canDeposit = true
                                                        myGrade = ESX.PlayerData.job.grade
                                                        break
                                                    end
                                                end
                                            end

                                            if Config.Jobs[jobName].WithdrawGrades ~= nil and next(Config.Jobs[jobName].WithdrawGrades) ~= nil then 
                                                for key, value in pairs(Config.Jobs[jobName].WithdrawGrades) do 
                                                    if value == ESX.PlayerData.job.grade then 
                                                        canWithdraw = true
                                                        myGrade = ESX.PlayerData.job.grade
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

        return canHire, canFire, canWithdraw, canDeposit, myGrade, jobGrades
    end
end