local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SAVE_TO_ORDERED_STORES = true

local DATASTORE_NAME = "StudioStore"

local MAX_RETRIES = 5

local defaultStore = DataStoreService:GetDataStore(DATASTORE_NAME)

local BetterDataService = {}

function BetterDataService:GetPlayerData(player: Player, dataStore: DataStore | OrderedDataStore | string)
	
	if typeof(dataStore) == "string" then
		dataStore = DataStoreService:GetDataStore(dataStore)
	end
	
	dataStore = dataStore or defaultStore

	local count = 0
	repeat
		local success, playerData = pcall(dataStore.GetAsync, dataStore, tostring(player.UserId))

		if success and playerData then
			return playerData
		end

		count += 1
		task.wait(1 + 2 * count)
	until count > MAX_RETRIES

end

function BetterDataService:SetPlayerData(player: Player, valueToSave: any, dataStore: DataStore | OrderedDataStore | string)
	
	if typeof(dataStore) == "string" then
		dataStore = DataStoreService:GetDataStore(dataStore)
	end
	
	dataStore = dataStore or defaultStore

	if SAVE_TO_ORDERED_STORES and typeof(valueToSave) == "table" then
		coroutine.wrap(BetterDataService._SetOrderedDataStoreValues)(self, player, valueToSave)
	end
	
	local count = 0
	repeat
		local success = pcall(dataStore.SetAsync, dataStore, tostring(player.UserId), valueToSave)

		if success then
			return true
		end

		count += 1
		task.wait(1 + 2 * count)
	until count > MAX_RETRIES
	
end

function BetterDataService:_SetOrderedDataStoreValues(player: Player, dataTable: table)

	for key, value in dataTable do
		if typeof(value) == "number" then
			local orderedDataStore = DataStoreService:GetOrderedDataStore(key.."OrderedStore")
			BetterDataService:SetPlayerData(player, value, orderedDataStore)
		end
	end

end

return BetterDataService
