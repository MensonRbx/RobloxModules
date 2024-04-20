local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local StudioStore = DataStoreService:GetDataStore("StudioStore")

local MAX_TRIES = 5

local LeaderstatStore = {}
LeaderstatStore.__index = LeaderstatStore

function LeaderstatStore.new()
	local self = setmetatable({}, LeaderstatStore)
	
	local onPlayerJoined = function(player)
		self:PlayerJoin(player)
	end
	
	local onPlayerLeave = function(player)
		self:SavePlayerData(player)
	end
	
	self.valueObjects = {
		{"NumberValue", "Money", 0},
		{"NumberValue", "Bank", 0},
	}
	
	Players.PlayerAdded:Connect(onPlayerJoined)
	Players.PlayerRemoving:Connect(onPlayerLeave)
	
	return self
end

function LeaderstatStore:PlayerJoin(player)
	
	self:CreateLeaderstats(player)
	
	local playerData = self:GetPlayerData(player)
	
	if playerData then
		self:SetPlayerData(player, playerData)
	end
	
end

function LeaderstatStore:CreateLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	for i, dataTable in self.valueObjects do
		local dataType = dataTable[1]
		local dataName = dataTable[2]
		local dataDefault = dataTable[3]

		local dataObject = Instance.new(dataType)
		dataObject.Name = dataName
		dataObject.Value = dataDefault

		dataObject.Parent = leaderstats
	end
end

function LeaderstatStore:GetPlayerData(player)
	
	local key = tostring(player.UserId)
	local tries = 0
	
	repeat
		local success, data = pcall(function()
			return StudioStore:GetAsync(key)
		end)
		
		if success then
			return data
		end
		
		tries += 1
		task.wait(2)
	until tries > MAX_TRIES
	
end

function LeaderstatStore:SetPlayerData(player, playerData)
	
	for name, value in playerData do
		player.leaderstats:WaitForChild(name).Value = value
	end
	
end

function LeaderstatStore:GetLeaderstats(player)
	local data = {}
	
	for _, valueObject in player.leaderstats:GetChildren() do
		data[valueObject.Name] = valueObject.Value
	end
	
	return data
end

function LeaderstatStore:SavePlayerData(player)
	
	local key = tostring(player.UserId)
	local tries = 0
	
	local dataToSave = self:GetLeaderstats(player)

	repeat
		local success, _ = pcall(function()
			return StudioStore:SetAsync(key, dataToSave)
		end)

		if success then
			return 
		end

		tries += 1
		task.wait(2)
	until tries > MAX_TRIES
	
end

return LeaderstatStore.new()
