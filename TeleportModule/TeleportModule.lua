local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local SubModules = script.Parent:WaitForChild("SubModules")

local GetPlayerDataToSend = require(SubModules:WaitForChild("GetPlayerDataToSend", 60))

local TeleportRequest = ReplicatedStorage.TeleportRequest

local baseTeleportPlaceId = 00000000

local ATTEMPT_LIMIT = 5
local RETRY_DELAY = 1
local FLOOD_DELAY = 15

local TeleportModule = {}
TeleportModule.__index = TeleportModule

function TeleportModule.new()
	local self = setmetatable({}, TeleportModule)
	
	local onTeleportRequest = function(player: Player, placeId: number)
		self:TeleportPlayerAsync(player, placeId)
	end
	
	local handleFailedTeleport = function(player: Player, teleportResult: TeleportAsyncResult, errorMessage: string, targetPlaceId: number, teleportOptions: TeleportOptions)
		self:HandleFailedTeleport(player, teleportResult, errorMessage, targetPlaceId, teleportOptions)
	end
	
	TeleportRequest.OnServerEvent:Connect(onTeleportRequest)
	TeleportService.TeleportInitFailed:Connect(handleFailedTeleport)
	
	return self
end

function TeleportModule:TeleportPlayerAsync(player: Player, placeId: number)
	
	placeId = placeId or baseTeleportPlaceId
	
	local attemptIndex = 0
	local success, result
	
	local options = Instance.new("TeleportOptions")
	local playerData = GetPlayerDataToSend(player)
	options:SetTeleportData(playerData)

	repeat
		success, result = pcall(function()
			return TeleportService:TeleportAsync(placeId, {player}, options)
		end)
		attemptIndex += 1
		if not success then
			task.wait(RETRY_DELAY)
		end
	until success or attemptIndex == ATTEMPT_LIMIT 

	if not success then
		warn(result) 
	end

	return success, result
	
end

function TeleportModule:HandleFailedTeleport(player: Player, teleportResult: TeleportAsyncResult, errorMessage: string, targetPlaceId: number, teleportOptions: TeleportOptions)
	if teleportResult == Enum.TeleportResult.Flooded then
		task.wait(FLOOD_DELAY)
	elseif teleportResult == Enum.TeleportResult.Failure then
		task.wait(RETRY_DELAY)
	else
		error(("Invalid teleport [%s]: %s"):format(teleportResult.Name, errorMessage))
	end

	self:TeleportPlayerAsync(targetPlaceId, {player}, teleportOptions)
end

return TeleportModule.new()
