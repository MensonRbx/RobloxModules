local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SubModules = script.Parent:WaitForChild("SubModules")

local CacheClass  = require(SubModules:WaitForChild("CacheClass"), 60)
local HandleSetRequest = require(SubModules:WaitForChild("HandleSetRequest", 60))
local DataSaveSettings = require(SubModules:WaitForChild("DataSaveSettings", 60))
local DeepCopy = require(SubModules:WaitForChild("DeepCopy"))

local DataStoreName = "StudioDataStore"

local DataModule = {}
DataModule.__index = DataModule

function DataModule.new()
	local self = setmetatable({}, DataModule)

	self.dataScopes = {}
	self.orderedDataScopes = {}

	self.PlayerDataOnJoin, self.PlayerDataOnJoinCacheIndex = CacheClass.new("table", Players.MaxPlayers + 1)
	self.LightPlayerData, self.LightPlayerDataCacheIndex = CacheClass.new("table", Players.MaxPlayers + 1)

	self.basePlayerStats = {
		{"Wins", "NumberValue", 0, "leaderstats"},
		{"Goals", "NumberValue", 0, "invisstats"},
		{"Points", "NumberValue", 0, "invisstats"}
	}	

	do
		for i, playerStat in self.basePlayerStats do
			local scopeName = playerStat[1]
			self.dataScopes[scopeName] = DataStoreService:GetDataStore(DataStoreName, scopeName)

			if type(playerStat[3]) == "number" then
				self.orderedDataScopes[scopeName] = DataStoreService:GetOrderedDataStore(DataStoreName, scopeName)
			end

		end
	end

	local onPlayerJoined = function(player)
		self:PlayerJoin(player)
	end

	local onPlayerLeave = function(player)
		self:PlayerLeft(player)
	end

	local onGameClose = function()
		self:SaveAllPlayers()
	end

	game:BindToClose(onGameClose)

	return self
end

function DataModule:GetAndSetPlayerData(player: Player)

	self:CreatePlayerLeaderstats(player)

	local playerDataTable = self:GetHeavyPlayerData(player) or {}

	if playerDataTable then
		self:SetPlayerLeaderstats(player, "", playerDataTable)
	end

	self:CreatePlayerLightDataAndJoinData(player, playerDataTable)
	self:AutosavePlayerAsync(player)

end

function DataModule:GetHeavyPlayerData(player, scope)

	local key = tostring(player.UserId)

	if scope then
		local dataStore: GlobalDataStore = self.dataScopes[scope]
		local data

		for i = 1, 5 do
			local success, err = pcall(function()
				data = dataStore:GetAsync(key)
			end)

			if data then return data end
			task.wait(1)
		end
	else

		local dataTable = {}

		for name, dataStore in self.dataScopes do

			local dataValue = nil

			local success, err = pcall(function()
				dataValue = dataStore:GetAsync(key)
			end)

			if success then
				dataTable[name] = dataValue
			end

		end

		return dataTable
	end 

end

function DataModule:SavePlayerData(player: Player, scope: string, leaving: boolean)

	local key = tostring(player.UserId)

	if scope then

		local dataStore: GlobalDataStore = self.dataScopes[scope]

		for i = 1, 5 do
			local success, err = pcall(function()
				dataStore:SetAsync(key, player.leaderstats[scope].Value)
			end)	
			if success then return end
		end

	else
		
		local playerLeaveData = self.LightPlayerData:GetFromCache(player.UserId)
		local playerJoinData = self.PlayerDataOnJoin:GetFromCache(player.UserId)

		for name, dataStore: GlobalDataStore in self.dataScopes do
			local onLeaveValue = playerLeaveData[name]
			local onJoinValue = playerJoinData[name]

			if onLeaveValue == onJoinValue then continue end

			if RunService:IsStudio() then
				self:SaveToScope(dataStore, key, onLeaveValue)
				if type(onLeaveValue) == "number" then
					self:SaveToScope(self.orderedDataScopes[name], key, onLeaveValue)
				end
			else
				HandleSetRequest(dataStore, dataStore.SetAsync, player.UserId, name.."SetAsyncForGlobalDataStore", key, onLeaveValue)
				if type(onLeaveValue) == "number" then
					local orderedDataStore = self.orderedDataScopes[name]
					HandleSetRequest(orderedDataStore, orderedDataStore.SetAsync, player.UserId, name.."SetAsyncForOrderedDataStore", key, onLeaveValue)
				end
			end

		end

		if leaving then
			self.LightPlayerData:RemoveFromCacheIndex(player.UserId)
			self.PlayerDataOnJoin:RemoveFromCacheIndex(player.UserId)
		end

	end

end

function DataModule:SetPlayerLeaderstats(player, scope, playerData)

	if scope and scope ~= "" then
		local valueObject = player.leaderstats:FindFirstChild(scope) or player.invisstats:FindFirstChild(scope)
		valueObject.Value = playerData
		return
	end
	for name, value in pairs(playerData) do
		local stat = player.leaderstats:FindFirstChild(name) or player.invisstats:FindFirstChild(name)
		stat.Value = value
	end

end

function DataModule:GetCurrentPlayerLeaderstats(player, scope)

	if scope and scope ~= "" then
		local valueObject = player.leaderstats:FindFirstChild(scope) or player.invisstats:FindFirstChild(scope)
		return valueObject.Value
	end

	local dataDictionary = {}

	for i, value in player.leaderstats:GetChildren() do
		dataDictionary[value.Name] = value.Value
	end

	for i, value in player.invisstats:GetChildren() do
		dataDictionary[value.Name] = value.Value
	end

	return dataDictionary

end

function DataModule:SaveAllPlayers()
	for i, player in Players:GetPlayers() do
		self:SavePlayerData(player, nil, true)
	end
end

function DataModule:CreatePlayerLightDataAndJoinData(player, dataTable)

	local cachedPlayerData = self.LightPlayerData:AddToCache(DeepCopy(dataTable), player.UserId)
	local playerDataOnJoin = self.PlayerDataOnJoin:AddToCache(DeepCopy(dataTable), player.UserId)

	for _, valueObject in player.leaderstats:GetChildren() do
		valueObject.Changed:Connect(function()
			self.LightPlayerData:AddItemToListInCache(valueObject.Name, valueObject.Value, player.UserId)
		end)
	end

	for _, valueObject in player.invisstats:GetChildren() do
		valueObject.Changed:Connect(function()
			self.LightPlayerData:AddItemToListInCache(valueObject.Name, valueObject.Value, player.UserId)
		end)
	end

end

function DataModule:AutosavePlayerAsync(player)
	coroutine.wrap(function()
		while player do
			task.wait(180)

			self:SavePlayerData(player)

		end
	end)	
end

function DataModule:CreatePlayerLeaderstats(player: Player)
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"

	local invisstats = Instance.new("Folder", player)
	invisstats.Name = "invisstats"

	for i, statType in self.basePlayerStats do

		local name = statType[1]
		local statClass = statType[2]
		local baseValue = statType[3]
		local parent = statType[4]

		local newStat = Instance.new(statClass, player[parent])
		newStat.Name = name
		newStat.Value = baseValue

	end

end

function DataModule:SaveToScope(store: DataStore, key: string, value: any)
	for i = 1, 10 do
		local success, err = pcall(function()
			store:SetAsync(key, value)	
		end)
		if success then break end
		task.wait(i)
	end
end

function DataModule:GetOrderedscopedDataStore(scopeName)
	return self.orderedDataScopes[scopeName]
end

return DataModule.new()
