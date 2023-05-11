--!strict

--[[
	UserInventoryFetchModule:
		
	Module created to get user's inventory data from a proxy
	
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local MAX_RECURSIVE_ATTEMPTS = 5
local MAX_GET_ASYNC_REQUESTS = 5
local MAX_JSON_DECODE = 5

local baseUrl = "https://www.roproxy.com/users/inventory/list-json?assetTypeId=34&cursor=&itemsPerPage=100&pageNumber=%s&userId=%s"

local InventoryFetchModule = {}
InventoryFetchModule.__index = InventoryFetchModule

function InventoryFetchModule.new()
	local self = setmetatable({}, InventoryFetchModule)

	return self
end

function InventoryFetchModule:GetPlayerInventroyRecursive(userId: number, pageNumber: number, lastLength: number)
	
	lastLength = lastLength or 0
	pageNumber = pageNumber or 1	
	
	if lastLength > MAX_RECURSIVE_ATTEMPTS then
		return 
	end
	
	local JSONData = self:_GetJSONData(pageNumber, userId, lastLength)
	
	if JSONData then
		return self:_DecodeJSONAsync(JSONData, userId)		
	end
	
end

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

function InventoryFetchModule:GetPlayerItems(player, dataTable)
	dataTable = dataTable or self:GetPlayerInventroyRecursive(player.UserId)
	return dataTable.Data.Items
end



return InventoryFetchModule.new()
