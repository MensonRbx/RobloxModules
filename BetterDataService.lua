local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DATASTORE_NAME = "StudioStore"
local MAX_RETRIES = 5

local defaultStore = DataStoreService:GetDataStore(DATASTORE_NAME)

local BetterDataService = {}
BetterDataService.__index = BetterDataService

function BetterDataService.new()
	local self = setmetatable({}, BetterDataService)
	
	return self
end

--gets player data
function BetterDataService:GetPlayerDataFromStore(player: Player, dataStore: DataStore | OrderedDataStore)

	dataStore = dataStore or defaultStore

	local count = 0
	repeat
		--"shorthand pcall, not so sure if this is good practice"
		local _, playerData = pcall(dataStore.GetAsync, dataStore, tostring(player.UserId))

		if playerData then
			return playerData
		end
		
		count += 1
		task.wait(1 + 2 * count)
	until count > MAX_RETRIES

end

--sets player data in their store
function BetterDataService:SetPlayerStoreData(player: Player, valueToSave: any, dataStore: DataStore | OrderedDataStore)

	dataStore = dataStore or defaultStore
	
	--think this is just for studio
	if RunService:IsStudio() and typeof(valueToSave) == "table" then
		coroutine.wrap(BetterDataService._SetOrderedDataStoreValues)(BetterDataService, player, valueToSave)
	end

	local count = 0
	repeat
		--"shorthand pcall"
		local success = pcall(dataStore.SetAsync, dataStore, tostring(player.UserId), valueToSave)

		if success then
			return true
		end

		count += 1
		task.wait(1 + 2 * count)
	until count > MAX_RETRIES
	
	if typeof(valueToSave) == "table" then
		BetterDataService:_SetOrderedDataStoreValues(player, valueToSave)
	end

end

--[[
	Method goes through table and sets ordered data store values of numerical memebers
	of table for leaderboards
]]
function BetterDataService:_SetOrderedDataStoreValues(player: Player, dataTable: table)

	for key, value in dataTable do
		if typeof(value) == "number" then
			local orderedDataStore = DataStoreService:GetOrderedDataStore(key.."OrderedStore")
			BetterDataService:SetPlayerStoreData(player, value, orderedDataStore)
		end
	end

end

return BetterDataService.new()
