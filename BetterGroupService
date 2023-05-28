local GroupService = game:GetService("GroupService")

local MAX_RETRIES = 5

local BetterGroupService = {}
BetterGroupService.__index = BetterGroupService

function BetterGroupService.new()
	local self = setmetatable({}, BetterGroupService)
	
	self.playerGroupsCache = {}
	self.groupInfoCache = {}
	self.groupAlliesCache = {}
	self.groupEnemiesCache = {}
	
	return self
end

function BetterGroupService:GetPlayerGroups(playerId)
	if self.playerGroupsCache[playerId] then
		return self.playerGroupsCache[playerId]
	end
	
	local playerGroups = self:_RepeatAsyncMethod("GetGroupsAsync", playerId)
	
	self.playerGroupsCache[playerId] = playerGroups
	
	return playerGroups 
end

function BetterGroupService:GetGroupInfo(groupId)
	if self.groupInfoCache[groupId] then
		return self.groupInfoCache[groupId]
	end
	
	local groupInfo = self:_RepeatAsyncMethod("GetGroupInfoAsync", groupId)
	
	self.groupInfoCache[groupId] = groupInfo
	
	return groupInfo
end

function BetterGroupService:GetGroupAllies(groupId)
	if self.groupAlliesCache[groupId] then
		return self.groupAlliesCache[groupId]
	end
	
	local pages = self:_RepeatAsyncMethod("GetAlliesAsync", groupId)
	local tableOfPage = self:_GetPagesAsTable(pages)

	self.groupAlliesCache[groupId] = tableOfPage
	
	return tableOfPage
end

function BetterGroupService:GetGroupEnemies(groupId)
	if self.groupEnemiesCache[groupId] then
		return self.groupEnemiesCache[groupId]
	end
	
	local pages: StandardPages = self:_RepeatAsyncMethod("GetEnemiesAsync", groupId)
	local tableOfPage = self:_GetPagesAsTable(pages)
	
	self.groupEnemiesCache[groupId] = tableOfPage
	
	return tableOfPage 
end

function BetterGroupService:_GetPagesAsTable(pages)
	
	local dataTable = {}
	repeat
		local tempData = pages:GetCurrentPage()

		for key, value in tempData do
			dataTable[key] = value
		end

		if pages.IsFinished then
			return dataTable
		end

		pcall(pages.AdvanceToNextPageAsync, pages)
	until pages.IsFinished
	
end

function BetterGroupService:_RepeatAsyncMethod(method: () -> any, ...: any)
	
	local retries = 0
	
	repeat
		local success, value = pcall(GroupService[method], GroupService, ...)
		
		if success and value then
			return value, retries
		end
		
		print(success, value)
		
		task.wait(2)
		retries += 1
	until retries > MAX_RETRIES
	
end

return BetterGroupService.new()
