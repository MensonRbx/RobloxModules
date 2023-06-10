--[[
  Been doing some tinkering, and taught of not having a constructor, and just returning a table with functions. 
  Seems to be the same thing like.
]]

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local STORE_VERSION = "1"
local DATASTORE_NAME = "StudioStore"
local MAX_RETRIES = 5

local defaultStore = DataStoreService:GetDataStore(DATASTORE_NAME..STORE_VERSION)

local BetterDataService = {}

function BetterDataService:GetPlayerData(player: Player, dataStore: DataStore | OrderedDataStore)

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

function BetterDataService:SetPlayerData(player: Player, valueToSave: any, dataStore: DataStore | OrderedDataStore)

	dataStore = dataStore or defaultStore

	if RunService:IsStudio() and typeof(valueToSave) == "table" then
		coroutine.wrap(BetterDataService._SetOrderedDataStoreValues)(BetterDataService, player, valueToSave)
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

	if typeof(valueToSave) == "table" then
		BetterDataService:_SetOrderedDataStoreValues(player, valueToSave)
	end

end

function BetterDataService:_SetOrderedDataStoreValues(player: Player, dataTable: table)

	for key, value in dataTable do
		if typeof(value) == "number" then
			local orderedDataStore = DataStoreService:GetOrderedDataStore(key.."OrderedStore"..STORE_VERSION)
			BetterDataService:SetPlayerData(player, value, orderedDataStore)
		end
	end

end

return BetterDataService
