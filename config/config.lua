Config = {}

Config.ConsoleLogging = true --TRUE DISPLAYS SCRIPT LOGGING INFO IN F8 AND SERVER CONSOLE

------------------------------------------------------NOTIFICATIONS-----------------------------------------------------------
Config.Notify = { 
    UseCustom = false, --FALSE = DEFAULT NOTIFY WILL BE YOUR FRAMEWORKS NOTIFY SYSTEM (QBCore:Notify / esx:showNotification) / TRUE = CUSTOM NOTIFY SCRIPT (OX_LIB / T-NOTIFY / ECT) (VIEW README FILE FOR DETAILED SETUP INFO)
    CustomClientNotifyFunction = function(Data) --**CLIENT SIDE CODE**
        ---@param Data table: { Message string, Type string (error, success, primary), Duration number }
        
        --TriggerEvent('QBCore:Notify', Data.Message, Data.Type, Data.Duration) --QBCORE EXAMPLE
    end,
    CustomServerNotifyFunction = function(PlayerSource, Data) --**SERVER SIDE CODE** SAME AS ABOVE EXCEPT PASSES THE SOURCE TO SEND THE NOTIFICATION TO FROM THE SERVER
        ---@param PlayerSource number Server id of the player
        ---@param Data table: { Message string, Type string (error, success, primary), Duration number }

        --TriggerClientEvent('QBCore:Notify', PlayerSource, Data.Message, Data.Type, Data.Duration) --QBCORE EXAMPLE
    end,
}
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------TEXT UI-----------------------------------------------------------------
Config.UseTextUI = true --Displays ox_lib text ui when near bossmenu area

Config.TextUI = { --ox_lib text ui for using the boss menu
    Position = 'left-center', --left-center / right-center / top-center
    Icon = {
        Icon = 'fa-solid fa-tablet-screen-button', --FONT AWESOME ICON
        Color = 'white', --ICON COLOR
    },
    Style = { --REACT.CSS PROPERTIES STYLING
        borderRadius = 0,
        backgroundColor = '#1A626B', --BACKGROUND
        color = 'white' --TEXT COLOR
    }
}
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------RADIAL MENU-------------------------------------------------------------
Config.UseOxLibRadialMenu = true --Add bossmenu option to ox_lib radial menu when near bossmenu area

Config.RadialMenu = {
    Icon = 'fa-solid fa-tablet-screen-button',
    JobLabel = 'Boss',
    GangLabel = 'Gang'
}
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------MENU--------------------------------------------------------------------
Config.UseOxLibContextMenu = true --set true to use ox_lib menu / false to use the script provided menu
------------------------------------------------------------------------------------------------------------------------------