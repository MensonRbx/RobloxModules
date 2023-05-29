--!strict

--[[
	UserInventoryFetchModule:
		
	Module created to get user's inventory data from a proxy server
	
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local MAX_RECURSIVE_ATTEMPTS = 5
local MAX_GET_ASYNC_REQUESTS = 5
local MAX_JSON_DECODE = 5

local CACHE_DELETE_TIME = 10

local baseUrl = "https://www.roproxy.com/users/inventory/list-json?assetTypeId=34&cursor=&itemsPerPage=100&pageNumber=%s&userId=%s"

local InventoryFetchModule = {}
InventoryFetchModule.__index = InventoryFetchModule

function InventoryFetchModule.new()
	local self = setmetatable({}, InventoryFetchModule)
	
	self.inventoryCache = {}
	
	return self
end

function InventoryFetchModule:GetPlayerInventroyAsync(userId: number, pageNumber: number)
	pageNumber = pageNumber or 1
	
	local cachedInventory = self.inventoryCache[userId]
	
	if cachedInventory then
		return cachedInventory 
	end
	
	local JSONData = self:_GetJSONData(pageNumber, userId)
	
	if not JSONData then
		warn("Inventory for player",userId,"not found!")
		return false
	end
	
	local inventory = self:_DecodeJSONAsync(JSONData, userId)	
	
	if not inventory then
		warn("Inventory for player",userId,"not found!")
		return false
	end
	
	self.inventoryCache[userId] = inventory
	
	task.delay(CACHE_DELETE_TIME, rawset, self.inventoryCache, userId, nil)
	
	return inventory
end

function InventoryFetchModule:GetPlayerItems(playerId: number, playerMadeItems: boolean, dataTable: {[string]: any})
	dataTable = dataTable or self:GetPlayerInventroyAsync(playerId)

	if not playerMadeItems then
		return dataTable.Data.Items
	else
		return self:_GetPlayerMadeItems(playerId, dataTable.Data.Items)
	end

end

function InventoryFetchModule:_GetPlayerMadeItems(playerId: number, listOfItems): {[number]: any}

	local playerMadeItems: {[number]: any} = {}

	for index, item in listOfItems do
		local creator = item.Creator
		if creator.Id == playerId then
			table.insert(playerMadeItems, item)
		end
	end

	return playerMadeItems

end

--[[Private]]--
function InventoryFetchModule:_GetJSONData(pageNumber: number, userId: number, lastLength: number)

	local attempts = 0
	local requestUrl = baseUrl:format(pageNumber, userId)

	repeat
		local requestSuccess, result = pcall(function()
			return HttpService:GetAsync(requestUrl)
		end)

		if requestSuccess and result then
			return result
		end
		attempts += 1
	until attempts >= MAX_GET_ASYNC_REQUESTS

	error("Failed to get JSON data for player "..userId)

	return false
end

function InventoryFetchModule:_DecodeJSONAsync(jsonToDecode: string, userId: number)

	local attempts = 0

	repeat
		local getDataSuccess, playerDataTable= pcall(function()
			return HttpService:JSONDecode(jsonToDecode)
		end)

		if getDataSuccess and playerDataTable then
			return playerDataTable
		end

		attempts += 1
	until attempts > MAX_JSON_DECODE

	error("Failed to decode JSON data for player "..userId)

	return false
end

return InventoryFetchModule.new()
