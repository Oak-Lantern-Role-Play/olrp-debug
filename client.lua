-- RDR2 prop list courteout of https://github.com/BryceCanyonCounty
-- Peds:     https://raw.githubusercontent.com/BryceCanyonCounty/rdr3-nativedb-data/master/objects/peds.json
-- Vehicles: https://raw.githubusercontent.com/BryceCanyonCounty/rdr3-nativedb-data/master/objects/vehicles.json
-- Objects:  https://raw.githubusercontent.com/BryceCanyonCounty/rdr3-nativedb-data/master/objects/objects.json
-- Custom:   Please read the readme.md for instructions on how to generate this list

-- Resource name
local resource = GetCurrentResourceName()

-- Table contains var function
function table_contains(tbl, x)
    for _, v in pairs(tbl) do
        if v == x then 
            return true 
        end
    end
    return false
end

-- Read JSON files
local jsonItems = {}
local jsonPeds = {}
local jsonVehicles = {}
local jsonCustom = {}
local unique = {}

-- Note do not change this load order, the BryceCanyonCounty list seems to duplicate vehicles in the items list.. this order prevents duplicates

local fileVehicles = LoadResourceFile(resource, "entities/vehicles.json") -- Read the file
if fileVehicles then
    for _, data in ipairs(json.decode(fileVehicles)) do -- Decode data
        if not table_contains(unique, data.hash) then -- Confirm not duplicate
            table.insert(unique, data.hash) -- Add to category table
            table.insert(jsonVehicles, data.hash) -- Add to unique table
        end
    end
end

local filePeds = LoadResourceFile(resource, "entities/peds.json") -- Read the file
if filePeds then
    for _, data in ipairs(json.decode(filePeds)) do -- Decode data
        if not table_contains(unique, data.hash) then -- Confirm not duplicate
            table.insert(unique, data.hash) -- Add to category table
            table.insert(jsonPeds, data.hash) -- Add to table
        end
    end
end

local fileItems = LoadResourceFile(resource, "entities/items.json") -- Read the file
if fileItems then
    for _, data in ipairs(json.decode(fileItems)) do -- Decode data
        if not table_contains(unique, data.hash) then -- Confirm not duplicate
            table.insert(unique, data.hash) -- Add to category table
            table.insert(jsonItems, data.hash) -- Add to table
        end
    end
end

local fileCustom = LoadResourceFile(resource, "entities/custom.json") -- Read the file
if fileCustom then
    for _, data in ipairs(json.decode(fileCustom)) do -- Decode data
        local hash = GetHashKey(data) -- Not multidimensional, convert name to hash
        if not table_contains(unique, hash) then -- Confirm not duplicate
            table.insert(unique, hash) -- Add to category table
            table.insert(jsonCustom, hash) -- Add to table
        end
    end
end

-- Check if display should be active
local active = false

-- Recommended max models loaded before RAGE error: 0x9952DB5E:212 crash
local maxLoad = 990  -- 990 recommended from SPOONI

-- Draw Text
function drawPoolText(text, x, y, percent)
   
    -- Setup text properties
    SetTextDropshadow(2, 0, 0, 0, 200) -- Offset 2px, Black color, mostly opaque
    SetTextScale(0.25, 0.25)

    -- Colour based on usage percentage
    if percent ~= nil and percent >= 1.0 then
        SetTextColor(210, 34, 45, 255) -- RED RGBA (>100%)
    elseif percent ~= nil and percent >= 0.95 then
        SetTextColor(255, 191, 0, 255) -- AMBER RGBA (>=95%)
    else 
        SetTextColor(255, 255, 255, 255) -- WHITE RGBA
    end
    
    -- Align to center
    SetTextCentre(true)
            
    -- Create the string
    local string = VarString(10, 'LITERAL_STRING', text)

    -- Draw at screen coordinates (0.0 to 1.0)
    BgDisplayText(string, x, y)
end

-- Command to start display
RegisterCommand('showmodels', function(source, args, rawCommand)
    if active then
        active = false
        print('Stop model monitor')
    else
        active = true
        displayCounter()
        print('Start model monitor')
    end
end)
TriggerEvent('chat:addSuggestion', "/showmodels", "\nToggle a counter for all loaded models", {})

-- Display objects on screen
function displayCounter()

    local CPed = 0
    local CObject = 0
    local CNetObject = 0
    local CVehicle = 0
    local CPickup = 0

    local loadedTotal = 0
    local loadedItems = 0
    local loadedPeds = 0
    local loadedVehicles = 0
    local loadedCustom = 0

    local totalItems = #jsonItems
    local totalPeds = #jsonPeds
    local totalVehicles = #jsonVehicles
    local totalCustom = #jsonCustom

    -- Count every 0.5 seconds
    CreateThread(function()
        while active do
            Wait(500)          
            
            -- Pool count
            CPed = #GetGamePool('CPed')
            CObject = #GetGamePool('CObject')
            CNetObject = #GetGamePool('CNetObject')
            CVehicle = #GetGamePool('CVehicle')
            CPickup = #GetGamePool('CPickup')

            -- Model count
            loadedItems = 0
            loadedPeds = 0
            loadedVehicles = 0
            loadedCustom = 0

            -- Count Items
            for _, hash in ipairs(jsonItems) do
                if HasModelLoaded(hash) then
                    loadedItems = loadedItems + 1
                end
            end
            
            -- Count Peds
            for _, hash in ipairs(jsonPeds) do
                if HasModelLoaded(hash) then
                    loadedPeds = loadedPeds + 1
                end
            end

            -- Count Vehicles
            for _, hash in ipairs(jsonVehicles) do
                if HasModelLoaded(hash) then
                    loadedVehicles = loadedVehicles + 1
                end
            end

            -- Count Custom
            for _, hash in ipairs(jsonCustom) do
                if HasModelLoaded(hash) then
                    loadedCustom = loadedCustom + 1
                end
            end

            -- Total
            loadedTotal = loadedItems + loadedPeds + loadedVehicles + loadedCustom
            
            -- Print to console
            print(string.format("Models loaded: %d/%d", loadedTotal, maxLoad))
        end
    end)

    -- Render display on every frame
    CreateThread(function()
        while active do
            Wait(0)
            
            drawPoolText('Pool CPeds: ' .. tostring(CPed),       0.5, 0.10)
            drawPoolText('Pool CObject: ' .. tostring(CObject),    0.5, 0.115)
            drawPoolText('Pool CNetObject: ' .. tostring(CNetObject), 0.5, 0.13)
            drawPoolText('Pool CVehicle: ' .. tostring(CVehicle),   0.5, 0.145)
            drawPoolText('Pool CPickup: ' .. tostring(CPickup),    0.5, 0.16)

            drawPoolText('Model Items: ' .. tostring(loadedItems),    0.5, 0.19)
            drawPoolText('Model Peds: ' .. tostring(loadedPeds),    0.5, 0.205)
            drawPoolText('Model Vehicles: ' .. tostring(loadedVehicles),    0.5, 0.22)
            drawPoolText('Model Custom: ' .. tostring(loadedCustom),    0.5, 0.235)
            drawPoolText('Model Total: ' .. tostring(loadedTotal) .. '/' .. tostring(maxLoad), 0.5, 0.25, (loadedTotal/maxLoad))
        end
    end)
end

-- Resource Stopped
AddEventHandler('onResourceStop', function(resourceName)

    -- Check event is our resource
    if GetCurrentResourceName() ~= resourceName then return end

    -- Active
    active = false
end)
